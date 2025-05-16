function analyze_prop_models_korekce()
    % === Konfigurace vstupních a výstupních souborů ===
    configs = {
        {'VF_B20_NB.xlsx', 'Brno-cells-nbiot.xlsx', 'results_nb_korekce.xlsx', 'NB'};
        {'VF_B8_M.xlsx',   'Brno-cells-catm.xlsx',  'results_ltem_korekce.xlsx', 'LTE'};
    };

    % --- Globální korekční členy podle technologie a modelu ---
    korekce = struct();
    korekce.NB = [-44.8, -47.5, -23.0];    % OH, COST231, Ericsson
    korekce.LTE = [-34.0, -36.2, -14.9];

    hm = 1.5;

    for c = 1:size(configs, 1)
        input_file  = configs{c}{1};
        bts_file    = configs{c}{2};
        output_file = configs{c}{3};
        tech        = configs{c}{4};

        % --- Načti vstupy ---
        data = readtable(input_file, 'VariableNamingRule','preserve');
        bts_db = readtable(bts_file, 'VariableNamingRule','preserve');
        n = height(data);

        % --- Inicializace výstupních sloupců ---
        Distance = zeros(n,1);
        RSRP_OH = zeros(n,1);
        RSRP_COST = zeros(n,1);
        RSRP_Eric = zeros(n,1);
        BTS_Lat_used = zeros(n,1);
        BTS_Lon_used = zeros(n,1);

        for i = 1:n
            lat2 = deg2rad(str2double(data.Latitude(i)));
            lon2 = deg2rad(str2double(data.Longitude(i)));
            cell_id = data.CID(i);
            earfcn_val = data.earfcn(i);

            % Frekvence
            if earfcn_val == 3544
                f = 801.4;
            elseif earfcn_val == 6447
                f = 945.0;
            else
                f = 900;
            end

            match = find(bts_db.CellID == cell_id, 1);
            if isempty(match)
                warning("CellID %d nebyl nalezen v BTS databázi.", cell_id);
                continue;
            end

            lat1 = deg2rad(str2double(bts_db.Latitude(match)));
            lon1 = deg2rad(str2double(bts_db.Longitude(match)));
            hb = bts_db.Height(match);
            BTS_Lat_used(i) = str2double(bts_db.Latitude(match));
            BTS_Lon_used(i) = str2double(bts_db.Longitude(match));

            % --- Vzdálenost (Haversine) ---
            a = sin((lat2 - lat1)/2)^2 + cos(lat1)*cos(lat2)*sin((lon2 - lon1)/2)^2;
            c_ = 2 * atan2(sqrt(a), sqrt(1 - a));
            d_km = 6371 * c_;
            Distance(i) = d_km;

            % Výpočty
            ahm = (1.1 * log10(f) - 0.7)*hm - (1.56 * log10(f) - 0.8);
            g_f = 44.49*log10(f) - 4.78*(log10(f))^2;

            L_OH = 69.55 + 26.16*log10(f) - 13.82*log10(hb) - ahm + ...
                   (44.9 - 6.55*log10(hb))*log10(d_km);
            L_COST = 46.3 + 33.9*log10(f) - 13.82*log10(hb) - ahm + ...
                     (44.9 - 6.55*log10(hb))*log10(d_km) + 3;
            L_Eric = 36.2 + 30.2*log10(d_km) - 12*log10(hb) + ...
                     0.1*log10(hb)*log10(d_km) - 3.2*(log10(11.75*hm))^2 + g_f;

            K = korekce.(tech);  % korekční členy: [OH, COST231, Ericsson]

            RSRP_OH(i)   = -(L_OH   + K(1));
            RSRP_COST(i) = -(L_COST + K(2));
            RSRP_Eric(i) = -(L_Eric + K(3));
        end

        % Výpočet rozdílů
        rsrp_measured = data.rsrp;
        Diff_OH   = abs(rsrp_measured - RSRP_OH);
        Diff_COST = abs(rsrp_measured - RSRP_COST);
        Diff_Eric = abs(rsrp_measured - RSRP_Eric);

        % Výstupní tabulka
        results = table(data.Latitude, data.Longitude, rsrp_measured, ...
                        BTS_Lat_used, BTS_Lon_used, ...
                        Distance, ...
                        RSRP_OH, RSRP_COST, RSRP_Eric, ...
                        Diff_OH, Diff_COST, Diff_Eric, ...
                        'VariableNames', {'Latitude', 'Longitude', 'RSRP_measured', ...
                                          'BTS_Lat_used', 'BTS_Lon_used', ...
                                          'Distance_km', ...
                                          'RSRP_OH', 'RSRP_COST231', 'RSRP_Ericsson', ...
                                          'Diff_OH', 'Diff_COST231', 'Diff_Ericsson'});

        writetable(results, output_file);
        disp(['✅ Výstupní soubor s korekcemi uložen: ', output_file]);
    end
end

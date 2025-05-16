% Skript: analyze_prop_models.m
% Popis: Zpracuje NB-IoT (B20) i LTE-M (B8) a použije dynamické souřadnice BTS z databáze

% Konfigurace
configs = {
    {'VF_B20_NB.xlsx', 'Brno-cells-nbiot.xlsx', 'results_nb.xlsx'},   % NB-IoT
    {'VF_B8_M.xlsx',   'Brno-cells-catm.xlsx',  'results_ltem.xlsx'}  % LTE-M
};

hm = 1.5;

for c = 1:length(configs)
    input_file = configs{c}{1};
    bts_file = configs{c}{2};
    output_file = configs{c}{3};

    data = readtable(input_file, 'VariableNamingRule', 'preserve');
    bts_db = readtable(bts_file, 'VariableNamingRule', 'preserve');
    n = height(data);

    % Inicializace
    Distance = zeros(n,1);
    RSRP_OH = zeros(n,1);
    RSRP_COST = zeros(n,1);
    RSRP_Eric = zeros(n,1);
    BTS_Lat_used = zeros(n,1);
    BTS_Lon_used = zeros(n,1);

    for i = 1:n
        % --- Načtení a převod vstupních dat ---
        lat2 = deg2rad(str2double(data.Latitude(i)));
        lon2 = deg2rad(str2double(data.Longitude(i)));
        cell_id = data.CID(i);
        earfcn_val = data.earfcn(i);

        % Frekvence dle EARFCN
        if earfcn_val == 3544
            f = 801.4; % NB-IoT (B20)
        elseif earfcn_val == 6447
            f = 945.0; % LTE-M (B8)
        else
            f = 900;
        end

        % Vyhledání BTS podle CellID
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

        % --- Výpočet vzdálenosti (Haversine) ---
        a = sin((lat2 - lat1)/2)^2 + cos(lat1)*cos(lat2)*sin((lon2 - lon1)/2)^2;
        c_ = 2 * atan2(sqrt(a), sqrt(1 - a));
        d_km = 6371 * c_;
        Distance(i) = d_km;

        % Sdílené výpočty
        ahm = (1.1 * log10(f) - 0.7)*hm - (1.56 * log10(f) - 0.8);
        g_f = 44.49*log10(f) - 4.78*(log10(f))^2;

        % --- Modely ---
        L_OH = 69.55 + 26.16*log10(f) - 13.82*log10(hb) - ahm + ...
               (44.9 - 6.55*log10(hb))*log10(d_km);
        RSRP_OH(i) = -L_OH;

        L_COST = 46.3 + 33.9*log10(f) - 13.82*log10(hb) - ahm + ...
                 (44.9 - 6.55*log10(hb))*log10(d_km) + 3;
        RSRP_COST(i) = -L_COST;

        L_Eric = 36.2 + 30.2*log10(d_km) - 12*log10(hb) + ...
                 0.1*log10(hb)*log10(d_km) - 3.2*(log10(11.75*hm))^2 + g_f;
        RSRP_Eric(i) = -L_Eric;
    end

    % Výpočet rozdílů
    Diff_OH = abs(data.rsrp - RSRP_OH);
    Diff_COST = abs(data.rsrp - RSRP_COST);
    Diff_Eric = abs(data.rsrp - RSRP_Eric);

    % Výstup
 results = table(data.Latitude, data.Longitude, data.rsrp, ...
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
    disp(['✅ Výsledky uloženy do: ', output_file]);
end

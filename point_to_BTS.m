%% 
% Skript: point_to_BTS.m
% Popis: Satelitní mapa spojení měřených bodů s BTS pro NB-IoT a LTE-M

% --- Konfigurace ---
configs = {
    'results_nb.xlsx',   'NB-IoT', 'spojeni_nbiot_satelit.png';
    'results_ltem.xlsx', 'LTE-M',  'spojeni_ltem_satelit.png'
};

% --- Vytvoření výstupní složky ---
outputFolder = 'satellite_maps_spojeni_bts';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% --- Smyčka přes technologie ---
for i = 1:size(configs, 1)
    % --- Konfigurace ---
    file = configs{i,1};
    tech = configs{i,2};
    outputFile = configs{i,3};

    % --- Načtení a převod ---
    T = readtable(file, 'VariableNamingRule', 'preserve');
    lat_user = str2double(string(T.Latitude));
    lon_user = str2double(string(T.Longitude));
    lat_bts  = str2double(string(T.BTS_Lat_used));
    lon_bts  = str2double(string(T.BTS_Lon_used));

    % --- Filtrace ---
    valid = ~isnan(lat_user) & ~isnan(lon_user) & ...
            ~isnan(lat_bts) & ~isnan(lon_bts) & ...
            lat_bts >= 48.5 & lat_bts <= 49.5 & ...
            lon_bts >= 15.5 & lon_bts <= 17.5;

    lat_user = lat_user(valid);
    lon_user = lon_user(valid);
    lat_bts  = lat_bts(valid);
    lon_bts  = lon_bts(valid);

    % --- Unikátní BTS a barvy ---
    bts_coords = unique([lat_bts, lon_bts], 'rows');
colors = [
    0 0 0;     % černá
    0 0 1;     % modrá
    0 1 0;     % zelená
    0 1 1;     % modrá 2
    1 0 0;     % červená
    1 0.5 0;     
    1 1 0;     % žlutá
    1 1 1;     % bila
];

% Pokud je více BTS než barev, opakuj barvy
if size(bts_coords,1) > size(colors,1)
    colors = repmat(colors, ceil(size(bts_coords,1)/size(colors,1)), 1);
end


    % --- Vykreslení ---
    figure('Color', 'w');
    geobasemap satellite;
    hold on;

    for k = 1:size(bts_coords,1)
        lat_b = bts_coords(k,1);
        lon_b = bts_coords(k,2);
        idx = (lat_bts == lat_b) & (lon_bts == lon_b);
        c = colors(k,:);

        % Spojnice (poloprůhledné)
        for j = find(idx)'
            geoplot([lat_user(j), lat_bts(j)], [lon_user(j), lon_bts(j)], ...
                '-', 'Color', [c 0.4], 'LineWidth', 0.6, 'HandleVisibility', 'off');
        end

        % Měřené body – bez legendy
        geoscatter(lat_user(idx), lon_user(idx), 16, c, 'o', 'filled', 'HandleVisibility', 'off');

        % BTS – první s legendou
        if k == 1
            geoscatter(lat_b, lon_b, 60, c, '^', 'filled', 'DisplayName', 'BTS');
            geoscatter(NaN, NaN, 16, 'k', 'o', 'filled', 'DisplayName', 'Měřené body');
        else
            geoscatter(lat_b, lon_b, 60, c, '^', 'filled', 'HandleVisibility', 'off');
        end
    end

    % --- Popisky ---
    title([tech, ': Spojení měřených bodů s BTS'], 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 9);

    % --- Dynamické ohraničení ---
    lat_all = [lat_user; lat_bts];
    lon_all = [lon_user; lon_bts];
    margin_lat = 0.01;
    margin_lon = 0.01;
    geolimits([min(lat_all)-margin_lat, max(lat_all)+margin_lat], ...
              [min(lon_all)-margin_lon, max(lon_all)+margin_lon]);

    % --- Export ---
    set(gcf, 'Toolbar', 'none');
    drawnow;
    exportgraphics(gcf, fullfile(outputFolder, outputFile), 'Resolution', 300);
    disp(['✅ Mapa pro ', tech, ' byla uložena jako ', outputFile]);
end

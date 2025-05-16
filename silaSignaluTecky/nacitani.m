clc; clear; close all;

% Načtení dat z Excelu
filename = 'data.xlsx';
data = readtable(filename);

% Možné metriky
options = {'rsrp_B20', 'sinr_B20', 'rsrp_B8', 'sinr_B8'};

% Výběr metriky uživatelem
fprintf('Dostupné metriky pro vizualizaci:\n');
for i = 1:length(options)
    fprintf('%d) %s\n', i, options{i});
end
choice = input('Zadejte číslo metriky, kterou chcete zobrazit: ');
if choice < 1 || choice > length(options)
    error('Neplatná volba.');
end
selected_metric = options{choice};

% Načtení dat
latitudes = str2double(string(data.Latitude));
longitudes = str2double(string(data.Longitude));
values = data.(selected_metric);

% Odstranění neplatných řádků
valid_idx = ~isnan(latitudes) & ~isnan(longitudes) & ~isnan(values);
latitudes = latitudes(valid_idx);
longitudes = longitudes(valid_idx);
values = values(valid_idx);

% Definice barev a popisků
if contains(selected_metric, 'rsrp', 'IgnoreCase', true)
    thresholds = [-120, -105, -90, -75];
    colors = [
        0.5, 0, 0;   % Téměř žádný
        1, 0, 0;     % Velmi slabý
        1, 0.5, 0;   % Slabší
        1, 1, 0;     % Dobrý
        0, 1, 0      % Výborný
    ];
    labels = {
        '< -120 dBm (Téměř žádný)', ...
        '-120 až -106 dBm', ...
        '-105 až -91 dBm', ...
        '-90 až -76 dBm', ...
        '≥ -75 dBm (Výborný)'};
    metric_label = 'RSRP (dBm)';
else
    thresholds = [0, 4, 8, 11];  % 4 prahy → 5 intervalů
    colors = [
        0.5, 0, 0;   % Téměř žádný
        1, 0, 0;     % Velmi slabý
        1, 0.5, 0;   % Slabší
        1, 1, 0;     % Dobrý
        0, 1, 0      % Výborný
    ];
    labels = {
        '≤ 0 dB (Téměř žádný)', ...
        '1 až 3 dB (Velmi slabý)', ...
        '4 až 7 dB (Slabší)', ...
        '8 až 11 dB (Dobrý)', ...
        '> 11 dB (Výborný)'};
    metric_label = 'SINR (dB)';
end

% Vykreslení mapy
figure;
geobasemap satellite;
hold on;

% Přiblížení na oblast měření
if ~isempty(latitudes)
    margin = 0.01;
    geolimits([min(latitudes)-margin, max(latitudes)+margin], ...
              [min(longitudes)-margin, max(longitudes)+margin]);
end

marker_size = 10;
% Dynamická délka podle počtu barev
h_leg = gobjects(length(colors), 1);

% Vykreslení bodů
for i = 1:length(values)
    val = values(i);
    lat = latitudes(i);
    lon = longitudes(i);

    % Výběr barvy a indexu
    if val <= thresholds(1)
        idx = 1;
    elseif val <= thresholds(2)
        idx = 2;
    elseif val <= thresholds(3)
        idx = 3;
    elseif val <= thresholds(4)
        idx = 4;
    else
        idx = 5;
    end
    col = colors(idx, :);

    % Vykresli bod
    h = geoplot(lat, lon, 'o', ...
        'MarkerFaceColor', col, ...
        'MarkerEdgeColor', [0.2 0.2 0.2], ...
        'MarkerSize', marker_size, ...
        'LineWidth', 0.7);

    % Pro legendu uchovej první výskyt dané barvy
    if ~isgraphics(h_leg(idx))
        h_leg(idx) = h;
    end
end

% Vykreslení legendy (pouze platné barvy)
valid_leg_idx = isgraphics(h_leg);
if any(valid_leg_idx)
   leg = legend(h_leg(valid_leg_idx), labels(valid_leg_idx), ...
    'FontSize', 8, ...
    'Box', 'on');

% Fixní pozice legendy zarovnaná doprava nahoru v rámci okna figury
set(leg, ...
    'Units', 'normalized', ...              % Jednotky relativní k celé figure
    'Position', [0.7, 0.72, 0.2, 0.2], ...  % x, y, šířka, výška
    'Interpreter', 'none');
end

% Zobrazený název pro titulek mapy
display_names = containers.Map(...
    {'rsrp_B20', 'sinr_B20', 'rsrp_B8', 'sinr_B8'}, ...
    {'VF NB B20', 'VF NB B20', 'VF LTE-M B8', 'VF LTE-M B8'});

% Použij přehledný název do titulku
display_name = display_names(selected_metric);

title(['Mapa pokrytí: ', display_name, ' - ', metric_label]);
hold off;
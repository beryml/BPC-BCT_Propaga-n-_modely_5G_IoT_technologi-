% === Načtení GPX souborů ===
all_xml = xmlread('output.gpx');
remaining_xml = xmlread('output2.gpx');

% === Získání všech bodů (lat, lon) ===
all_points = extract_all_gpx_points(all_xml);
remaining_points = extract_all_gpx_points(remaining_xml);

% === Porovnání: změřené = ty, které chybí v output2.gpx ===
tol = 1e-6; % tolerance pro GPS porovnání
is_measured = true(size(all_points, 1), 1);

for i = 1:size(all_points,1)
    diffs_lat = abs(remaining_points(:,1) - all_points(i,1));
    diffs_lon = abs(remaining_points(:,2) - all_points(i,2));
    if any(diffs_lat < tol & diffs_lon < tol)
        is_measured(i) = false; % pokud existuje blízký bod → nezměřený
    end
end

% === Výpis statistik ===
fprintf("📌 Celkem bodů:        %d\n", size(all_points,1));
fprintf("✅ Změřených bodů:     %d\n", sum(is_measured));
fprintf("❌ Nezměřených bodů:   %d\n", sum(~is_measured));

% === Rozdělení na dvě skupiny ===
lat_all = all_points(:,1);
lon_all = all_points(:,2);

lat_zm = lat_all(is_measured);
lon_zm = lon_all(is_measured);
lat_nezm = lat_all(~is_measured);
lon_nezm = lon_all(~is_measured);

% === Vykreslení mapy ===
figure('Units', 'normalized', 'Position', [0.2 0.2 0.6 0.6])
geobasemap satellite
hold on
geoscatter(lat_zm, lon_zm, 8, 'g', 'filled')     % Změřené (zelené)
geoscatter(lat_nezm, lon_nezm, 8, 'r', 'filled') % Nezměřené (červené)

legend('Změřené body', 'Nezměřené body', ...
       'Location', 'southwest', ...
       'Box', 'on', ...
       'FontSize', 10, ...
       'TextColor', 'black', ...
       'Color', 'w');

title('Zobrazení změřených a nezměřených bodů', 'FontWeight', 'bold')
set(gca, 'FontSize', 12)
geolimits([min(lat_all)-0.005, max(lat_all)+0.005], ...
          [min(lon_all)-0.005, max(lon_all)+0.005])


function points = extract_all_gpx_points(xml)
    points = [];
    allNodes = xml.getElementsByTagName('*');

    for i = 0:allNodes.getLength-1
        item = allNodes.item(i);
        if item.hasAttribute('lat') && item.hasAttribute('lon')
            lat = str2double(strrep(char(item.getAttribute('lat')), ',', '.'));
            lon = str2double(strrep(char(item.getAttribute('lon')), ',', '.'));
            if ~isnan(lat) && ~isnan(lon)
                points(end+1,:) = [lat, lon];
            end
        end
    end
end

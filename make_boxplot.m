% Účel: Generování boxplotů s PDF exportem pro NB-IoT a LTE-M

% --- Načtení dat ---
nb = readtable("results_nb.xlsx");
lte = readtable("results_ltem.xlsx");

% --- Složka pro výstup ---
outputFolder = "boxplot_pdf";
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% --- Definice dat ---
nb_data = [nb.RSRP_measured, nb.RSRP_OH, nb.RSRP_COST231, nb.RSRP_Ericsson];
lte_data = [lte.RSRP_measured, lte.RSRP_OH, lte.RSRP_COST231, lte.RSRP_Ericsson];
% --- Popisky sloupců ---
labels = {'Naměřené hodnoty', 'Model Okumura-Hata', 'Model COST-231', 'Model Ericsson 9999'};

% --- Vykreslení NB-IoT ---
figure;
boxplot(nb_data, 'Labels', labels);
hold on;
plot(1:4, mean(nb_data), 'r+', 'MarkerSize', 10, 'DisplayName', 'Střední hodnota RSRP [dBm]');
title("NB-IoT (Band 20): Porovnání naměřených a predikovaných hodnot RSRP");
ylabel("RSRP [dBm]");
legend('show', 'Location', 'southoutside');

yticks(-150:50:0);
ylim([-160 10]);
grid on;
ax = gca;
ax.YMinorGrid = 'on';
ax.MinorGridLineStyle = ':';
ax.YMinorTick = 'on';

% Uložení jako PDF
exportgraphics(gcf, fullfile(outputFolder, 'RSRP_Boxplot_NB.pdf'), 'ContentType', 'vector');

% --- Vykreslení LTE-M ---
figure;
boxplot(lte_data, 'Labels', labels);
hold on;
plot(1:4, mean(lte_data), 'r+', 'MarkerSize', 10, 'DisplayName', 'Střední hodnota RSRP [dBm]');
title("LTE-M (Band 8): Porovnání naměřených a predikovaných hodnot RSRP");
ylabel("RSRP [dBm]");
legend('show', 'Location', 'southoutside');

yticks(-150:50:0);
ylim([-160 10]);
grid on;
ax = gca;
ax.YMinorGrid = 'on';
ax.MinorGridLineStyle = ':';
ax.YMinorTick = 'on';

% Uložení jako PDF
exportgraphics(gcf, fullfile(outputFolder, 'RSRP_Boxplot_LTEM.pdf'), 'ContentType', 'vector');

disp('✅ Export do PDF byl úspěšný.');

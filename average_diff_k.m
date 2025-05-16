function average_diff_k()
    % === Načtení dat ===
    nb = readtable("results_nb_korekce.xlsx");
    lte = readtable("results_ltem_korekce.xlsx");

    % === Vytvoření složky pro výstupy ===
    outputFolder = "graf_korekce";
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end

    % === Mezní hodnota pro validní rozdíly ===
    threshold = 50;  % dBm – maximum tolerované odchylky

    % === Filtrovací anonymní funkce ===
    filtruj = @(x) x(~isnan(x) & x >= 0 & x <= threshold);

    % === Zpracování NB-IoT ===
    data_nb = [
        mean(filtruj(nb.Diff_OH));
        mean(filtruj(nb.Diff_COST231));
        mean(filtruj(nb.Diff_Ericsson))
    ];

    figure('Color', 'w');
    b = bar(data_nb, 0.5, 'FaceColor', [0.2 0.6 1]);
    set(gca, 'XTickLabel', {'Okumura-Hata', 'COST-231', 'Ericsson 9999'});
    ylabel('Průměrná odchylka RSRP [dBm]');
    title('NB-IoT: Průměrné rozdíly modelů');
    grid on;
    ylim([0 max(data_nb)+5]);
    exportgraphics(gcf, fullfile(outputFolder, 'nb_diff_avg.pdf'), 'ContentType', 'vector');
    close;

    % === Zpracování LTE-M ===
    data_lte = [
        mean(filtruj(lte.Diff_OH));
        mean(filtruj(lte.Diff_COST231));
        mean(filtruj(lte.Diff_Ericsson))
    ];

    figure('Color', 'w');
    b = bar(data_lte, 0.5, 'FaceColor', [1 0.5 0.1]);
    set(gca, 'XTickLabel', {'Okumura-Hata', 'COST-231', 'Ericsson 9999'});
    ylabel('Průměrná odchylka RSRP [dBm]');
    title('LTE-M: Průměrné rozdíly modelů');
    grid on;
    ylim([0 max(data_lte)+5]);
    exportgraphics(gcf, fullfile(outputFolder, 'ltem_diff_avg.pdf'), 'ContentType', 'vector');
    close;

    disp("✅ Grafy s filtrem na extrémní hodnoty uloženy do složky graf_korekce.");
end

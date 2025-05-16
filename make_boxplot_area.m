function make_boxplot_area()
    % === Načtení dat ===
    nb = readtable("results_nb.xlsx");
    lte = readtable("results_ltem.xlsx");

    nb.Latitude = str2double(nb.Latitude);
    nb.Longitude = str2double(nb.Longitude);
    lte.Latitude = str2double(lte.Latitude);
    lte.Longitude = str2double(lte.Longitude);

    % === Výstupní složka ===
    outputFolder = "boxplot_oblasti";
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end

    % === Definice oblastí ===
    oblasti = {
        "Lisen",          [49.1903689, 49.2143156], [16.6539039, 16.7033425];
        "SlatinaLetiste", [49.1524908, 49.1916592], [16.6481533, 16.7058317];
    };

    in_any_nb = false(height(nb),1);
    in_any_lte = false(height(lte),1);

    for i = 1:size(oblasti,1)
        oblast_nazev = oblasti{i,1};
        lat_range = oblasti{i,2};
        lon_range = oblasti{i,3};

        mask_nb = nb.Latitude >= lat_range(1) & nb.Latitude <= lat_range(2) & ...
                  nb.Longitude >= lon_range(1) & nb.Longitude <= lon_range(2);
        mask_lte = lte.Latitude >= lat_range(1) & lte.Latitude <= lat_range(2) & ...
                   lte.Longitude >= lon_range(1) & lte.Longitude <= lon_range(2);

        in_any_nb = in_any_nb | mask_nb;
        in_any_lte = in_any_lte | mask_lte;

        vykresli_a_uloz(nb(mask_nb,:), lte(mask_lte,:), oblast_nazev, outputFolder);
    end

    vykresli_a_uloz(nb(~in_any_nb,:), lte(~in_any_lte,:), "OkoliVUT", outputFolder);

    disp("✅ Všechny boxploty byly vygenerovány a uloženy.");
end

function vykresli_a_uloz(nb_data, lte_data, oblast_nazev, folder)
    % Převod interního názvu na hezčí název pro titulek
    switch oblast_nazev
        case "Lisen"
            oblast_text = "Líšeň";
        case "SlatinaLetiste"
            oblast_text = "Slatina + letiště";
        case "OkoliVUT"
            oblast_text = "Okolí VUT";
        otherwise
            oblast_text = oblast_nazev;
    end
    

if isempty(nb_data) || isempty(lte_data)
        warning("❗ Oblast '%s' neobsahuje žádná data. Přeskočeno.", oblast_nazev);
        return;
    end

    labels = {'Naměřené hodnoty', 'Model Okumura-Hata', 'Model COST-231', 'Model Ericsson 9999'};

    % === NB-IoT ===
    data_nb = [nb_data.RSRP_measured, nb_data.RSRP_OH, nb_data.RSRP_COST231, nb_data.RSRP_Ericsson];
    figure;
    boxplot(data_nb, 'Labels', labels);
    hold on;
    plot(1:4, mean(data_nb), 'r+', 'MarkerSize', 10, 'DisplayName', 'Střední hodnota RSRP [dBm]');
    title("NB-IoT – " + oblast_text + ": Naměřené vs. predikované RSRP");
    ylabel("RSRP [dBm]");
    legend('show', 'Location', 'southoutside');
    grid on;

    % Kompletní sada čar po 10 dBm
ytick_vals = -150:10:-50;

% Popisky: jen pro hlavní tři hodnoty, ostatní prázdné
tick_labels = strings(size(ytick_vals));
tick_labels(ytick_vals == -150) = "-150 dBm";
tick_labels(ytick_vals == -100) = "-100 dBm";
tick_labels(ytick_vals == -50)  = "-50 dBm";

ax = gca;
ylim(ax, [-160 -40]);
yticks(ax, ytick_vals);
yticklabels(ax, tick_labels);
ax.XTickLabelRotation = 0;
ax.TickLabelInterpreter = 'none';
ax.FontSize = 10;

    exportgraphics(gcf, fullfile(folder, "NB_" + oblast_nazev + ".pdf"), 'ContentType', 'vector');
    close;

    % === LTE-M ===
    data_lte = [lte_data.RSRP_measured, lte_data.RSRP_OH, lte_data.RSRP_COST231, lte_data.RSRP_Ericsson];
    figure;
    boxplot(data_lte, 'Labels', labels);
    hold on;
    plot(1:4, mean(data_lte), 'r+', 'MarkerSize', 10, 'DisplayName', 'Střední hodnota RSRP [dBm]');
    title("LTE-M – " + oblast_text + ": Naměřené vs. predikované RSRP");
    ylabel("RSRP [dBm]");
    legend('show', 'Location', 'southoutside');
    grid on;

    % Kompletní sada čar po 10 dBm
ytick_vals = -150:10:-50;

% Popisky: jen pro hlavní tři hodnoty, ostatní prázdné
tick_labels = strings(size(ytick_vals));
tick_labels(ytick_vals == -150) = "-150 dBm";
tick_labels(ytick_vals == -100) = "-100 dBm";
tick_labels(ytick_vals == -50)  = "-50 dBm";

ax = gca;
ylim(ax, [-160 -40]);
yticks(ax, ytick_vals);
yticklabels(ax, tick_labels);
ax.XTickLabelRotation = 0;
ax.TickLabelInterpreter = 'none';
ax.FontSize = 10;

    exportgraphics(gcf, fullfile(folder, "LTE_" + oblast_nazev + ".pdf"), 'ContentType', 'vector');
    close;
end

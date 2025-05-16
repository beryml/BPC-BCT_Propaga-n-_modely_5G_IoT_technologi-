function average_diff()
    % === Načtení dat ===
    nb = readtable("results_nb.xlsx");
    lte = readtable("results_ltem.xlsx");

    nb.Latitude = str2double(nb.Latitude);
    nb.Longitude = str2double(nb.Longitude);
    lte.Latitude = str2double(lte.Latitude);
    lte.Longitude = str2double(lte.Longitude);

    % === Definice oblastí ===
    oblasti = {
        "Líšeň",            [49.1903689, 49.2143156], [16.6539039, 16.7033425];
        "Slatina + Letiště",[49.1524908, 49.1916592], [16.6481533, 16.7058317];
    };

    vysledky_nb = [];
    vysledky_lte = [];
    mask_all_nb = false(height(nb),1);
    mask_all_lte = false(height(lte),1);

    for i = 1:size(oblasti,1)
        oblast = oblasti{i,1};
        lat_rng = oblasti{i,2};
        lon_rng = oblasti{i,3};

        mask_nb = in_oblast(nb, lat_rng, lon_rng);
        mask_lte = in_oblast(lte, lat_rng, lon_rng);

        mask_all_nb = mask_all_nb | mask_nb;
        mask_all_lte = mask_all_lte | mask_lte;

        vysledky_nb = [vysledky_nb; zpracuj_oblast(nb(mask_nb,:), oblast)];
        vysledky_lte = [vysledky_lte; zpracuj_oblast(lte(mask_lte,:), oblast)];
    end

    % Přidej "Okolí VUT"
    vysledky_nb = [vysledky_nb; zpracuj_oblast(nb(~mask_all_nb,:), "Okolí VUT")];
    vysledky_lte = [vysledky_lte; zpracuj_oblast(lte(~mask_all_lte,:), "Okolí VUT")];

    % Přidej souhrnný řádek
    vysledky_nb = [vysledky_nb; souhrn_radek(vysledky_nb)];
    vysledky_lte = [vysledky_lte; souhrn_radek(vysledky_lte)];

    % Výpis
    fprintf("--------------- NB-IoT ---------------\n");
    tiskni_tab(vysledky_nb);
    fprintf("\n--------------- LTE-M ---------------\n");
    tiskni_tab(vysledky_lte);

    % === Grafy ===
    if ~exist("graf", 'dir')
        mkdir("graf");
    end
    vykresli_sloupcovy_graf(vysledky_nb, 'NB-IoT: Průměrné rozdíly modelů', 'graf/nb_prum_diff.pdf');
    vykresli_sloupcovy_graf(vysledky_lte, 'LTE-M: Průměrné rozdíly modelů', 'graf/ltem_prum_diff.pdf');

    disp("✅ Hotovo: Grafy uloženy jako PDF.");
end

function mask = in_oblast(T, lat_range, lon_range)
    mask = T.Latitude >= lat_range(1) & T.Latitude <= lat_range(2) & ...
           T.Longitude >= lon_range(1) & T.Longitude <= lon_range(2);
end

function row = zpracuj_oblast(T, oblast)
    row = table;
    row.Oblast = string(oblast);
    oh   = T.Diff_OH(~isnan(T.Diff_OH));
    cost = T.Diff_COST231(~isnan(T.Diff_COST231));
    eri  = T.Diff_Ericsson(~isnan(T.Diff_Ericsson));

    row.Okumura  = round(mean(abs(oh)), 1);
    row.COST231  = round(mean(abs(cost)), 1);
    row.Ericsson = round(mean(abs(eri)), 1);
end

function radek = souhrn_radek(tbl)
    radek = table;
    radek.Oblast = "Celkem";
    radek.Okumura = round(mean(tbl.Okumura),1);
    radek.COST231 = round(mean(tbl.COST231),1);
    radek.Ericsson = round(mean(tbl.Ericsson),1);
end

function tiskni_tab(tbl)
    fprintf('%-20s %12s %12s %12s\n', 'Oblast', 'Okumura-Hata', 'COST-231', 'Ericsson 9999');
    fprintf('%s\n', repmat('-', 1, 60));
    for i = 1:height(tbl)
        fprintf('%-20s %12.1f %12.1f %12.1f\n', ...
            tbl.Oblast(i), tbl.Okumura(i), tbl.COST231(i), tbl.Ericsson(i));
    end
end

function vykresli_sloupcovy_graf(tbl, nazev, soubor)
    figure('Color','w');
    data = [tbl.Okumura, tbl.COST231, tbl.Ericsson];
    b = bar(data, 'grouped');
    b(1).FaceColor = [0.2 0.2 0.8];  % modrá
    b(2).FaceColor = [0.9 0.4 0.1];  % oranžová
    b(3).FaceColor = [0.2 0.7 0.2];  % zelená

    set(gca, 'XTickLabel', tbl.Oblast, 'FontSize', 11);
    ylabel('Průměrná odchylka RSRP [dBm]');
    title(nazev, 'FontWeight', 'bold');
    legend({'Okumura-Hata', 'COST-231', 'Ericsson 9999'}, 'Location', 'northoutside', 'Orientation', 'horizontal');
    ylim([0 max(data, [], 'all') + 10]);
    grid on;

    exportgraphics(gcf, soubor, 'ContentType', 'vector', 'Resolution', 300);
    close;
end

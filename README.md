# Analýza a vizualizace RSRP pro NB-IoT a LTE-M v MATLABu

Tento repozitář obsahuje MATLAB skripty a datové soubory použité v rámci bakalářské práce zaměřené na analýzu propagačních modelů a porovnání modelovaných a naměřených hodnot signálu RSRP pro technologie NB-IoT a LTE-M.

## 📂 Struktura projektu

- `analyze_prop_models.m`  
  Hlavní skript pro výpočet teoretických RSRP hodnot dle modelů (Okumura-Hata, COST-231, Ericsson 9999).

- `analyze_prop_models_korekce.m`  
  Modifikovaný skript s aplikací korekčních členů pro přesnější predikci.

- `make_boxplot.m`, `make_boxplot_area.m`  
  Generování boxplotů rozdílů mezi měřením a výpočtem, včetně rozdělení dle oblastí.

- `graf`, `graf_korekce`, `boxplot_pdf`  
  Výstupní grafy ve formátu PDF nebo obrázků.

- `point_to_BTS.m`  
  Skript pro přiřazení měřeného bodu k nejbližší BTS stanici.

- `average_diff.m`, `average_diff_k.m`  
  Výpočet průměrné odchylky mezi měřenými a modelovanými hodnotami.

## 📊 Datové soubory

- `Brno-cells-nbiot.xlsx`, `Brno-cells-catm.xlsx`  
  Lokace základnových stanic a jejich parametry.

- `VF_B20_NB.xlsx`, `VF_B8_M.xlsx`  
  Měřená data signálu NB-IoT a LTE-M.

- `results_*.xlsx`  
  Výsledky výpočtů pro jednotlivé technologie a modely, včetně aplikace korekčních členů.

## 🧪 Použité modely

- **Okumura-Hata**
- **COST 231 Hata**
- **Ericsson 9999**

Všechny modely byly upraveny o korekční člen \( K \) pro zlepšení shody s reálnými daty.

## 📌 Poznámky

- Projekt je vytvořen v prostředí **MATLAB R2023b**.
- Při spuštění skriptů je nutné mít v pracovním adresáři odpovídající datové soubory.
- Výstupy jsou uloženy v adresářích `graf`, `graf_korekce`, `boxplot_pdf`.

## 📄 Licence

Tento repozitář je součástí bakalářské práce a slouží k akademickým účelům.

---


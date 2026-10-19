"""Encode the reviewed Angkor paintings and their distinct viewpoints."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PAINTINGS = {
    "angkor_south_gate": "siem-reap-01-angkor-thom-south-gate-postoffice-v2.png",
    "angkor_bayon": "siem-reap-02-bayon-postoffice-v2.png",
    "angkor_baphuon": "siem-reap-03-baphuon-postoffice-v2.png",
    "angkor_phimeanakas": "siem-reap-04-phimeanakas-postoffice-v2.png",
    "angkor_elephants": "siem-reap-05-elephant-terrace-postoffice-v2.png",
    "angkor_leper_king": "siem-reap-06-leper-king-terrace-postoffice-v2.png",
    "angkor_royal_palace": "siem-reap-07-royal-palace-postoffice-v2.png",
    "angkor_victory_gate": "siem-reap-08-victory-gate-postoffice-v2.png",
    "angkor_chau_say": "siem-reap-09-chau-say-tevoda-postoffice-v2.png",
    "angkor_thommanon": "siem-reap-10-thommanon-postoffice-v2.png",
    "angkor_ta_keo": "siem-reap-11-ta-keo-postoffice-v2.png",
    "angkor_ta_prohm": "siem-reap-12-ta-prohm-postoffice-v2.png",
    "angkor_ta_prohm_roots_gate": "siem-reap-12-ta-prohm-roots-gate-postoffice-v2.png",
    "angkor_ta_prohm_roots_gallery": "siem-reap-12-ta-prohm-roots-gallery-postoffice-v2.png",
    "angkor_ta_prohm_colonnade": "siem-reap-12-ta-prohm-colonnade-postoffice-v2.png",
    "angkor_wat": "siem-reap-13-angkor-wat-approach-postoffice-v2.png",
    "angkor_wat_reflection": "siem-reap-13-angkor-wat-reflection-postoffice-v2.png",
    "angkor_wat_oblique": "siem-reap-13-angkor-wat-oblique-postoffice-v2.png",
    "angkor_wat_courtyard": "siem-reap-13-angkor-wat-courtyard-postoffice-v2.png",
    "angkor_bakheng": "siem-reap-14-bakheng-sunset-postoffice-v2.png",
    "angkor_bakheng_terrace": "siem-reap-14-bakheng-terrace-postoffice-v2.png",
    "angkor_banteay_kdei": "siem-reap-15-banteay-kdei-gateway-postoffice-v2.png",
    "angkor_banteay_kdei_west_gate": "siem-reap-15-banteay-kdei-west-gate-postoffice-v2.png",
    "angkor_preah_khan": "siem-reap-16-preah-khan-approach-postoffice-v2.png",
    "angkor_preah_khan_pond": "siem-reap-16-preah-khan-colonnade-postoffice-v2.png",
    "angkor_neak_pean": "siem-reap-17-neak-pean-boardwalk-postoffice-v2.png",
    "angkor_neak_pean_sanctuary": "siem-reap-17-neak-pean-sanctuary-postoffice-v2.png",
    "angkor_ta_som": "siem-reap-18-ta-som-gateway-postoffice-v2.png",
    "angkor_ta_som_roots": "siem-reap-18-ta-som-roots-postoffice-v2.png",
    "angkor_east_mebon": "siem-reap-19-east-mebon-complex-postoffice-v2.png",
    "angkor_east_mebon_elephant": "siem-reap-19-east-mebon-elephant-postoffice-v2.png",
    "angkor_pre_rup": "siem-reap-20-pre-rup-approach-postoffice-v2.png",
    "angkor_pre_rup_terrace": "siem-reap-20-pre-rup-terrace-postoffice-v2.png",
    "angkor_kravan": "siem-reap-21-kravan-front-postoffice-v2.png",
    "angkor_kravan_relief": "siem-reap-21-kravan-relief-postoffice-v2.png",
    "angkor_banteay_srei": "siem-reap-22-banteay-srei-approach-postoffice-v2.png",
    "angkor_banteay_srei_pond": "siem-reap-22-banteay-srei-pond-postoffice-v2.png",
    "angkor_beng_mealea": "siem-reap-23-beng-mealea-boardwalk-postoffice-v2.png",
    "angkor_beng_mealea_roots": "siem-reap-23-beng-mealea-roots-postoffice-v2.png",
    "angkor_preah_ko": "siem-reap-24-preah-ko-front-postoffice-v2.png",
    "angkor_preah_ko_bulls": "siem-reap-24-preah-ko-bulls-postoffice-v2.png",
    "angkor_bakong": "siem-reap-25-bakong-approach-postoffice-v2.png",
    "angkor_bakong_platform": "siem-reap-25-bakong-platform-postoffice-v2.png",
    "angkor_tonle_sap": "siem-reap-26-tonle-sap-village-postoffice-v4.png"
}

if __name__ == "__main__":
    for stop, filename in PAINTINGS.items():
        source = ROOT / "assets/game/scenes" / filename
        destination = ROOT / "assets/game/runtime" / f"tour-{stop}.jpg"
        with Image.open(source) as image:
            image.convert("RGB").resize((1600, 900), Image.Resampling.LANCZOS).save(
                destination, quality=91, optimize=True, progressive=True, subsampling=0
            )
        print(f"{destination.relative_to(ROOT)}: {destination.stat().st_size} bytes")

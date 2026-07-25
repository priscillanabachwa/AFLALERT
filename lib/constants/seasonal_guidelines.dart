import 'package:flutter/material.dart';

/// Stage of Uganda's bimodal maize calendar. The country gets two rainy
/// seasons a year (roughly Mar–Jul and Aug–Dec), so the cycle below repeats
/// twice within a single calendar year rather than mapping to the four
/// meteorological seasons.
enum SeasonStage { landPreparation, planting, growing, harvest, dryingStorage }

class SeasonalGuideline {
  final SeasonStage stage;
  final String seasonLabel;
  final String seasonLabelLg;
  final String title;
  final String titleLg;
  final String farmerAdvice;
  final String farmerAdviceLg;
  final String traderAdvice;
  final String traderAdviceLg;
  final IconData icon;

  const SeasonalGuideline({
    required this.stage,
    required this.seasonLabel,
    required this.seasonLabelLg,
    required this.title,
    required this.titleLg,
    required this.farmerAdvice,
    required this.farmerAdviceLg,
    required this.traderAdvice,
    required this.traderAdviceLg,
    required this.icon,
  });

  /// Season label in the language identified by [languageCode] ('en' or 'lg').
  String seasonLabelFor(String languageCode) =>
      languageCode == 'lg' ? seasonLabelLg : seasonLabel;

  /// Card title in the language identified by [languageCode] ('en' or 'lg').
  String titleFor(String languageCode) =>
      languageCode == 'lg' ? titleLg : title;
}

const List<SeasonalGuideline> _guidelines = [
  SeasonalGuideline(
    stage: SeasonStage.landPreparation,
    seasonLabel: 'Land Preparation',
    seasonLabelLg: 'Okutegeka Ettaka',
    title: 'Prepare your land',
    titleLg: 'Tegeka ettaka lyo',
    farmerAdvice:
        'Clear and plough your fields before the rains come. Remove old crop waste — mold can hide in it and spread to your next crop.',
    farmerAdviceLg:
        'Sanyaawo era olime ennimiro yo enkuba nga tennatonnya. Ggyawo ebisasiro by\'ebirime ebyakabaka — obukuku busobola okwekweka omwo ne busaasaanira ekirime kyo ekiddako.',
    traderAdvice:
        'Planting time is coming soon. Clear out and check your warehouse space before the next harvest arrives.',
    traderAdviceLg:
        'Ekiseera ky\'okusimba kinaatera okutuuka. Sanyaawo era okebere ebifo bya masitoowa lyo nga amakungula amaddako tegannatuuka.',
    icon: Icons.agriculture,
  ),
  SeasonalGuideline(
    stage: SeasonStage.planting,
    seasonLabel: 'Planting Season',
    seasonLabelLg: 'Ekiseera ky\'Okusimba',
    title: 'Time to plant',
    titleLg: 'Kiseera kya kusimba',
    farmerAdvice:
        'Plant once the rains are steady. Use good seed and space your plants well — crowded plants get stressed and are more likely to get moldy later.',
    farmerAdviceLg:
        'Simba enkuba bw\'emala okutuukirira obulungi. Kozesa ensigo ennungi era obawe ebifo ebimala — ebimera ebisibuganye biweddamu amaanyi ne byeyongera okukwatibwa obukuku oluvannyuma.',
    traderAdvice:
        'Farmers are planting now. This is a good time to plan supply deals and make sure you have enough drying and storage space ready.',
    traderAdviceLg:
        'Abalimi bali mu kusimba kati. Kino kye kiseera ekirungi okuteekateeka endagaano z\'okufuna emmere era n\'okukakasa nti olina ebifo ebimala eby\'okuyanjuluzaamu n\'okuterekamu.',
    icon: Icons.grass,
  ),
  SeasonalGuideline(
    stage: SeasonStage.growing,
    seasonLabel: 'Growing Season',
    seasonLabelLg: 'Ekiseera ky\'Okukula',
    title: 'Care for your crop',
    titleLg: 'Labirira ekimera kyo',
    farmerAdvice:
        'Weed your field and control pests right away. Insect damage and dry spells both make mold more likely later on.',
    farmerAdviceLg:
        'Sanyaawo omuddo mu nnimiro yo era oziyize ebiwuka amangu ago. Obwonoonefu obw\'ebiwuka n\'ebbanga ery\'ekyeya byombi biyongera okukwatibwa obukuku oluvannyuma.',
    traderAdvice:
        'Crops are still growing in the field. Use this quiet time to check your moisture meters and get storage bags and pallets ready.',
    traderAdviceLg:
        'Ebirime bikyakula mu nnimiro. Kozesa akaseera kano akatuufu okukebera obupima bwo obw\'obunnyogovu era oteeketeeke ensawo n\'embaawo ez\'okuterekamu.',
    icon: Icons.eco,
  ),
  SeasonalGuideline(
    stage: SeasonStage.harvest,
    seasonLabel: 'Harvest Season',
    seasonLabelLg: 'Ekiseera ky\'Amakungula',
    title: 'Harvest promptly',
    titleLg: 'Kungula mangu',
    farmerAdvice:
        'Harvest as soon as your crop is ready. Waiting too long is one of the biggest causes of mold. Do not leave wet cobs piled in the field overnight.',
    farmerAdviceLg:
        'Kungula amangu ekimera kyo bwe kimala okusaanira. Okulindirira ekiseera ekiwanvu y\'emu ku nsonga ennene ezireetera obukuku. Tolekanga bikonkome ebinyoze mu ntuumu mu nnimiro ekiro kyonna.',
    traderAdvice:
        'Harvest time has started. Test moisture and check for mold before you accept any batch. Do not mix a bad batch with your clean stock.',
    traderAdviceLg:
        'Ekiseera ky\'amakungula kitandiseewo. Pima obunnyogovu era okebere obukuku nga tonnakkiriza muganda gwonna. Tossanga muganda mubi n\'emmere yo endala ennungi.',
    icon: Icons.agriculture_outlined,
  ),
  SeasonalGuideline(
    stage: SeasonStage.dryingStorage,
    seasonLabel: 'Drying & Storage',
    seasonLabelLg: 'Okuyanjuluza n\'Okuterekera',
    title: 'Dry and store safely',
    titleLg: 'Yanjuluza era oterekere bulungi',
    farmerAdvice:
        'Dry your grain to below 13.5% moisture on a raised platform. Then store it in a cool, dry place with good airflow, off the ground.',
    farmerAdviceLg:
        'Yanjuluza emmere yo okutuuka ku bunnyogovu wansi wa 13.5% ku mbaawo eyimusiddwa. Oluvannyuma gyeterekere mu kifo ekinyogoga, ekikalu era ng\'empewo etambula bulungi, nga teri ku ttaka.',
    traderAdvice:
        'Keep stored batches off the floor with good airflow. Sell your oldest stock first, and check moisture again from time to time.',
    traderAdviceLg:
        'Kuuma emiganda gy\'oterese nga teri ku ttaka era ng\'empewo etambula bulungi. Sooka otunde emmere enkadde, era oddemu okupima obunnyogovu buli lwe kibeetaagisa.',
    icon: Icons.warehouse,
  ),
];

// Uganda's two rainy seasons drive a repeating five-stage cycle: land prep,
// planting, growing, harvest, then drying/storage before the next cycle
// begins. Season A runs roughly Feb–Jul, Season B roughly Aug–Jan.
const Map<int, SeasonStage> _monthToStage = {
  1: SeasonStage.dryingStorage,
  2: SeasonStage.landPreparation,
  3: SeasonStage.planting,
  4: SeasonStage.planting,
  5: SeasonStage.growing,
  6: SeasonStage.growing,
  7: SeasonStage.harvest,
  8: SeasonStage.dryingStorage,
  9: SeasonStage.landPreparation,
  10: SeasonStage.planting,
  11: SeasonStage.growing,
  12: SeasonStage.harvest,
};

SeasonalGuideline _guidelineForStage(SeasonStage stage) =>
    _guidelines.firstWhere((g) => g.stage == stage);

/// Trailing rainfall (mm) over [rainfallWindowDays] that counts as "the
/// rains have started" for a given spot. Below this, the ground is treated
/// as still dry even if the calendar says planting should be underway.
const double wetSeasonThresholdMm = 15.0;
const int rainfallWindowDays = 14;

/// Adjusts the calendar-based stage using observed rainfall, so the
/// guideline reflects what's actually happening on the ground for a given
/// year/location rather than a fixed date. Rains that arrive early bump
/// Land Preparation forward into Planting; rains that are late hold
/// Planting back at Land Preparation.
SeasonStage _resolveStage(int month, double? recentRainfallMm) {
  final SeasonStage calendarStage = _monthToStage[month]!;
  if (recentRainfallMm == null) return calendarStage;

  final bool rainsActive = recentRainfallMm >= wetSeasonThresholdMm;
  if (calendarStage == SeasonStage.landPreparation && rainsActive) {
    return SeasonStage.planting;
  }
  if (calendarStage == SeasonStage.planting && !rainsActive) {
    return SeasonStage.landPreparation;
  }
  return calendarStage;
}

/// Returns the guideline for the current month, corrected by
/// [recentRainfallMm] (trailing total over [rainfallWindowDays]) when
/// available. Falls back to the plain calendar when rainfall data is null,
/// e.g. because location/weather couldn't be fetched.
SeasonalGuideline currentSeasonalGuideline({DateTime? now, double? recentRainfallMm}) {
  final int month = (now ?? DateTime.now()).month;
  return _guidelineForStage(_resolveStage(month, recentRainfallMm));
}

/// Extra caution line for conditions the base guideline text doesn't
/// already cover: rain persisting into the harvest/drying window (grain
/// can't dry, high mold risk) or an unusually dry spell during growing
/// (drought stress raises aflatoxin risk in standing crops). [languageCode]
/// selects English vs Luganda text ('en' or 'lg').
String? weatherCautionFor(
  SeasonStage stage,
  double? recentRainfallMm,
  String languageCode,
) {
  if (recentRainfallMm == null) return null;
  final bool rainsActive = recentRainfallMm >= wetSeasonThresholdMm;
  final bool lg = languageCode == 'lg';

  if (rainsActive && (stage == SeasonStage.harvest || stage == SeasonStage.dryingStorage)) {
    return lg
        ? 'Enkuba ebadde etonnya mu kitundu kyo. Bikka emmere gy\'oyanjuluza era togirekayo ebweru — emmere ennyoze evunda mangu.'
        : 'It has been raining in your area. Cover your drying grain and do not leave it out — wet grain molds fast.';
  }
  if (!rainsActive && stage == SeasonStage.growing) {
    return lg
        ? 'Wabaddewo ekyeya mu kitundu kyo mu biseera bino. Weekesse ku kimera kyo okulaba obutayitiibwa okuva mu kubulwa amazzi — ekimera ekiweddemu amaanyi kisinga okukwatibwa obukuku.'
        : 'It has been dry in your area lately. Watch your crop for stress from lack of water — a stressed plant is more likely to get moldy.';
  }
  return null;
}

/// Picks the advice text for [userType] ("Farmer" or "Trader",
/// case-insensitive) from the given guideline, in the language identified by
/// [languageCode] ('en' or 'lg'). Defaults to farmer advice.
String seasonalAdviceFor(
  SeasonalGuideline guideline,
  String userType,
  String languageCode,
) {
  final bool lg = languageCode == 'lg';
  final bool isTrader = userType.trim().toLowerCase() == 'trader';
  if (isTrader) {
    return lg ? guideline.traderAdviceLg : guideline.traderAdvice;
  }
  return lg ? guideline.farmerAdviceLg : guideline.farmerAdvice;
}

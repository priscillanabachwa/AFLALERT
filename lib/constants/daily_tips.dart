/// Role-specific daily tips shown on the Home screen's "Daily Tip" card.
///
/// Tips rotate day-to-day (see [tipOfTheDay]) rather than always showing
/// the first entry, so returning users see fresh advice.
///
/// Each list has an English and a Luganda variant, kept the same length and
/// in the same order so the day-of-year index and the stage-overlap sets
/// below stay valid no matter which language is selected.
library;

import '../constants/seasonal_guidelines.dart' show SeasonStage;

const List<String> farmerDailyTipsEn = [
  'Keep corn moisture below 13.5%. Wet grain lets mold grow fast, and that mold is what makes aflatoxin.',
  'Dry maize on a raised platform, not on bare ground. Wet soil makes the grain damp again and mold grows.',
  'Harvest as soon as your crop is ready. Waiting too long leaves grain out in the weather, where mold can grow.',
  'Remove any moldy or discolored kernels before you store the grain. One bad kernel can spoil the whole batch.',
  'Store grain in a cool, dry place away from the sun. Heat and damp air are what let mold grow.',
  'Use airtight bags for storage. Keeping out moisture and pests is one of the best ways to stop mold.',
  'Check stored maize often for mold, insects, or heat. Finding problems early stops them from spreading.',
  'Change what you plant each season. This stops mold in the soil from building up and spreading to new crops.',
  'Try to protect your crop from drought and heat. A stressed plant is more likely to get moldy.',
  'Control insects in your field. Insect bites open the kernel, and mold can get in through the hole.',
  'Only shell maize once it is fully dry. Shelling wet cobs traps moisture inside, where mold can grow unseen.',
  'Clean storage containers and bags before each harvest. Old dirt can carry mold into your fresh grain.',
  'Keep stored grain off the floor on pallets. A damp floor is a common cause of mold in storage.',
  'Use a moisture meter instead of guessing. Grain can feel dry outside but still be wet enough for mold to grow.',
  'Weed your field on time. Weeds take water from your crop and make it weaker and more likely to get moldy.',
  'Do not leave freshly picked maize piled in the field overnight. Piled wet cobs heat up and start molding fast.',
  'Dry cobs in the sun with the husks opened. Trapped moisture inside closed husks is where mold often starts.',
  'Get a free AI scan before you sell. It finds mold you cannot see, so you protect your buyer and your name.',
];

const List<String> farmerDailyTipsLg = [
  'Kuuma obunnyogovu bw\'ekasooli wansi wa 13.5%. Emmere enyoze ekkiriza obukuku okukula mangu, era obwo bwe bukola Aflatoxin.',
  'Yanjuluza kasooli ku mbaawo eyimusiddwa waggulu, so si ku ttaka butereevu. Ettaka eritose lisobola okuddiza emmere obunnyogovu, obukuku ne bukula.',
  'Kungula amangu ekimera kyo bwe kimala okusaanira. Okulindirira ekiseera ekiwanvu kireka emmere mu budde obw\'ebweru, obukuku ne busobola okukula.',
  'Ggyawo ensigo zonna ezirimu obukuku oba ezikyusizza langi nga tonnaterekawo mmere. Ensigo emu embi esobola okwonoona omuganda gwonna.',
  'Terekera emmere mu kifo ekinyogoga, ekikalu, ewala n\'enjuba. Ebbugumu n\'empewo etose bye bikkiriza obukuku okukula.',
  'Kozesa nsawo eziziba obulungi mu kuterekamu. Okuziyiza obunnyogovu n\'ebiwuka y\'emu ku nkola ezisinga obulungi okuziyiza obukuku.',
  'Kebera kasooli gw\'oterese emirundi mingi okulaba obukuku, ebiwuka, oba ebbugumu. Okuzuula ebizibu mangu kiziyiza okusaasaana.',
  'Kyusa ky\'osimba buli kiseera ky\'okulima. Kino kiziyiza obukuku mu ttaka okwekuluumulukira ne busaasaanira ebimera ebiggya.',
  'Gezaako okukuuma ekimera kyo okuva mu kyeya n\'ebbugumu. Ekimera ekiweddemu amaanyi kisobola okwongera okukwatibwa obukuku.',
  'Ziyiza ebiwuka mu nnimiro yo. Ebiwuka bwe biluma ensigo, biggula obutundu obukuku mwe busobola okuyingirira.',
  'Kojjola kasooli nga wakamala okukala ddala. Okukojjola ebikonkome ebinyoze kisibira obunnyogovu munda, obukuku ne busobola okukula nga tobulabye.',
  'Yozaayoza ebibya n\'ensawo ez\'okuterekeramu nga tonnatandika makungula. Obucaafu obukadde busobola okuleeta obukuku mu mmere ya wamu empya.',
  'Kuuma emmere gy\'oterese nga teri ku ttaka, giteeke ku mbaawo. Ettaka eritose lye nsonga esinga okuleetera obukuku mu masitoowa.',
  'Kozesa akapima obunnyogovu mu kifo ky\'okulowoozaamu. Emmere esobola okuwulira ng\'ekaze ebweru naye ng\'ekyalimu obunnyogovu obumala okukuza obukuku.',
  'Sanyaawo omuddo mu nnimiro yo mu kiseera ekituufu. Omuddo gunyaga amazzi ku kimera kyo ne kifuuka ekinafu era ekisinga okukwatibwa obukuku.',
  'Tolekanga kasooli gwe wakakungudde mu ntuumu mu nnimiro ekiro kyonna. Ebikonkome ebinyoze bye bituumibwa bikaayana ne bitandika okukwatibwa obukuku mangu.',
  'Yanjuluza ebikonkome ku njuba nga ebikuta biggule. Obunnyogovu obusibiddwa mu bikuta ebiggale y\'ekifo obukuku we butera okutandikira.',
  'Funa okwekenneenya kwa AI nga tolina ky\'osasula nga tonnatunda. Kizuula obukuku bw\'otasobola kulaba, ne kikuuma omuguzi wo n\'erinnya lyo.',
];

const List<String> traderDailyTipsEn = [
  'Test moisture before you accept a batch. Grain above 13.5% moisture is likely to grow mold in storage.',
  'Check for bad color, bad smell, or insect holes before you buy. These are early signs of mold.',
  'Do not mix a suspect batch with clean stock. Mold spreads on contact and can spoil everything.',
  'Keep the warehouse dry with good airflow between bags. Trapped, damp air is what lets mold spread.',
  'Put bags on pallets, off the floor. A concrete floor holds moisture that soaks into the bottom bags.',
  'Sell your oldest stock first. Grain that sits in storage a long time has more time to grow mold.',
  'Ask for an AI scan or lab test on big or long-stored batches. Mold is not always easy to see.',
  'Buy from farmers who dry and store their grain well. Bad practice at the farm is the main cause of moldy grain.',
  'Treat your storage area for pests often. Pest damage on the grain lets mold get in.',
  'Keep transport trucks clean and dry. A damp truck can spoil grain that was dried well.',
  'Label and date every batch. This helps you sell older stock first, before it goes bad.',
  'Check moisture again during long storage, not just when the grain arrives. Grain can pick up moisture from damp air later.',
  'Separate any batch that fails inspection and test it again. This stops it from spoiling your clean stock.',
  'Do not stack grain right against warehouse walls. Water collects there and dampens the bags.',
  'Teach your suppliers how to dry grain properly. Grain that is already moldy cannot be fixed once it reaches you.',
  'Keep a record of scan results for each batch. This proves your grain is safe if a buyer ever asks.',
];

const List<String> traderDailyTipsLg = [
  'Pima obunnyogovu nga tonnakkiriza muganda gwa mmere. Emmere erina obunnyogovu obusukka 13.5% esobola okukwatibwa obukuku mu masitoowa.',
  'Kebera langi embi, akawoowo akabi, oba obutundu obw\'ebiwuka nga tonnagula. Bino bubonero bw\'olubereberye obw\'obukuku.',
  'Tossanga muganda gwa mmere gw\'obuusa n\'ogw\'obulungi. Obukuku busaasaana nga bukwatagana ne busobola okwonoona byonna.',
  'Kuuma masitoowa nga nkalu era nga empewo etambula bulungi wakati w\'ensawo. Empewo etose etasobola kutambula y\'ekkiriza obukuku okusaasaana.',
  'Teeka ensawo ku mbaawo, so si butereevu ku ttaka. Ettaka ery\'ekongikonkoni likuuma obunnyogovu obuyingira mu nsawo eziri wansi.',
  'Sooka otunde emmere ekadde okusinga endala. Emmere emala ekiseera ekiwanvu mu masitoowa erina omukisa omunene ogw\'okukwatibwa obukuku.',
  'Saba okwekenneenya kwa AI oba ekipimo kya laabo ku miganda emikulu oba egyamaze ekiseera nga giterese. Obukuku tebutera kwerabika mangu.',
  'Gula okuva mu balimi abayanjuluza era ne baterekera emmere yaabwe bulungi. Empisa embi ku lulimi lye nsonga ennene ey\'emmere okukwatibwa obukuku.',
  'Ddukanya ebiwuka mu kifo ky\'oterekera emirundi mingi. Obw\'ekyava ku biwuka ku mmere bukkiriza obukuku okuyingira.',
  'Kuuma emmotoka ez\'okusitulamu nga nnongoofu era nkalu. Emmotoka etose esobola okwonoona emmere eyayanjuluzibwa bulungi.',
  'Wandika akalulu n\'olunaku ku buli muganda gwa mmere. Kino kikuyamba okusooka okutunda emmere enkadde nga tennonooneka.',
  'Ddamu opime obunnyogovu ng\'emmere emaze ekiseera mu masitoowa, si ku lunaku lwe yatuuka lwokka. Emmere esobola okuddira obunnyogovu okuva mu mpewo etose oluvannyuma.',
  'Awulamu omuganda gwonna ogutayise mu kwekenneenya, ogupime nate. Kino kiziyiza okwonoona emmere yo endala ennungi.',
  'Totuuma mmere okumpi n\'ebisenge bya masitoowa. Amazzi geekuŋŋaanyiza awo ne gatosa ensawo.',
  'Yigiriza abakusindikira emmere engeri gy\'oyanjuluzaamu bulungi. Emmere eyakwatibwa obukuku tesobola kuddaabirizibwa bw\'etuuka gy\'oli.',
  'Kuuma endagiriro y\'ebiva mu kwekenneenya ku buli muganda. Kino kikakasa nti emmere yo ntuufu omuguzi bw\'abuuza.',
];

// Indices into the daily tip lists whose advice is already covered,
// near-verbatim, by that stage's seasonal guideline text (see
// seasonal_guidelines.dart). Excluded from rotation while that guideline is
// showing so the Daily Tip card never just repeats the Guidelines card.
const Map<SeasonStage, Set<int>> _farmerStageOverlap = {
  SeasonStage.landPreparation: {7},
  SeasonStage.planting: {},
  SeasonStage.growing: {8, 9, 14},
  SeasonStage.harvest: {2, 15},
  SeasonStage.dryingStorage: {0, 1, 4, 12},
};

const Map<SeasonStage, Set<int>> _traderStageOverlap = {
  SeasonStage.landPreparation: {},
  SeasonStage.planting: {},
  SeasonStage.growing: {},
  SeasonStage.harvest: {0, 2},
  SeasonStage.dryingStorage: {4, 5, 11},
};

/// Picks a tip for [userType] ("Farmer" or "Trader", case-insensitive) that
/// changes once per day. Defaults to the farmer list for unknown/empty types.
/// [languageCode] selects English vs Luganda text; the two lists share the
/// same length and order, so the rotation index is unaffected by language.
///
/// When [currentStage] is given, skips any tip that overlaps with that
/// stage's seasonal guideline advice, so the two cards don't repeat each
/// other on the same day.
String tipOfTheDay(
  String userType,
  String languageCode, {
  SeasonStage? currentStage,
}) {
  final bool isTrader = _isTrader(userType);
  final bool lg = languageCode == 'lg';
  final List<String> tips = isTrader
      ? (lg ? traderDailyTipsLg : traderDailyTipsEn)
      : (lg ? farmerDailyTipsLg : farmerDailyTipsEn);
  final Set<int> excluded = currentStage == null
      ? const {}
      : (isTrader ? _traderStageOverlap : _farmerStageOverlap)[currentStage] ??
            const {};

  final int dayIndex = _dayOfYear();
  for (int offset = 0; offset < tips.length; offset++) {
    final int i = (dayIndex + offset) % tips.length;
    if (!excluded.contains(i)) return tips[i];
  }
  return tips[dayIndex % tips.length];
}

// Aflatoxin-producing molds thrive fastest once ambient temperature climbs
// past this point, so it's used to trigger a heat-specific warning in place
// of the regular rotating tip.
const double highHeatThresholdC = 30.0;

const List<String> farmerHeatAlertTipsEn = [
  'It is very hot today. Check drying grain more often and keep it out of the sun once it is dry — heat helps mold grow.',
  'Hot weather makes damp grain mold faster. Move stored maize to the coolest, most shaded place you have.',
  'Hot weather stresses your growing crop, making it more likely to get moldy. Water it if you can and check on it often.',
];

const List<String> farmerHeatAlertTipsLg = [
  'Leero waliwo ebbugumu nnyingi. Kebera emmere gy\'oyanjuluza emirundi mingi, era ogiggye ku njuba bw\'emala okukala — ebbugumu buyamba obukuku okukula.',
  'Ebbugumu bulaza emmere entose okukwatibwa obukuku mangu. Sengula kasooli gw\'oterese ogutwale mu kifo ekisinga okunyogoga era ekiriko ekisiikirize.',
  'Ebbugumu buleetera ekimera kyo ekikula okuweddamu amaanyi, ne kyeyongera okukwatibwa obukuku. Kifukirire bw\'osobola era okikebere emirundi mingi.',
];

const List<String> traderHeatAlertTipsEn = [
  'It is very hot today. Check your stored batches more often for heat and dampness.',
  'Hot weather makes mold grow faster in warehouses. Improve airflow and keep bags out of the sun.',
  'Hot weather raises the risk of mold in your stock. Test your oldest or weakest batches first.',
];

const List<String> traderHeatAlertTipsLg = [
  'Leero waliwo ebbugumu nnyingi. Kebera emiganda gyo egy\'omu masitoowa emirundi mingi okulaba ebbugumu n\'obunnyogovu.',
  'Ebbugumu bulaza obukuku okukula mangu mu masitoowa. Longoosa empewo etambula era oteeke ensawo ewala n\'enjuba.',
  'Ebbugumu bwongera obulabe bw\'obukuku ku mmere yo. Sooka opime emiganda egikadde oba egisinga obunafu.',
];

/// True when [temperatureC] is hot enough to warrant a heat-risk warning
/// instead of the regular rotating tip.
bool isHeatAlert(double? temperatureC) =>
    temperatureC != null && temperatureC >= highHeatThresholdC;

// Ambient moisture is the more direct driver of aflatoxin risk — it's what
// keeps grain from drying out and lets mold spread — so relative humidity at
// or above this level triggers a humidity-specific warning in place of the
// regular rotating tip.
const double highHumidityPercentThreshold = 80.0;

const List<String> farmerHumidityAlertTipsEn = [
  'The air is very humid today. Damp air slows drying, so check drying grain more often and cover it if rain threatens.',
  'High humidity lets mold spread even in grain that felt dry. Check stored maize closely today.',
  'Humid air raises mold risk on standing crops too. Keep an eye out for early signs of disease in the field.',
];

const List<String> farmerHumidityAlertTipsLg = [
  'Leero empewo etose nnyo. Empewo etose ekozaanya okuyanjuluza, kale kebera emmere gy\'oyanjuluza emirundi mingi era ogibikke enkuba bw\'eba esuubirwa.',
  'Obunnyogovu bungi bukkiriza obukuku okusaasaana n\'okutuuka ne mu mmere eyawulikika ng\'ekaze. Kebera kasooli gw\'oterese n\'obwegendereza leero.',
  'Empewo etose yongera obulabe bw\'obukuku n\'ku bimera ebikyali mu nnimiro. Weekesse ku bubonero obw\'olubereberye obw\'endwadde mu nnimiro yo.',
];

const List<String> traderHumidityAlertTipsEn = [
  'The air is very humid today. Check your stored batches more closely — damp air lets mold spread fast.',
  'High humidity can undo good drying. Improve airflow in the warehouse and re-check moisture on older batches.',
  'Humid conditions raise mold risk across your stock. Prioritize testing batches that have been in storage longest.',
];

const List<String> traderHumidityAlertTipsLg = [
  'Leero empewo etose nnyo. Kebera emiganda gyo egy\'omu masitoowa n\'obwegendereza — empewo etose ekkiriza obukuku okusaasaana mangu.',
  'Obunnyogovu bungi busobola okuzikiriza okuyanjuluza okulungi. Longoosa empewo mu masitoowa era oddemu okupima obunnyogovu ku miganda emikadde.',
  'Embeera y\'obunnyogovu yongera obulabe bw\'obukuku ku mmere yo yonna. Sooka opime emiganda egimaze ekiseera ekiwanvu mu masitoowa.',
];

/// True when [humidityPercent] (relative humidity) is high enough to warrant
/// a moisture-risk warning instead of the regular rotating tip.
bool isHumidityAlert(double? humidityPercent) =>
    humidityPercent != null && humidityPercent >= highHumidityPercentThreshold;

/// Which weather-driven warning, if any, should replace the regular rotating
/// tip. Humidity takes priority over heat when both are in alert range,
/// since moisture — not temperature — is the more direct driver of
/// aflatoxin risk.
enum WeatherAlertKind { none, heat, humidity }

WeatherAlertKind alertKindFor(double? temperatureC, double? humidityPercent) {
  if (isHumidityAlert(humidityPercent)) return WeatherAlertKind.humidity;
  if (isHeatAlert(temperatureC)) return WeatherAlertKind.heat;
  return WeatherAlertKind.none;
}

/// Picks the tip to show for [userType] given the current [temperatureC] and
/// [humidityPercent], in the language identified by [languageCode] ('en' or
/// 'lg'). When conditions meaningfully raise aflatoxin risk, this returns a
/// weather-specific warning (see [alertKindFor] for how heat and humidity
/// are prioritized) instead of the normal rotating daily tip. Otherwise
/// forwards [currentStage] to [tipOfTheDay] so the rotating tip stays
/// distinct from the seasonal guideline currently on screen.
String tipForConditions(
  String userType,
  String languageCode,
  double? temperatureC, {
  double? humidityPercent,
  SeasonStage? currentStage,
}) {
  final bool isTrader = _isTrader(userType);
  final bool lg = languageCode == 'lg';
  switch (alertKindFor(temperatureC, humidityPercent)) {
    case WeatherAlertKind.humidity:
      final List<String> tips = isTrader
          ? (lg ? traderHumidityAlertTipsLg : traderHumidityAlertTipsEn)
          : (lg ? farmerHumidityAlertTipsLg : farmerHumidityAlertTipsEn);
      return tips[_dayOfYear() % tips.length];
    case WeatherAlertKind.heat:
      final List<String> tips = isTrader
          ? (lg ? traderHeatAlertTipsLg : traderHeatAlertTipsEn)
          : (lg ? farmerHeatAlertTipsLg : farmerHeatAlertTipsEn);
      return tips[_dayOfYear() % tips.length];
    case WeatherAlertKind.none:
      return tipOfTheDay(userType, languageCode, currentStage: currentStage);
  }
}

bool _isTrader(String userType) => userType.trim().toLowerCase() == 'trader';

int _dayOfYear() => DateTime.now().difference(DateTime(DateTime.now().year)).inDays;

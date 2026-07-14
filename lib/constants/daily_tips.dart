/// Role-specific daily tips shown on the Home screen's "Daily Tip" card.
///
/// Tips rotate day-to-day (see [tipOfTheDay]) rather than always showing
/// the first entry, so returning users see fresh advice.
library;

const List<String> farmerDailyTips = [
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

const List<String> traderDailyTips = [
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

/// Picks a tip for [userType] ("Farmer" or "Trader", case-insensitive) that
/// changes once per day. Defaults to the farmer list for unknown/empty types.
String tipOfTheDay(String userType) {
  final List<String> tips = _isTrader(userType) ? traderDailyTips : farmerDailyTips;
  return tips[_dayOfYear() % tips.length];
}

// Aflatoxin-producing molds thrive fastest once ambient temperature climbs
// past this point, so it's used to trigger a heat-specific warning in place
// of the regular rotating tip.
const double highHeatThresholdC = 30.0;

const List<String> farmerHeatAlertTips = [
  'It is very hot today. Check drying grain more often and keep it out of the sun once it is dry — heat helps mold grow.',
  'Hot weather makes damp grain mold faster. Move stored maize to the coolest, most shaded place you have.',
  'Hot weather stresses your growing crop, making it more likely to get moldy. Water it if you can and check on it often.',
];

const List<String> traderHeatAlertTips = [
  'It is very hot today. Check your stored batches more often for heat and dampness.',
  'Hot weather makes mold grow faster in warehouses. Improve airflow and keep bags out of the sun.',
  'Hot weather raises the risk of mold in your stock. Test your oldest or weakest batches first.',
];

/// True when [temperatureC] is hot enough to warrant a heat-risk warning
/// instead of the regular rotating tip.
bool isHeatAlert(double? temperatureC) =>
    temperatureC != null && temperatureC >= highHeatThresholdC;

/// Picks the tip to show for [userType] given the current [temperatureC].
/// When it's hot enough to meaningfully raise aflatoxin risk, this returns a
/// heat-specific warning instead of the normal rotating daily tip.
String tipForConditions(String userType, double? temperatureC) {
  if (!isHeatAlert(temperatureC)) return tipOfTheDay(userType);
  final List<String> tips = _isTrader(userType) ? traderHeatAlertTips : farmerHeatAlertTips;
  return tips[_dayOfYear() % tips.length];
}

bool _isTrader(String userType) => userType.trim().toLowerCase() == 'trader';

int _dayOfYear() => DateTime.now().difference(DateTime(DateTime.now().year)).inDays;

/// Role-specific daily tips shown on the Home screen's "Daily Tip" card.
///
/// Tips rotate day-to-day (see [tipOfTheDay]) rather than always showing
/// the first entry, so returning users see fresh advice.
library;

const List<String> farmerDailyTips = [
  'Keep corn moisture below 13.5% to prevent mold growth.',
  'Dry harvested maize on a raised platform, not directly on bare soil.',
  'Harvest promptly at maturity — delayed harvesting increases aflatoxin risk.',
  'Remove and discard visibly moldy or discolored kernels before storage.',
  'Store grain in a cool, dry, well-ventilated space away from direct sunlight.',
  'Use hermetic (airtight) bags to limit moisture and pest exposure during storage.',
  'Inspect stored maize regularly for signs of mold, insects, or heat buildup.',
  'Rotate crops each season to reduce fungal buildup in the soil.',
  'Avoid drought and heat stress where possible — stressed plants are more prone to aflatoxin.',
  'Control insect pests in the field; insect damage gives mold an entry point.',
  'Shell maize only once it is fully dry to avoid trapping moisture.',
  'Clean storage containers and bags thoroughly before each new harvest.',
  'Keep stored grain off the ground on pallets to avoid dampness from the floor.',
  'Use a moisture meter if available rather than guessing by feel.',
  'Practice timely weeding — weeds compete for water and increase plant stress.',
  'Avoid piling freshly harvested maize in the field overnight before drying.',
  'Sun-dry cobs with husks partly removed to speed up even drying.',
  'Get a free AI scan before selling to confirm your grain is safe.',
];

const List<String> traderDailyTips = [
  'Test moisture content before accepting a batch — reject anything above 13.5%.',
  'Inspect for discoloration, musty odor, or insect damage before purchase.',
  'Avoid mixing suspect batches with clean stock — contamination can spread.',
  'Keep warehouse humidity low and ensure adequate airflow between stacked bags.',
  'Use pallets to keep stored bags off the floor and away from moisture.',
  'Rotate stock (first in, first out) to avoid prolonged storage of older grain.',
  'Request an AI scan result or lab test for high-value or long-stored batches.',
  'Buy from farmers who dry and store grain properly — ask about their practices.',
  'Fumigate or treat storage areas regularly to prevent pest infestation.',
  'Keep transport vehicles clean and dry — damp trucks can spoil a good batch.',
  'Label and date batches so older stock is tracked and sold before it degrades.',
  'Re-check moisture levels periodically during long-term storage, not just at intake.',
  'Separate and quarantine any batch that fails inspection until it is retested.',
  'Avoid storing grain directly against warehouse walls, where condensation collects.',
  'Educate suppliers on proper drying — it protects your business as much as theirs.',
  'Keep records of scan results per batch to build trust with your buyers.',
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
  'Temperatures above 30°C raise aflatoxin risk — check drying grain more often and keep it out of direct sun once dry.',
  'Hot weather speeds up mold growth in damp grain — move stored maize to the coolest, most shaded space you have.',
  'High heat stresses standing crops, making them more vulnerable to aflatoxin — water where possible and monitor closely.',
];

const List<String> traderHeatAlertTips = [
  'Temperatures above 30°C raise spoilage risk — inspect stored batches more frequently for heat and moisture buildup.',
  'Hot weather accelerates mold growth in warehouses — improve airflow and keep bags out of direct sun.',
  'High heat increases aflatoxin risk in stock — prioritize testing older or borderline batches during hot spells.',
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

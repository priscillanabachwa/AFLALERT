/// Role-specific daily tips shown on the Home screen's "Daily Tip" card.
///
/// Tips rotate day-to-day (see [tipOfTheDay]) rather than always showing
/// the first entry, so returning users see fresh advice.
library;

const List<String> farmerDailyTips = [
  'Keep corn moisture below 13.5% — above that, the mold that produces aflatoxin grows fast.',
  'Dry harvested maize on a raised platform, not bare soil — ground moisture re-wets grain and invites mold.',
  'Harvest promptly at maturity — delayed harvesting leaves grain exposed to weather and mold for longer.',
  'Remove and discard visibly moldy or discolored kernels before storage — one bad kernel can contaminate the whole batch.',
  'Store grain in a cool, dry, ventilated space away from sunlight — heat and humidity are what let mold take hold.',
  'Use hermetic (airtight) bags for storage — sealing out moisture and pests is one of the most effective ways to stop mold forming.',
  'Inspect stored maize regularly for mold, insects, or heat buildup — catching problems early stops them spreading through the whole store.',
  'Rotate crops each season — this breaks the fungal buildup that lingers in soil and infects the next planting.',
  'Avoid drought and heat stress where possible — stressed plants are more vulnerable to the mold that causes aflatoxin.',
  'Control insect pests in the field — insect damage breaks the kernel\'s outer layer, giving mold a way in.',
  'Shell maize only once fully dry — shelling wet cobs traps moisture inside the kernels, where mold can grow unseen.',
  'Clean storage containers and bags before each new harvest — leftover residue can carry mold spores into fresh grain.',
  'Keep stored grain off the ground on pallets — floor dampness is a common, avoidable cause of mold in storage.',
  'Use a moisture meter rather than guessing by feel — grain can feel dry outside while still holding enough moisture for mold to grow.',
  'Practice timely weeding — weeds compete for water, stressing the plant and making it more prone to aflatoxin.',
  'Avoid piling freshly harvested maize in the field overnight — piled damp cobs heat up and start molding within hours.',
  'Sun-dry cobs with husks partly removed — trapped moisture inside unopened husks is where mold often starts.',
  'Get a free AI scan before selling — it catches contamination invisible to the eye, protecting your buyer and your reputation.',
];

const List<String> traderDailyTips = [
  'Test moisture content before accepting a batch — grain above 13.5% is at high risk of molding in storage.',
  'Inspect for discoloration, musty odor, or insect damage before purchase — these are the earliest visible signs of contamination.',
  'Avoid mixing suspect batches with clean stock — mold spreads on contact, so one bad batch can spoil a whole store.',
  'Keep warehouse humidity low with airflow between stacked bags — trapped humid air is exactly what lets mold spread through a stack.',
  'Use pallets to keep bags off the floor — concrete floors draw up moisture that soaks into the lowest bags.',
  'Rotate stock first-in, first-out — grain that sits in storage too long has more time to develop mold.',
  'Request an AI scan or lab test for high-value or long-stored batches — contamination often isn\'t visible until it has already spread.',
  'Buy from farmers who dry and store grain properly — poor practices at the farm are the root cause of most contaminated batches.',
  'Fumigate or treat storage areas regularly — pest damage on kernels opens the door for mold to take hold.',
  'Keep transport vehicles clean and dry — a damp truck can undo good drying and spoil an otherwise safe batch.',
  'Label and date batches so older stock is tracked and sold first — untracked grain is easy to accidentally store too long.',
  'Re-check moisture periodically during long storage — grain can pick up moisture from humid air even after passing intake testing.',
  'Separate and quarantine any batch that fails inspection — this stops one bad batch from cross-contaminating clean stock.',
  'Avoid storing grain against warehouse walls — condensation collects there, dampening bags from the outside in.',
  'Educate suppliers on proper drying — grain that arrives already contaminated can\'t be fixed once it\'s in your store.',
  'Keep records of scan results per batch — traceable proof of safety builds trust and protects you if quality is disputed later.',
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

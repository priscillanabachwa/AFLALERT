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
];

const List<String> traderDailyTips = [
  'Test moisture content before accepting a batch — reject anything above 13.5%.',
  'Inspect for discoloration, musty odor, or insect damage before purchase.',
  'Avoid mixing suspect batches with clean stock — contamination can spread.',
  'Keep warehouse humidity low and ensure adequate airflow between stacked bags.',
  'Use pallets to keep stored bags off the floor and away from moisture.',
  'Rotate stock (first in, first out) to avoid prolonged storage of older grain.',
  'Request an AI scan result or lab test for high-value or long-stored batches.',
];

/// Picks a tip for [userType] ("Farmer" or "Trader", case-insensitive) that
/// changes once per day. Defaults to the farmer list for unknown/empty types.
String tipOfTheDay(String userType) {
  final List<String> tips =
      userType.trim().toLowerCase() == 'trader' ? traderDailyTips : farmerDailyTips;
  final int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  return tips[dayOfYear % tips.length];
}

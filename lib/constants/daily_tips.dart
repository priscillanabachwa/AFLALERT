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
  final List<String> tips =
      userType.trim().toLowerCase() == 'trader' ? traderDailyTips : farmerDailyTips;
  final int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  return tips[dayOfYear % tips.length];
}

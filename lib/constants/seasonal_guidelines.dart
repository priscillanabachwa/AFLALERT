import 'package:flutter/material.dart';

/// Stage of Uganda's bimodal maize calendar. The country gets two rainy
/// seasons a year (roughly Mar–Jul and Aug–Dec), so the cycle below repeats
/// twice within a single calendar year rather than mapping to the four
/// meteorological seasons.
enum SeasonStage { landPreparation, planting, growing, harvest, dryingStorage }

class SeasonalGuideline {
  final SeasonStage stage;
  final String seasonLabel;
  final String title;
  final String farmerAdvice;
  final String traderAdvice;
  final IconData icon;

  const SeasonalGuideline({
    required this.stage,
    required this.seasonLabel,
    required this.title,
    required this.farmerAdvice,
    required this.traderAdvice,
    required this.icon,
  });
}

const List<SeasonalGuideline> _guidelines = [
  SeasonalGuideline(
    stage: SeasonStage.landPreparation,
    seasonLabel: 'Land Preparation',
    title: 'Prepare your land',
    farmerAdvice:
        'Clear and plough fields ahead of the rains. Remove old crop debris where mold can overwinter.',
    traderAdvice:
        'Planting season is approaching — clear out and inspect warehouse space ahead of the next harvest intake.',
    icon: Icons.agriculture,
  ),
  SeasonalGuideline(
    stage: SeasonStage.planting,
    seasonLabel: 'Planting Season',
    title: 'Time to plant',
    farmerAdvice:
        'Plant with the onset of reliable rains. Use certified, disease-resistant seed and proper spacing to reduce plant stress.',
    traderAdvice:
        'Farmers are planting now — a good time to line up supply agreements and confirm drying/storage capacity for the coming harvest.',
    icon: Icons.grass,
  ),
  SeasonalGuideline(
    stage: SeasonStage.growing,
    seasonLabel: 'Growing Season',
    title: 'Care for your crop',
    farmerAdvice:
        'Weed regularly and control pests promptly — insect damage and drought stress both raise aflatoxin risk later on.',
    traderAdvice:
        'Crops are still in the field. Use this quieter period to service moisture meters and prepare storage bags and pallets.',
    icon: Icons.eco,
  ),
  SeasonalGuideline(
    stage: SeasonStage.harvest,
    seasonLabel: 'Harvest Season',
    title: 'Harvest promptly',
    farmerAdvice:
        'Harvest as soon as crops mature — delayed harvesting is one of the biggest aflatoxin risks. Avoid piling wet cobs in the field overnight.',
    traderAdvice:
        'Harvest is underway — test moisture and inspect for mold before accepting any batch, and avoid mixing suspect grain with clean stock.',
    icon: Icons.agriculture_outlined,
  ),
  SeasonalGuideline(
    stage: SeasonStage.dryingStorage,
    seasonLabel: 'Drying & Storage',
    title: 'Dry and store safely',
    farmerAdvice:
        'Dry grain to below 13.5% moisture on a raised platform, then store in a cool, dry, well-ventilated space away from the ground.',
    traderAdvice:
        'Keep stored batches off the floor with good airflow, rotate stock first-in-first-out, and re-check moisture periodically during storage.',
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

/// Returns the guideline for the current calendar month.
SeasonalGuideline currentSeasonalGuideline({DateTime? now}) {
  final int month = (now ?? DateTime.now()).month;
  return _guidelineForStage(_monthToStage[month]!);
}

/// Picks the advice text for [userType] ("Farmer" or "Trader",
/// case-insensitive) from the given guideline. Defaults to farmer advice.
String seasonalAdviceFor(SeasonalGuideline guideline, String userType) {
  return userType.trim().toLowerCase() == 'trader'
      ? guideline.traderAdvice
      : guideline.farmerAdvice;
}

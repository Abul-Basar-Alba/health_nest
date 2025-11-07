class BabyDevelopmentModel {
  final int week;
  final String sizeComparisonEN; // "Size of a poppy seed"
  final String sizeComparisonBN; // "পপি বীজের সমান"
  final String lengthCm; // "0.2 cm"
  final String weightGrams; // "0.1 g"
  final List<String> developmentsEN; // Key developments in English
  final List<String> developmentsBN; // Key developments in Bangla
  final List<String> tipsEN; // Tips for mom in English
  final List<String> tipsBN; // Tips for mom in Bangla
  final List<String> symptomsEN; // Common symptoms in English
  final List<String> symptomsBN; // Common symptoms in Bangla

  BabyDevelopmentModel({
    required this.week,
    required this.sizeComparisonEN,
    required this.sizeComparisonBN,
    required this.lengthCm,
    required this.weightGrams,
    required this.developmentsEN,
    required this.developmentsBN,
    required this.tipsEN,
    required this.tipsBN,
    required this.symptomsEN,
    required this.symptomsBN,
  });

  // Get trimester (1, 2, or 3)
  int getTrimester() {
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  factory BabyDevelopmentModel.fromMap(Map<String, dynamic> map) {
    return BabyDevelopmentModel(
      week: map['week'] ?? 0,
      sizeComparisonEN: map['sizeComparisonEN'] ?? '',
      sizeComparisonBN: map['sizeComparisonBN'] ?? '',
      lengthCm: map['lengthCm'] ?? '',
      weightGrams: map['weightGrams'] ?? '',
      developmentsEN: List<String>.from(map['developmentsEN'] ?? []),
      developmentsBN: List<String>.from(map['developmentsBN'] ?? []),
      tipsEN: List<String>.from(map['tipsEN'] ?? []),
      tipsBN: List<String>.from(map['tipsBN'] ?? []),
      symptomsEN: List<String>.from(map['symptomsEN'] ?? []),
      symptomsBN: List<String>.from(map['symptomsBN'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'week': week,
      'sizeComparisonEN': sizeComparisonEN,
      'sizeComparisonBN': sizeComparisonBN,
      'lengthCm': lengthCm,
      'weightGrams': weightGrams,
      'developmentsEN': developmentsEN,
      'developmentsBN': developmentsBN,
      'tipsEN': tipsEN,
      'tipsBN': tipsBN,
      'symptomsEN': symptomsEN,
      'symptomsBN': symptomsBN,
    };
  }
}

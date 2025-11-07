class PregnancyCalculator {
  // Calculate due date from last menstrual period (LMP)
  // Standard: LMP + 280 days (40 weeks)
  static DateTime calculateDueDate(DateTime lastPeriodDate) {
    return lastPeriodDate.add(const Duration(days: 280));
  }

  // Calculate LMP from due date
  static DateTime calculateLMP(DateTime dueDate) {
    return dueDate.subtract(const Duration(days: 280));
  }

  // Calculate current pregnancy week from LMP
  static int calculateWeek(DateTime lastPeriodDate) {
    final daysSinceLMP = DateTime.now().difference(lastPeriodDate).inDays;
    return (daysSinceLMP / 7).floor() + 1;
  }

  // Calculate days remaining until due date
  static int calculateDaysRemaining(DateTime dueDate) {
    return dueDate.difference(DateTime.now()).inDays;
  }

  // Calculate weeks and days (e.g., "12 weeks, 3 days")
  static Map<String, int> calculateWeeksAndDays(DateTime lastPeriodDate) {
    final daysSinceLMP = DateTime.now().difference(lastPeriodDate).inDays;
    final weeks = daysSinceLMP ~/ 7;
    final days = daysSinceLMP % 7;

    return {
      'weeks': weeks,
      'days': days,
    };
  }

  // Format weeks and days for display (English)
  static String formatWeeksAndDaysEN(DateTime lastPeriodDate) {
    final data = calculateWeeksAndDays(lastPeriodDate);
    final weeks = data['weeks']!;
    final days = data['days']!;

    if (days == 0) {
      return '$weeks weeks';
    }
    return '$weeks weeks, $days days';
  }

  // Format weeks and days for display (Bangla)
  static String formatWeeksAndDaysBN(DateTime lastPeriodDate) {
    final data = calculateWeeksAndDays(lastPeriodDate);
    final weeks = data['weeks']!;
    final days = data['days']!;

    if (days == 0) {
      return '$weeks সপ্তাহ';
    }
    return '$weeks সপ্তাহ, $days দিন';
  }

  // Calculate trimester (1, 2, or 3)
  static int calculateTrimester(DateTime lastPeriodDate) {
    final week = calculateWeek(lastPeriodDate);
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  // Get trimester date ranges
  static Map<String, DateTime> getTrimesterDates(DateTime lastPeriodDate) {
    return {
      'firstTrimesterStart': lastPeriodDate,
      'firstTrimesterEnd': lastPeriodDate.add(const Duration(days: 84)),
      'secondTrimesterStart': lastPeriodDate.add(const Duration(days: 85)),
      'secondTrimesterEnd': lastPeriodDate.add(const Duration(days: 182)),
      'thirdTrimesterStart': lastPeriodDate.add(const Duration(days: 183)),
      'thirdTrimesterEnd': lastPeriodDate.add(const Duration(days: 280)),
    };
  }

  // Calculate conception date (approximately LMP + 14 days)
  static DateTime calculateConceptionDate(DateTime lastPeriodDate) {
    return lastPeriodDate.add(const Duration(days: 14));
  }

  // Check if pregnancy is overdue
  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  // Check if pregnancy is in early labor period (37+ weeks)
  static bool isFullTerm(DateTime lastPeriodDate) {
    final week = calculateWeek(lastPeriodDate);
    return week >= 37;
  }

  // Calculate percentage of pregnancy completed
  static double calculateProgressPercentage(
      DateTime lastPeriodDate, DateTime dueDate) {
    final totalDays = dueDate.difference(lastPeriodDate).inDays;
    final daysPassed = DateTime.now().difference(lastPeriodDate).inDays;
    return (daysPassed / totalDays * 100).clamp(0, 100);
  }

  // Get week-specific milestones
  static String getMilestoneEN(int week) {
    if (week <= 4) return 'Embryo implantation';
    if (week == 5) return 'Heart begins to beat';
    if (week == 8) return 'All major organs forming';
    if (week == 12) return 'First trimester complete';
    if (week == 16) return 'Gender may be visible';
    if (week == 20) return 'Halfway through!';
    if (week == 24) return 'Viable if born early';
    if (week == 28) return 'Third trimester begins';
    if (week == 32) return 'Baby gaining weight rapidly';
    if (week == 36) return 'Baby is full-term soon';
    if (week == 37) return 'Full-term pregnancy';
    if (week >= 40) return 'Due date reached';
    return 'Baby growing steadily';
  }

  // Get week-specific milestones in Bangla
  static String getMilestoneBN(int week) {
    if (week <= 4) return 'ভ্রূণ প্রতিস্থাপন';
    if (week == 5) return 'হৃদস্পন্দন শুরু';
    if (week == 8) return 'সকল অঙ্গ গঠন হচ্ছে';
    if (week == 12) return 'প্রথম ত্রৈমাসিক সম্পূর্ণ';
    if (week == 16) return 'লিঙ্গ সনাক্ত হতে পারে';
    if (week == 20) return 'অর্ধেক সম্পন্ন!';
    if (week == 24) return 'প্রাথমিক জন্মেও টিকতে পারে';
    if (week == 28) return 'তৃতীয় ত্রৈমাসিক শুরু';
    if (week == 32) return 'দ্রুত ওজন বৃদ্ধি';
    if (week == 36) return 'শীঘ্রই পূর্ণ মেয়াদ';
    if (week == 37) return 'পূর্ণ মেয়াদের গর্ভাবস্থা';
    if (week >= 40) return 'নির্ধারিত তারিখ';
    return 'শিশু স্থিরভাবে বৃদ্ধি পাচ্ছে';
  }
}

/// Utility for converting climbing grades between British and European systems.
///
/// Bouldering: Font (Fontainebleau / European) ↔ V Scale (international)
/// Rope:       UK Technical (British) ↔ French Sport (European)
class GradeConverter {
  GradeConverter._(); // prevent instantiation

  // ── Bouldering: Font ↔ V Scale ──────────────────────────────────────────

  static const _fontGrades = [
    'f2', 'f3', 'f4', 'f5', 'f5+',
    'f6a', 'f6a+', 'f6b', 'f6b+',
    'f6c', 'f6c+',
    'f7a', 'f7a+', 'f7b', 'f7b+',
    'f7c', 'f7c+',
    'f8a',
  ];

  static const _vGrades = [
    'VB', 'V0', 'V0+', 'V1', 'V2',
    'V3', 'V3+', 'V4', 'V4+',
    'V5', 'V5+',
    'V6', 'V7', 'V8', 'V8+',
    'V9', 'V10',
    'V11',
  ];

  // ── Rope: UK Technical ↔ French Sport ───────────────────────────────────
  // UK Tech grades can appear with sub-grades (4a, 4b, 4c) or simplified (3, 4, 5+).
  // We map both forms so seed-data values like "5+" still resolve.

  static const _ukTechGrades = [
    '3', '4', '4+', '5', '5+',
    '6a', '6a+', '6b', '6b+',
    '6c', '6c+',
    '7a', '7a+', '7b',
  ];

  static const _frenchSportGrades = [
    '3', '4+', '5', '5+', '6a',
    '6b', '6b+', '6c', '6c+',
    '7a', '7a+',
    '7b', '7b+', '7c',
  ];

  // ── Public API ──────────────────────────────────────────────────────────

  /// Returns the equivalent grade in the "other" system, or `null` if the
  /// grade is not found in the mapping table.
  ///
  /// • font   → V Scale
  /// • v_scale → Font
  /// • uk_tech → French Sport
  /// • french  → UK Technical
  static String? convertGrade(String grade, String gradeSystem) {
    final g = grade.toLowerCase().trim();
    switch (gradeSystem) {
      case 'font':
        final i = _fontGrades.indexOf(g);
        return i >= 0 ? _vGrades[i] : null;
      case 'v_scale':
        final i = _vGrades.indexWhere((v) => v.toLowerCase() == g);
        return i >= 0 ? _fontGrades[i] : null;
      case 'uk_tech':
        final i = _ukTechGrades.indexOf(g);
        return i >= 0 ? _frenchSportGrades[i] : null;
      case 'french':
        final i = _frenchSportGrades.indexOf(g);
        return i >= 0 ? _ukTechGrades[i] : null;
      default:
        return null;
    }
  }

  /// Formatted string showing both grade systems.
  ///
  /// Examples:
  ///   font    → "f6a (V3)"
  ///   v_scale → "V3 (f6a)"
  ///   uk_tech → "5+ (Fr 6a)"
  ///   french  → "6a (UK 5+)"
  static String dualGradeDisplay(String grade, String gradeSystem) {
    final converted = convertGrade(grade, gradeSystem);
    if (converted == null) return grade;

    switch (gradeSystem) {
      case 'font':
        return '$grade ($converted)';
      case 'v_scale':
        return '$grade ($converted)';
      case 'uk_tech':
        return '$grade (Fr $converted)';
      case 'french':
        return '$grade (UK $converted)';
      default:
        return grade;
    }
  }

  /// A numeric sort index that works across all grading systems.
  ///
  /// Bouldering grades: 0 – 17
  /// Rope grades:       100 – 113
  /// Unknown grades:    999
  static int sortIndex(String grade, String gradeSystem) {
    final g = grade.toLowerCase().trim();
    switch (gradeSystem) {
      case 'font':
        final i = _fontGrades.indexOf(g);
        return i >= 0 ? i : 999;
      case 'v_scale':
        final i = _vGrades.indexWhere((v) => v.toLowerCase() == g);
        return i >= 0 ? i : 999;
      case 'uk_tech':
        final i = _ukTechGrades.indexOf(g);
        return i >= 0 ? 100 + i : 999;
      case 'french':
        final i = _frenchSportGrades.indexOf(g);
        return i >= 0 ? 100 + i : 999;
      default:
        return 999;
    }
  }

  /// Human-readable label for a grade system key.
  static String systemLabel(String gradeSystem) {
    switch (gradeSystem) {
      case 'font':
        return 'Font';
      case 'v_scale':
        return 'V Scale';
      case 'uk_tech':
        return 'UK Tech';
      case 'french':
        return 'French';
      case 'yds':
        return 'YDS';
      default:
        return gradeSystem;
    }
  }

  /// Whether this grade system is for bouldering.
  static bool isBouldering(String gradeSystem) {
    return gradeSystem == 'font' || gradeSystem == 'v_scale';
  }
}

import 'package:flutter/material.dart';

/// The API sends category icons as Bootstrap Icon class names (e.g.
/// "bi-backpack2") rather than image URLs. Maps the common
/// education-related ones to a Material icon; unknown names fall back
/// to null so the caller can use a generic default.
IconData? bootstrapIconFor(String? name) {
  if (name == null) return null;
  final key = name.replaceFirst('bi-', '').trim();
  const map = {
    'backpack2': Icons.backpack_rounded,
    'backpack': Icons.backpack_rounded,
    'mortarboard': Icons.school_rounded,
    'mortarboard-fill': Icons.school_rounded,
    'stars': Icons.auto_awesome_rounded,
    'book': Icons.menu_book_rounded,
    'book-half': Icons.menu_book_rounded,
    'journal-bookmark': Icons.bookmark_rounded,
    'calculator': Icons.calculate_rounded,
    'calculator-fill': Icons.calculate_rounded,
    'flask': Icons.science_rounded,
    'globe': Icons.public_rounded,
    'globe2': Icons.public_rounded,
    'pencil': Icons.edit_rounded,
    'pencil-square': Icons.edit_rounded,
    'translate': Icons.translate_rounded,
    'atom': Icons.hub_rounded,
    'clipboard-data': Icons.assignment_rounded,
    'graph-up': Icons.trending_up_rounded,
    'palette': Icons.palette_rounded,
    'music-note': Icons.music_note_rounded,
    'code-slash': Icons.code_rounded,
    'laptop': Icons.laptop_mac_rounded,
  };
  return map[key];
}

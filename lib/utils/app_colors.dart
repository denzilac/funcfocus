// File: lib/utils/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // UPDATED: New "Rich Rainbow" palette with darker, vibrant colors for better contrast.
  static const Map<String, Color> _categoryColors = {
    // User requested colors with new, darker shades:
    'home': Color(0xFF1976D2),      // Rich Blue (Material Blue 700)
    'work': Color(0xFF6D4C41),      // Rich Brown (Material Brown 600)
    'project': Color(0xFFD32F2F),    // Rich Red (Material Red 700)
    'entertain': Color(0xFFEF6C00),  // Rich Orange (Material Orange 800)
    'gardening': Color(0xFF388E3C),  // Rich Green (Material Green 600)
    'health': Color(0xFF0097A7),      // Rich Cyan (Material Cyan 700)
    
    // Kept 'Chores' from the original list
    'chores': Color(0xFFFFA000),     // Rich Amber (Material Amber 700)

    // REMOVED: 'Focus' is no longer a category
  };

  // UPDATED: A darker default grey.
  static const Color defaultColor = Color(0xFF546E7A); // Rich Grey (Blue Grey 600)

  /// Gets the color for a given category.
  /// Returns a default grey if the category is not found.
  static Color get(String? category) {
    if (category == null) {
      return defaultColor;
    }
    return _categoryColors[category.toLowerCase()] ?? defaultColor;
  }
}
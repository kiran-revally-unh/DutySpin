import 'dart:math';

import 'package:flutter/material.dart';

String initials(String name) {
  final cleaned = name.trim();
  if (cleaned.isEmpty) return '?';
  final parts = cleaned.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  final first = parts.isNotEmpty ? parts.first[0] : '';
  final second = parts.length > 1
      ? parts.last[0]
      : (parts.first.length > 1 ? parts.first[1] : '');
  final two = ('$first$second').toUpperCase();
  return two.isEmpty ? '?' : two.substring(0, min(2, two.length));
}

const _chipColors = <Color>[
  Color(0xFFDCEBFF),
  Color(0xFFE6F9EE),
  Color(0xFFF3E8FF),
  Color(0xFFFFE8D6),
  Color(0xFFE5E7EB),
  Color(0xFFD1FAE5),
];

Color chipColor(String seed) {
  if (seed.isEmpty) return _chipColors.first;
  var hash = 0;
  for (final codeUnit in seed.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return _chipColors[hash % _chipColors.length];
}

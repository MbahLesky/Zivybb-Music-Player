import 'package:flutter/material.dart';

/// Computes the time-of-day-based [ThemeMode] for adaptive dark mode
/// (SRS F-3.4). Dark from 7pm to 6am, light otherwise.
ThemeMode adaptiveThemeModeFor(DateTime now) {
  final isNight = now.hour >= 19 || now.hour < 6;
  return isNight ? ThemeMode.dark : ThemeMode.light;
}

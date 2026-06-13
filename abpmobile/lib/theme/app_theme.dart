import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF111827);
  static const Color white = Color(0xFFFFFFFF);
  static const Color bgPage = Color(0xFFF9FAFB);
  static const Color border = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF059669);
  static const Color danger = Color(0xFFDC2626);
  static const Color badgeAdmin = Color(0xFFDBEAFE);
  static const Color badgeAdminText = Color(0xFF2563EB);
  static const Color badgeManager = Color(0xFFD1FAE5);
  static const Color badgeManagerText = Color(0xFF059669);

  static ThemeData get theme => ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          background: white,
        ),
        scaffoldBackgroundColor: white,
        appBarTheme: const AppBarTheme(
          backgroundColor: white,
          foregroundColor: textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: textSecondary),
        ),
        dividerColor: border,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgPage,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: textSecondary),
          ),
          labelStyle: TextStyle(color: textSecondary, fontSize: 14),
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: textSecondary),
        ),
      );
}

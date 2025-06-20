import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const COLOR_PRIMARY = Colors.deepOrangeAccent;
const COLOR_ACCENT = Colors.orange;
const COLOR_BACKGROUND_DARK = Color(0xFF171822);
const COLOR_BACKGROUND = Colors.white;
const COLOR_BACKGROUND_LIGHT = Color(0xFFF1F3F6);

const primaryColor = Color(0xFFFEECE7);

const backgroundColor = Color(0xFFFAFAFA);
const borderColor = Color(0xFFE9ECEE);
const textColor = Color(0xFF1C0802);
const greenColor = Color(0xFF5DD5AB);
const redColor = Color(0xFFFE46353);
const greyColor = Color(0xFFBFBFBF);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: COLOR_PRIMARY,
  cardColor: const Color(0xffF1F3F6),
  iconTheme: const IconThemeData(
    color: Color(0xFF3A4276),
  ),
  textTheme: TextTheme(
    labelLarge: GoogleFonts.inter(
      fontSize: 15,
      height: 1.6,
      color: const Color(0xff212330),
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 12,
      color: const Color(0xff1B1D28),
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(
      height: 1.6,
      fontSize: 12,
      color: const Color(0xff7b7f9e),
      fontWeight: FontWeight.w400,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 24,
      color: const Color(0xff171822),
      fontWeight: FontWeight.w600,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 22,
      color: const Color(0xff3A4276),
      fontWeight: FontWeight.w800,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 15,
      color: const Color(0xff3A4276),
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 22,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 18,
      color: Colors.black,
      fontWeight: FontWeight.w700,
    ),
  ),
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(secondary: COLOR_BACKGROUND_LIGHT)
      .copyWith(background: COLOR_BACKGROUND),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  iconTheme: const IconThemeData(
    color: Color(0xff7b7f9e),
  ),
  cardColor: const Color(0xFF212330),
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.inter(
      fontSize: 12,
      color: const Color(0xffffffff),
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.inter(
      height: 1.6,
      fontSize: 12,
      color: const Color(0xff7b7f9e),
      fontWeight: FontWeight.w400,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 15,
      height: 1.6,
      color: const Color(0xff212330),
      fontWeight: FontWeight.w600,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 24,
      color: const Color(0xFFFFFFFF),
      fontWeight: FontWeight.w600,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 22,
      color: const Color(0xFFFFFFFF),
      fontWeight: FontWeight.w800,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 15,
      color: const Color(0xff7b7f9e),
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 22,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 18,
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
  ),
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: COLOR_PRIMARY,
    onPrimary: Colors.white,
    secondary: COLOR_ACCENT,
    onSecondary: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    background: COLOR_BACKGROUND_DARK,
    onBackground: Colors.white,
    surface: Color(0xFF212330),
    onSurface: Colors.white,
  ),
);

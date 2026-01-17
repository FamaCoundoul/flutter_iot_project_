import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff3953bd),
      surfaceTint: Color(0xff3c55bf),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff546cd7),
      onPrimaryContainer: Color(0xfffffbff),
      secondary: Color(0xff5d3288),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff764ba2),
      onSecondaryContainer: Color(0xffead0ff),
      tertiary: Color(0xffb0223d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffd23d54),
      onTertiaryContainer: Color(0xfffffbff),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffbf8ff),
      onSurface: Color(0xff1a1b22),
      onSurfaceVariant: Color(0xff444653),
      outline: Color(0xff757684),
      outlineVariant: Color(0xffc5c5d5),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3037),
      inversePrimary: Color(0xffb9c3ff),
      primaryFixed: Color(0xffdde1ff),
      onPrimaryFixed: Color(0xff001356),
      primaryFixedDim: Color(0xffb9c3ff),
      onPrimaryFixedVariant: Color(0xff1f3ba6),
      secondaryFixed: Color(0xfff0dbff),
      onSecondaryFixed: Color(0xff2c0051),
      secondaryFixedDim: Color(0xffdcb8ff),
      onSecondaryFixedVariant: Color(0xff5c3187),
      tertiaryFixed: Color(0xffffdadb),
      onTertiaryFixed: Color(0xff40000d),
      tertiaryFixedDim: Color(0xffffb2b7),
      onTertiaryFixedVariant: Color(0xff91022a),
      surfaceDim: Color(0xffdad9e2),
      surfaceBright: Color(0xfffbf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f2fc),
      surfaceContainer: Color(0xffeeedf6),
      surfaceContainerHigh: Color(0xffe9e7f1),
      surfaceContainerHighest: Color(0xffe3e1eb),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff002896),
      surfaceTint: Color(0xff3c55bf),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff4c65cf),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff4a1e75),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff764ba2),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff72001f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc7354d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffbf8ff),
      onSurface: Color(0xff101117),
      onSurfaceVariant: Color(0xff343542),
      outline: Color(0xff50525f),
      outlineVariant: Color(0xff6b6c7a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3037),
      inversePrimary: Color(0xffb9c3ff),
      primaryFixed: Color(0xff4c65cf),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff314bb5),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff8459b1),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff6b4096),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xffc7354d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xffa51937),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc7c5cf),
      surfaceBright: Color(0xfffbf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f2fc),
      surfaceContainer: Color(0xffe9e7f1),
      surfaceContainerHigh: Color(0xffdddce5),
      surfaceContainerHighest: Color(0xffd2d0da),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00207e),
      surfaceTint: Color(0xff3c55bf),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff233ea9),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff40116a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5e348a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff5f0018),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff94072c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffbf8ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2a2b37),
      outlineVariant: Color(0xff474855),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3037),
      inversePrimary: Color(0xffb9c3ff),
      primaryFixed: Color(0xff233ea9),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00258e),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5e348a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff461a71),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff94072c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff6c001c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb9b8c1),
      surfaceBright: Color(0xfffbf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f0f9),
      surfaceContainer: Color(0xffe3e1eb),
      surfaceContainerHigh: Color(0xffd5d3dd),
      surfaceContainerHighest: Color(0xffc7c5cf),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb9c3ff),
      surfaceTint: Color(0xffb9c3ff),
      onPrimary: Color(0xff002388),
      primaryContainer: Color(0xff7189f6),
      onPrimaryContainer: Color(0xff00155d),
      secondary: Color(0xffdcb8ff),
      onSecondary: Color(0xff44176f),
      secondaryContainer: Color(0xff764ba2),
      onSecondaryContainer: Color(0xffead0ff),
      tertiary: Color(0xffffb2b7),
      onTertiary: Color(0xff67001b),
      tertiaryContainer: Color(0xfff8596e),
      onTertiaryContainer: Color(0xff570015),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff121319),
      onSurface: Color(0xffe3e1eb),
      onSurfaceVariant: Color(0xffc5c5d5),
      outline: Color(0xff8f909e),
      outlineVariant: Color(0xff444653),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e1eb),
      inversePrimary: Color(0xff3c55bf),
      primaryFixed: Color(0xffdde1ff),
      onPrimaryFixed: Color(0xff001356),
      primaryFixedDim: Color(0xffb9c3ff),
      onPrimaryFixedVariant: Color(0xff1f3ba6),
      secondaryFixed: Color(0xfff0dbff),
      onSecondaryFixed: Color(0xff2c0051),
      secondaryFixedDim: Color(0xffdcb8ff),
      onSecondaryFixedVariant: Color(0xff5c3187),
      tertiaryFixed: Color(0xffffdadb),
      onTertiaryFixed: Color(0xff40000d),
      tertiaryFixedDim: Color(0xffffb2b7),
      onTertiaryFixedVariant: Color(0xff91022a),
      surfaceDim: Color(0xff121319),
      surfaceBright: Color(0xff383940),
      surfaceContainerLowest: Color(0xff0d0e14),
      surfaceContainerLow: Color(0xff1a1b22),
      surfaceContainer: Color(0xff1e1f26),
      surfaceContainerHigh: Color(0xff292931),
      surfaceContainerHighest: Color(0xff34343c),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd5daff),
      surfaceTint: Color(0xffb9c3ff),
      onPrimary: Color(0xff001b6e),
      primaryContainer: Color(0xff7189f6),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffebd3ff),
      onSecondary: Color(0xff390664),
      secondaryContainer: Color(0xffaa7dd8),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd1d3),
      onTertiary: Color(0xff530014),
      tertiaryContainer: Color(0xfff8596e),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121319),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdbdbeb),
      outline: Color(0xffb0b1c0),
      outlineVariant: Color(0xff8e8f9e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e1eb),
      inversePrimary: Color(0xff213da7),
      primaryFixed: Color(0xffdde1ff),
      onPrimaryFixed: Color(0xff000b3d),
      primaryFixedDim: Color(0xffb9c3ff),
      onPrimaryFixedVariant: Color(0xff002896),
      secondaryFixed: Color(0xfff0dbff),
      onSecondaryFixed: Color(0xff1d0039),
      secondaryFixedDim: Color(0xffdcb8ff),
      onSecondaryFixedVariant: Color(0xff4a1e75),
      tertiaryFixed: Color(0xffffdadb),
      onTertiaryFixed: Color(0xff2d0007),
      tertiaryFixedDim: Color(0xffffb2b7),
      onTertiaryFixedVariant: Color(0xff72001f),
      surfaceDim: Color(0xff121319),
      surfaceBright: Color(0xff43444b),
      surfaceContainerLowest: Color(0xff06070d),
      surfaceContainerLow: Color(0xff1c1d24),
      surfaceContainer: Color(0xff27272e),
      surfaceContainerHigh: Color(0xff313239),
      surfaceContainerHighest: Color(0xff3c3d45),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffefefff),
      surfaceTint: Color(0xffb9c3ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffb3bfff),
      onPrimaryContainer: Color(0xff00062f),
      secondary: Color(0xfff9ebff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffdab3ff),
      onSecondaryContainer: Color(0xff15002c),
      tertiary: Color(0xffffeceb),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffffadb2),
      onTertiaryContainer: Color(0xff210004),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff121319),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffefefff),
      outlineVariant: Color(0xffc1c1d1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e1eb),
      inversePrimary: Color(0xff213da7),
      primaryFixed: Color(0xffdde1ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffb9c3ff),
      onPrimaryFixedVariant: Color(0xff000b3d),
      secondaryFixed: Color(0xfff0dbff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffdcb8ff),
      onSecondaryFixedVariant: Color(0xff1d0039),
      tertiaryFixed: Color(0xffffdadb),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffffb2b7),
      onTertiaryFixedVariant: Color(0xff2d0007),
      surfaceDim: Color(0xff121319),
      surfaceBright: Color(0xff4f4f57),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1e1f26),
      surfaceContainer: Color(0xff2f3037),
      surfaceContainerHigh: Color(0xff3a3b42),
      surfaceContainerHighest: Color(0xff46464e),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );

  /// Under-tertiary
  static const underTertiary = ExtendedColor(
    seed: Color(0xfff093fb),
    value: Color(0xffd4a0ff),
    light: ColorFamily(
      color: Color(0xff7849a0),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd4a0ff),
      onColorContainer: Color(0xff5f3086),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff7849a0),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd4a0ff),
      onColorContainer: Color(0xff5f3086),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff7849a0),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd4a0ff),
      onColorContainer: Color(0xff5f3086),
    ),
    dark: ColorFamily(
      color: Color(0xffe6c4ff),
      onColor: Color(0xff46156e),
      colorContainer: Color(0xffd4a0ff),
      onColorContainer: Color(0xff5f3086),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffe6c4ff),
      onColor: Color(0xff46156e),
      colorContainer: Color(0xffd4a0ff),
      onColorContainer: Color(0xff5f3086),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffe6c4ff),
      onColor: Color(0xff46156e),
      colorContainer: Color(0xffd4a0ff),
      onColorContainer: Color(0xff5f3086),
    ),
  );

  /// Succes-color
  static const succesColor = ExtendedColor(
    seed: Color(0xff4caf50),
    value: Color(0xff00b171),
    light: ColorFamily(
      color: Color(0xff006d43),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff00b171),
      onColorContainer: Color(0xff003b23),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff006d43),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff00b171),
      onColorContainer: Color(0xff003b23),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff006d43),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff00b171),
      onColorContainer: Color(0xff003b23),
    ),
    dark: ColorFamily(
      color: Color(0xff52df9a),
      onColor: Color(0xff003921),
      colorContainer: Color(0xff00b171),
      onColorContainer: Color(0xff003b23),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff52df9a),
      onColor: Color(0xff003921),
      colorContainer: Color(0xff00b171),
      onColorContainer: Color(0xff003b23),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff52df9a),
      onColor: Color(0xff003921),
      colorContainer: Color(0xff00b171),
      onColorContainer: Color(0xff003b23),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    underTertiary,
    succesColor,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

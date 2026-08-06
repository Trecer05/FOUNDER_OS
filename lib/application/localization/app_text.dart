import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SelectionRegistrar;

import '../settings/display_preferences.dart';
import 'app_localizer.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null;

  const AppText.rich(
    this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = null;

  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final String? semanticsIdentifier;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final ambientLocale = Localizations.maybeLocaleOf(context);
    final preferredCode = DisplayPreferences.instance.language == AppLanguage.en
        ? 'en'
        : 'ru';
    final resolvedLocale =
        locale ??
        (ambientLocale?.languageCode == preferredCode
            ? ambientLocale!
            : Locale(preferredCode));
    if (textSpan != null) {
      return Text.rich(
        _translateSpan(textSpan!, resolvedLocale),
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: resolvedLocale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel == null
            ? null
            : AppLocalizer.translate(semanticsLabel!, resolvedLocale),
        semanticsIdentifier: semanticsIdentifier,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }
    return Text(
      AppLocalizer.translate(data ?? '', resolvedLocale),
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: resolvedLocale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel == null
          ? null
          : AppLocalizer.translate(semanticsLabel!, resolvedLocale),
      semanticsIdentifier: semanticsIdentifier,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

class AppRichText extends StatelessWidget {
  const AppRichText({
    required this.text,
    super.key,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.selectionRegistrar,
    this.selectionColor,
  });

  final InlineSpan text;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final TextScaler textScaler;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final SelectionRegistrar? selectionRegistrar;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final ambientLocale = Localizations.maybeLocaleOf(context);
    final preferredCode = DisplayPreferences.instance.language == AppLanguage.en
        ? 'en'
        : 'ru';
    final resolvedLocale =
        locale ??
        (ambientLocale?.languageCode == preferredCode
            ? ambientLocale!
            : Locale(preferredCode));
    return RichText(
      text: _translateSpan(text, resolvedLocale),
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      locale: resolvedLocale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionRegistrar: selectionRegistrar,
      selectionColor: selectionColor,
    );
  }
}

InlineSpan _translateSpan(InlineSpan source, Locale locale) {
  if (source is TextSpan) {
    return TextSpan(
      text: source.text == null
          ? null
          : AppLocalizer.translate(source.text!, locale),
      children: source.children
          ?.map((child) => _translateSpan(child, locale))
          .toList(growable: false),
      style: source.style,
      recognizer: source.recognizer,
      mouseCursor: source.mouseCursor,
      onEnter: source.onEnter,
      onExit: source.onExit,
      semanticsLabel: source.semanticsLabel == null
          ? null
          : AppLocalizer.translate(source.semanticsLabel!, locale),
      semanticsIdentifier: source.semanticsIdentifier,
      locale: source.locale,
      spellOut: source.spellOut,
    );
  }
  if (source is WidgetSpan) {
    return WidgetSpan(
      child: source.child,
      alignment: source.alignment,
      baseline: source.baseline,
      style: source.style,
    );
  }
  return source;
}

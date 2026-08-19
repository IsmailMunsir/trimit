import 'package:simple_icons/simple_icons.dart';

/// A small local lookup of well-known subscription services, mapped to
/// their real brand icon glyph (via the simple_icons package, where
/// available) and official brand color. Fully offline — no internet call,
/// no image download.
class KnownService {
  final int colorValue;
  final dynamic iconData; // IconData from simple_icons

  const KnownService({required this.colorValue, required this.iconData});
}

final Map<String, KnownService> kKnownServices = {
  'netflix': KnownService(colorValue: 0xFFE50914, iconData: SimpleIcons.netflix),
  'spotify': KnownService(colorValue: 0xFF1DB954, iconData: SimpleIcons.spotify),
  'youtube': KnownService(colorValue: 0xFFFF0000, iconData: SimpleIcons.youtube),
  'youtube premium': KnownService(colorValue: 0xFFFF0000, iconData: SimpleIcons.youtube),
  'apple music': KnownService(colorValue: 0xFFFA243C, iconData: SimpleIcons.applemusic),
  'apple tv+': KnownService(colorValue: 0xFF000000, iconData: SimpleIcons.appletv),
  'apple arcade': KnownService(colorValue: 0xFF000000, iconData: SimpleIcons.applearcade),
  'apple news': KnownService(colorValue: 0xFF000000, iconData: SimpleIcons.applenews),
  'apple podcasts': KnownService(colorValue: 0xFF000000, iconData: SimpleIcons.applepodcasts),
  'whatsapp': KnownService(colorValue: 0xFF25D366, iconData: SimpleIcons.whatsapp),
  'hbo max': KnownService(colorValue: 0xFF9B30FF, iconData: SimpleIcons.hbomax),
  'max': KnownService(colorValue: 0xFF9B30FF, iconData: SimpleIcons.hbomax),
  'hbo': KnownService(colorValue: 0xFF9B30FF, iconData: SimpleIcons.hbo),
  'google one': KnownService(colorValue: 0xFF4285F4, iconData: SimpleIcons.google),
  'dropbox': KnownService(colorValue: 0xFF0061FF, iconData: SimpleIcons.dropbox),
  'notion': KnownService(colorValue: 0xFF000000, iconData: SimpleIcons.notion),
  'zoom': KnownService(colorValue: 0xFF2D8CFF, iconData: SimpleIcons.zoom),
  'audible': KnownService(colorValue: 0xFFFF9900, iconData: SimpleIcons.audible),
  'playstation plus': KnownService(colorValue: 0xFF003791, iconData: SimpleIcons.playstation),
};

/// Looks up a known service by name — case-insensitive, whitespace-trimmed,
/// exact match only (kept simple and predictable rather than fuzzy-matching).
KnownService? findKnownService(String name) {
  final key = name.trim().toLowerCase();
  return kKnownServices[key];
}
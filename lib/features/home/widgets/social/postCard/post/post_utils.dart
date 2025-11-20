import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

enum ReactionType { Like, Love, Haha, Wow, Sad, Angry }

extension ReactionTypeName on ReactionType {
  String get name {
    switch (this) {
      case ReactionType.Like:
        return "Like";
      case ReactionType.Love:
        return "Love";
      case ReactionType.Haha:
        return "Haha";
      case ReactionType.Wow:
        return "Wow";
      case ReactionType.Sad:
        return "Sad";
      case ReactionType.Angry:
        return "Angry";
    }
  }
}

int? reactionIndexFromName(String? name) {
  if (name == null) return null;
  for (int i = 0; i < ReactionType.values.length; i++) {
    if (ReactionType.values[i].name == name) return i;
  }
  return null;
}

Future<Color> getDominantColor(String url) async {
  try {
    final palette = await PaletteGenerator.fromImageProvider(
      NetworkImage(url),
      maximumColorCount: 20,
    );
    return palette.dominantColor?.color ?? Colors.grey;
  } catch (e) {
    return Colors.grey;
  }
}

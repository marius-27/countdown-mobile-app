import 'package:flutter/material.dart';

class EmojiSelector extends StatelessWidget {
  const EmojiSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const List<String> emojis = ['😀', '🎂', '✈️', '🎓', '❤️', '🎮'];

  final String? selected;

  /// Called with the tapped emoji, or null when the selected one is tapped
  /// again to clear the choice.
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final emoji in emojis)
          ChoiceChip(
            label: Text(emoji, style: const TextStyle(fontSize: 24)),
            selected: emoji == selected,
            showCheckmark: false,
            selectedColor: colorScheme.primaryContainer,
            onSelected: (isSelected) => onSelected(isSelected ? emoji : null),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nextcloud_cookbook_flutter/src/blocs/recipe/recipe_bloc.dart';
import 'package:nextcloud_cookbook_flutter/src/widget/input/integer_text_form_field.dart';

class DurationFormField extends StatefulWidget {
  final String title;
  final RecipeState state;
  final Duration duration;
  final void Function(Duration value) onChanged;

  const DurationFormField({
    super.key,
    required this.state,
    required this.duration,
    required this.onChanged,
    required this.title,
  });

  @override
  _DurationFormFieldState createState() => _DurationFormFieldState();
}

class _DurationFormFieldState extends State<DurationFormField> {
  late Duration currentDuration;
  late bool enabled;

  @override
  void initState() {
    currentDuration = widget.duration;
    enabled = widget.state.status != RecipeStatus.updateInProgress;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(translate('recipe.fields.time.hours')),
            ),
            SizedBox(
              width: 70,
              child: IntegerTextFormField(
                enabled: enabled,
                initialValue: widget.duration.inHours,
                decoration: InputDecoration(
                  hintText: translate('recipe.fields.time.hours'),
                ),
                onChanged: (value) {
                  currentDuration = _updateDuration(
                    currentDuration: currentDuration,
                    hours: value,
                  );
                  widget.onChanged(currentDuration);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0, left: 12.0),
              child: Text(translate('recipe.fields.time.minutes')),
            ),
            SizedBox(
              width: 50,
              child: IntegerTextFormField(
                enabled: enabled,
                initialValue: widget.duration.inMinutes % 60,
                maxValue: 60,
                decoration: InputDecoration(
                  hintText: translate('recipe.fields.time.minutes'),
                ),
                onChanged: (value) {
                  currentDuration = _updateDuration(
                    currentDuration: currentDuration,
                    minutes: value,
                  );
                  widget.onChanged(currentDuration);
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Duration _updateDuration({
    required Duration currentDuration,
    int? hours,
    int? minutes,
  }) {
    if (hours != null) {
      final int currentMinutes = currentDuration.inMinutes % 60;

      return Duration(hours: hours, minutes: currentMinutes);
    }

    if (minutes != null) {
      final int currentHours = currentDuration.inHours;

      return Duration(hours: currentHours, minutes: minutes);
    }

    return currentDuration;
  }
}

import 'package:example/src/common/localization/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart'
    show CountryPickerTheme;

/// {@template common_logo}
/// CommonLogo widget.
/// {@endtemplate}
class CommonLogo extends StatelessWidget {
  /// {@macro common_logo}
  const CommonLogo({this.size = 76, super.key}) : _useText = false;

  /// {@macro common_logo}
  const CommonLogo.text({this.size = 76, super.key}) : _useText = true;

  /// The diameter of the logo.
  final double size;

  /// Use text?
  final bool _useText;

  @override
  Widget build(BuildContext context) {
    final localization = ExampleLocalization.of(context);
    final pickerTheme = CountryPickerTheme.of(context);
    final theme = Theme.of(context);
    final logo = ClipOval(
      child: Image.asset(
        'assets/icons/icon-1024x1024.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
    final spacer = SizedBox(height: pickerTheme.padding);
    return _useText
        ? Column(
            children: <Widget>[
              logo,
              spacer,
              Text(
                localization.title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              spacer,
              Text(
                localization.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel,
                    context,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        : logo;
  }
}

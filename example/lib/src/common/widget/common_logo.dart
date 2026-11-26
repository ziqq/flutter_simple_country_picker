import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart'
    show CountryPickerTheme;
import 'package:material_ui/material_ui.dart';

/// {@template common_logo}
/// Displays the package icon with an optional localized introduction.
/// {@endtemplate}
class CommonLogo extends StatelessWidget {
  /// Displays the icon by itself.
  const CommonLogo({this.size = 76, super.key}) : _useText = false;

  /// Displays the icon followed by the localized title and description.
  const CommonLogo.text({this.size = 76, super.key}) : _useText = true;

  /// The diameter of the logo.
  final double size;

  /// Whether to include the localized labels below the icon.
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

import 'package:example/src/common/constant/constant.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// {@template common_logo}
/// CommonLogo widget.
/// {@endtemplate}
class CommonLogo extends StatelessWidget {
  /// {@macro common_logo}
  const CommonLogo({super.key}) : _useText = false;

  /// {@macro common_logo}
  const CommonLogo.text({super.key}) : _useText = true;

  /// Use text?
  final bool _useText;

  @override
  Widget build(BuildContext context) {
    final localization = ExampleLocalization.of(context);
    final theme = Theme.of(context);
    final logo = CircleAvatar(
      radius: 38,
      child: ClipOval(
        child: Image.asset(
          'assets/icons/icon-1024x1024.jpg',
          width: 100,
          height: 100,
        ),
      ),
    );
    return _useText
        ? Column(
            children: [
              logo,
              const SizedBox(height: kDefaultPadding),
              Text(
                localization.title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kDefaultPadding),
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

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get localeCode => 'es_ES';

  @override
  String get languageCode => 'es';

  @override
  String get language => 'Español';

  @override
  String get title => 'Preview';

  @override
  String get description => 'Verifique el código de país e ingrese su número de teléfono.';

  @override
  String get nextLable => 'Siguiente';

  @override
  String get passwordLable => 'Contraseña';

  @override
  String get submitButton => 'Continuar';
}

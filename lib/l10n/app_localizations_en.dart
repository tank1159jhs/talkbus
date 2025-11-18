// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profile_edit => 'Profile Edit';

  @override
  String get nickname_edit => 'Edit Nickname';

  @override
  String get nickname_edit_hint => 'Enter new nickname';

  @override
  String get profile_photo => 'Profile Photo';

  @override
  String get secret_photo => 'Secret Photo';

  @override
  String get upload_success => 'Upload successful';

  @override
  String get upload_fail => 'Upload failed';

  @override
  String get nickname_changed => 'Nickname changed';

  @override
  String get nickname_change_fail => 'Nickname change failed';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';
}

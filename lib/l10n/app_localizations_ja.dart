// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get profile_edit => 'プロフィール編集';

  @override
  String get nickname_edit => 'ニックネーム編集';

  @override
  String get nickname_edit_hint => '新しいニックネームを入力';

  @override
  String get profile_photo => 'プロフィール写真';

  @override
  String get secret_photo => '秘密写真';

  @override
  String get upload_success => 'アップロードしました';

  @override
  String get upload_fail => 'アップロード失敗';

  @override
  String get nickname_changed => 'ニックネームが変更されました';

  @override
  String get nickname_change_fail => 'ニックネーム変更失敗';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';
}

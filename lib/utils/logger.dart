import 'dart:developer' as developer;

import 'package:urven/data/configs/app_config.dart';

class Logger {
  // ignore: constant_identifier_names
  static const String NAME = 'OrgOptimize';

  static d(String tag, String msg) {
    if (AppConfigs.IS_DEBUG) {
      final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
      pattern.allMatches(msg).forEach((match) => developer
          .log('($tag) ${match.group(0)}', name: NAME));
    }
  }

  static e(String tag, String msg) {
    if (AppConfigs.IS_DEBUG) {
      developer.log(
        '($tag) $msg',
        name: NAME,
        error: msg,
      );
    }
  }
}

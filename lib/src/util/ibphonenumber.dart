import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

// TODO(ziqq): Maybe should make simple package to this library.
// Anton Ustinoff <a.a.ustinoff@gmail.com>, 18 March 2026

/// {@template region_info}
/// Region information for a phone number.
/// Including the region prefix, ISO code, and formatted phone number.
/// {@endtemplate}
@immutable
@experimental
class RegionInfo {
  /// {@macro region_info}
  const RegionInfo({
    required this.regionPrefix,
    required this.isoCode,
    required this.formattedPhoneNumber,
  });

  /// The region prefix, e.g. "US" for United States.
  final String? regionPrefix;

  /// The ISO code, e.g. "US" for United States.
  final String? isoCode;

  /// The formatted phone number, e.g. "+1 213 373 4253" for United States.
  final String? formattedPhoneNumber;

  @override
  String toString() =>
      'RegionInfo{regionPrefix: $regionPrefix, isoCode: $isoCode, formattedPhoneNumber: $formattedPhoneNumber}';
}

/// An enumiration of the different phone number formats that can be used with [PhoneNumberUtil.format].
@experimental
enum PhoneNumberFormat {
  /// E.164 format, e.g. +12133734253.
  e164,

  /// International format, e.g. +1 213 373 4253.
  international,

  /// National format, e.g. (213) 373-4253.
  national,

  /// RFC3966 format, e.g. tel:+1-213-373-4253;ext=1234.
  rfc3966,
}

/// An enumiration of the different phone number types
/// that can be returned by [PhoneNumberUtil.getNumberType].
@experimental
enum PhoneNumberType {
  /// Fixed line phone number, e.g. a landline.
  fixedLine,

  /// Mobile phone number, e.g. a cell phone.
  mobile,

  /// A phone number that can be used for both fixed line and mobile.
  fixedLineOrMobile,

  /// A toll free phone number, e.g. 1-800 numbers in the US.
  tollFree,

  /// A premium rate phone number, e.g. 1-900 numbers in the US.
  premiumRate,

  /// A shared cost phone number, where the cost is shared between the caller
  sharedCost,

  /// A VOIP phone number, e.g. a Skype number.
  voip,

  /// A personal number, e.g. a non-geographic number assigned to a person.
  personalNumber,

  /// A pager number, e.g. a number for a pager device.
  pager,

  /// A UAN (Universal Access Number), e.g. a number that can be used to reach
  uan,

  /// A voicemail number, e.g. a number that can be used to access voicemail.
  voicemail,

  /// An unknown phone number type.
  unknown,
}

/// {@template phone_number_util}
/// The utility class to
/// {@endtemplate}
@experimental
class PhoneNumberUtil {
  /// {@macro phone_number_util}
  const PhoneNumberUtil._();

  // TODO(ziqq): Realyze this channel in each platform's implementation
  // intro android, ios, web, etc.
  // Anton Ustinoff <a.a.ustinoff@gmail.com>, 18 March 2026
  static const MethodChannel _channel = MethodChannel(
    'ziqq.github.libphonenumber',
  );

  /// Check if a phone number is valid for a given ISO code.
  static Future<bool?> isValidPhoneNumber({
    required String phoneNumber,
    required String isoCode,
  }) async {
    try {
      final result = await _channel.invokeMethod('isValidPhoneNumber', {
        'phone_number': phoneNumber,
        'iso_code': isoCode,
      });
      if (result case bool isValid) {
        return isValid;
      } else {
        return null;
      }
    } on Object catch (_) {
      // Sometimes invalid phone numbers can cause exceptions, e.g. "+1"
      return false;
    }
  }

  /// Get the name of the phone number's region,
  /// e.g. "United States" for a US number.
  static Future<String?> getNameForNumber({
    required String phoneNumber,
    required String isoCode,
  }) async {
    final result = await _channel.invokeMethod('getNameForNumber', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
    if (result case String name when name.isNotEmpty) {
      return name;
    } else {
      return null;
    }
  }

  /// Get the normalized E.164 phone number.
  /// For example, if the input phone number is "(213) 373-4253"
  /// and the ISO code is "US", this will return "+12133734253".
  static Future<String?> normalizePhoneNumber({
    required String phoneNumber,
    required String isoCode,
  }) async {
    final result = await _channel.invokeMethod('normalizePhoneNumber', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
    if (result case String normalizedPhone when normalizedPhone.isNotEmpty) {
      return normalizedPhone;
    } else {
      return null;
    }
  }

  /// Return the region information for a phone number,
  /// including the region prefix, ISO code, and formatted phone number.
  static Future<RegionInfo> getRegionInfo({
    required String phoneNumber,
    required String isoCode,
  }) async {
    final result = await _channel.invokeMethod('getRegionInfo', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });

    if (result case Map<String, String> json) {
      return RegionInfo(
        regionPrefix: json['regionCode'],
        isoCode: json['isoCode'],
        formattedPhoneNumber: json['formattedPhoneNumber'],
      );
    } else {
      throw FormatException('Invalid response from getRegionInfo: $result');
    }
  }

  /// Return the type of a phone number,
  /// e.g. fixed line, mobile, toll free, etc.
  static Future<PhoneNumberType> getNumberType({
    required String phoneNumber,
    required String isoCode,
  }) async {
    final result = await _channel.invokeMethod('getNumberType', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
    if (result case int resultINT) {
      if (resultINT == -1) return PhoneNumberType.unknown;
      return PhoneNumberType.values[resultINT];
    } else {
      return PhoneNumberType.unknown;
    }
  }

  /// Get an example phone number for a given ISO code,
  /// formatted in the international format with the plus sign.
  static Future<String> getExampleNumber(String isoCode) async {
    final result = await _channel.invokeMethod('getExampleNumber', {
      'iso_code': isoCode,
    });
    if (result case Map<String, Object?> json) {
      return json['formattedPhoneNumber'].toString();
    } else {
      throw FormatException('Invalid response from getExampleNumber: $result');
    }
  }

  /// Format a phone number as you type it, according to the formatting rules
  /// of the specified ISO code's region.
  static Future<String?> formatAsYouType({
    required String phoneNumber,
    required String isoCode,
  }) async {
    final result = await _channel.invokeMethod('formatAsYouType', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
    });
    if (result case String formattedPhone when formattedPhone.isNotEmpty) {
      return formattedPhone;
    } else {
      return null;
    }
  }

  /// Formats a phone number in the specified format.
  static Future<String> format({
    required String phoneNumber,
    required String isoCode,
    required PhoneNumberFormat format,
    // If true, this removes the spaces between the digits in the number formats
    // that add them.
    bool removeSpacesBetweenDigits = true,
  }) async {
    final formatString = format.toString();
    if (formatString.isEmpty) return phoneNumber;

    final formattedPhoneNumber = await _channel.invokeMethod('format', {
      'phone_number': phoneNumber,
      'iso_code': isoCode,
      'format': formatString.substring(formatString.indexOf('.') + 1),
    });

    if (formattedPhoneNumber case String formattedPhone
        when formattedPhone.isNotEmpty) {
      if (removeSpacesBetweenDigits) {
        return formattedPhoneNumber.replaceAll(' ', '');
      } else {
        return formattedPhoneNumber;
      }
    } else {
      return phoneNumber;
    }
  }
}

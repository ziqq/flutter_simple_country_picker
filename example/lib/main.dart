import 'dart:async';

import 'package:example/src/common/initialization/initialization.dart'
    deferred as initialization;
import 'package:example/src/common/util/app_zone.dart';
import 'package:example/src/common/util/error_util.dart';
import 'package:example/src/common/widget/app.dart' deferred as app;
import 'package:example/src/common/widget/app_error.dart' deferred as app_error;
import 'package:example/src/preview/county_picker_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => appZone(
      () async {
        // Splash screen
        final initializationProgress =
            ValueNotifier<({int progress, String message})>(
                (progress: 0, message: ''));
        /* runApp(SplashScreen(progress: initializationProgress)); */
        await initialization.loadLibrary();
        initialization
            .$initializeApp(
              onProgress: (progress, message) => initializationProgress.value =
                  (progress: progress, message: message),
              onSuccess: (_) async {
                await app.loadLibrary();
                // CountyPhoneInputPreview();
                runApp(app.App(home: const CountryPickerPreview()));
              },
              onError: (error, stackTrace) async {
                await app_error.loadLibrary();
                runApp(app_error.AppError(error: error));
                ErrorUtil.logError(error, stackTrace).ignore();
              },
            )
            .ignore();
      },
    );

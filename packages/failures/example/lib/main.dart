import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:failures/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_logger/multi_logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart' hide SentryLogger;
// ignore: implementation_imports
import 'package:sentry_flutter/src/integrations/flutter_error_integration.dart';

import 'i18n/translations.g.dart';
import 'failures/location_failures.dart';

final dio = Dio();
final failureNotifier = ValueNotifier<Failure?>(null);

void main() async {
  initLogging();
  initFailures();

  SentryWidgetsFlutterBinding.ensureInitialized();

  await LocaleSettings.setLocaleRaw('en');

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://47fd742d23ef449e8b5dc0064c272d00@o72377.ingest.sentry.io/4504173096730624';
      options.debug = false;
      options.enableAppHangTracking = !kDebugMode;

      final onPlatformError = options
        .integrations
        .whereType<OnErrorIntegration>()
        .firstOrNull;

      final onFlutterError = options
        .integrations
        .whereType<FlutterErrorIntegration>()
        .firstOrNull;

      if (onPlatformError != null) {
        options.removeIntegration(onPlatformError);
      }
      if (onFlutterError != null) {
        options.removeIntegration(onFlutterError);
      }
    },

    appRunner: () {
      return runApp(MyApp());
    },
  );
}

void initLogging() {
  logger = MultiLogger(
    beforeLog: (event) {
      if (event.message is Failure) {
        final Failure failure = event.message;

        return event.copyWith(
          message: failure.description,
          error: failure,
          stackTrace: failure.stackTrace,
          extra: failure.extra,
        );
      }
      return event;
    },
    loggers: [
      ConsoleLogger(
        level: LogLevel.trace,
      ),
      SentryLogger(
        level: LogLevel.error,
      ),
    ]
  );

  FlutterError.onError = (details) {
    final failure = Failure.fromError(
      details.exception,
      stackTrace: details.stack,
    );
    failureNotifier.value = failure;
    logger.error(failure);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    final failure = Failure.fromError(
      error,
      stackTrace: stack,
    );
    failureNotifier.value = failure;
    logger.error(failure);

    return true;
  };
}

void initFailures() {
  failures.register<LocationFailure, LocationError>(
    create: LocationFailure.new,
    descriptor: LocationFailureDescriptor(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            bottom: false,
            child: page(context),
          ),
          floatingActionButton: FloatingActionButton.small(
            onPressed: () async {
              await LocaleSettings.setLocaleRaw(
                LocaleSettings.currentLocale.languageCode == 'en' ? 'el' : 'en',
              );
              setState(() => {});
            },
            child: Text(LocaleSettings.currentLocale.languageCode.toUpperCase()),
          ),
        ),
      ),
    );
  }

  Widget page(BuildContext context) {
    return  ValueListenableBuilder<Failure?>(
      valueListenable: failureNotifier,
      builder: (_, failure, __) => Container(
        padding: EdgeInsetsGeometry.only(top: 12.0, left: 20.0, right: 20.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12.0,
          children: [
            Text(
              'Throw exception of type:',
              style: TextStyle().copyWith(fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: [
                    _button(
                      context,
                      onPressed: () {
                        throw 'This is an instance of String';
                      },
                      title: 'String',
                    ),
                    _button(
                      context,
                      onPressed: () {
                        throw Exception('This is an instance of Exception');
                      },
                      title: 'Exception',
                    ),
                    _button(
                      context,
                      onPressed: () {
                        dio.get(
                          'https://www.production.stg.douleutaras.gr/api',
                          queryParameters: {
                            'param1': 'value1',
                          },
                        );
                      },
                      title: 'DioException',
                    ),
                    _button(
                      context,
                      onPressed: () {
                        [1, 2][3];
                      },
                      title: 'RangeError',
                    ),
                    _button(
                      context,
                      onPressed: () {
                        throw LocationFailure.placeNotFound();
                      },
                      title: 'LocationFailure',
                    ),
                  ],
                )
              ],
            ),
            if (failure != null) ...[
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  initialIndex: 0,
                  child: Scaffold(
                    appBar: AppBar(
                      toolbarHeight: 0.0,
                      bottom: const TabBar(
                        tabs: [
                          Tab(text: 'General'),
                          Tab(text: 'Stack'),
                          Tab(text: 'Extra'),
                        ],
                      ),
                    ),
                    body: TabBarView(
                      children: [
                        _descriptor(context, failure),
                        _stackTrace(context, failure),
                        _extra(context, failure),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _descriptor(
    BuildContext context,
    Failure failure,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          _keyValue(
            context,
            key: 'toString()',
            value: failure.toString(),
          ),
          if (failure.description != null) ...[
            _keyValue(
              context,
              key: 'description',
              value: failure.description!,
            ),
          ],
          if (failure.message != null) ...[
            _keyValue(
              context,
              key: 'message',
              value: failure.message!,
            ),
          ],
          if (failure.details != null) ...[
            _keyValue(
              context,
              key: 'details',
              value: failure.details!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _stackTrace(
    BuildContext context,
    Failure failure,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 10.0),
      child: Text(failure.stackTrace.original.toString())
    );
  }

  Widget _extra(
    BuildContext context,
    Failure failure,
  ) {
    if (failure.extra != null) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: failure.extra!.entries.map((entry) {
            return _keyValue(
              context,
              key: entry.key.toString(),
              value: entry.value.toString().trim(),
            );
          }).toList(),
        )
      );
    }

    return const SizedBox.shrink();
  }

  Widget _keyValue(
    BuildContext context, {
    required String key,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          key.toString(),
          style: TextStyle().copyWith(fontWeight: FontWeight.bold),
        ),
        Text(value.toString()),
      ],
    );
  }

  Widget _button(
    BuildContext context, {
    required String title,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 36.0,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}

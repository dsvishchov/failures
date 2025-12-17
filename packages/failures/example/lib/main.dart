import 'dart:developer';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:failures/failures.dart';
import 'package:flutter/material.dart';

import 'i18n/translations.g.dart';
import 'failures/location_failures.dart';

final dio = Dio();
final failureNotifier = ValueNotifier<Failure?>(null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleSettings.setLocaleRaw('en');

  failures.register<LocationError>(
    create: LocationFailure.new,
    descriptor: LocationFailureDescriptor(),
  );

  final flutterOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    failureNotifier.value = Failure.fromError(details.exception, details.stack);
    flutterOnError?.call(details);
  };

  final platformOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    failureNotifier.value = Failure.fromError(error, stack);
    platformOnError?.call(error, stack);
    return true;
  };

  runApp(MyApp());
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
    return Container(
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
                runSpacing: 4.0,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () {
                      throw 'This is an instance of String';
                    },
                    child: const Text('String'),
                  ),
                  FilledButton(
                    onPressed: () {
                      throw Exception('This is an instance of Exception');
                    },
                    child: const Text('Exception'),
                  ),
                  FilledButton(
                    onPressed: () {
                      dio.get('https://dart.dev1');
                    },
                    child: const Text('DioException'),
                  ),
                  FilledButton(
                    onPressed: () {
                      throw LocationError.locationUnavailble;
                    },
                    child: const Text('LocationError'),
                  ),
                  FilledButton(
                    onPressed: () {
                      throw LocationFailure.placeNotFound();
                    },
                    child: const Text('LocationFailure'),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 4.0),
          Expanded(
            child: ValueListenableBuilder<Failure?>(
              valueListenable: failureNotifier,
              builder: (_, failure, __) => Column(
                spacing: 8.0,
                children: [
                  if (failure?.message != null) ...[
                    Text(
                      failure!.message!,
                      style: TextStyle().copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (failure?.details != null) ...[
                    Text(
                      failure!.details!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (failure != null) ...[
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        FilledButton.tonal(
                          onPressed: () {
                            log(failure.stackTrace.toString());
                          },
                          child: const Text('Log Trace'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(failure.stackTrace.original.toString())
                      ),
                    )
                  ],
                ],
              )
            ),
          ),
        ],
      ),
    );
  }
}

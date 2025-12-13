import 'package:failures/failures.dart';
import 'package:flutter/material.dart';

import 'i18n/translations.g.dart';
import 'failures/location_failures.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleSettings.setLocaleRaw('en');

  failures.register<LocationFailure>(
    descriptor: LocationFailureDescriptor(),
  );

  runApp(const MyApp());
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
          body: page(context),
        ),
      ),
    );
  }

  Widget? page(BuildContext context) {
    final failure = LocationFailure.locationUnavailble();

    return Padding(
      padding: EdgeInsetsGeometry.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8.0,
        children: [
          if (failure.title != null) ...[
            Text(
              failure.title!,
              style: TextStyle().copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
          if (failure.message != null) ...[
            Text(
              failure.message!,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8.0),
          FilledButton(
            onPressed: () async {
              await LocaleSettings.setLocaleRaw(
                LocaleSettings.currentLocale.languageCode == 'en' ? 'el' : 'en',
              );
              setState(() => {});
            },
            child: Text(t.common.language.change),
          ),
        ],
      ),
    );
  }
}

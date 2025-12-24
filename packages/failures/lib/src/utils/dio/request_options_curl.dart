import 'dart:convert';

import 'package:dio/dio.dart';

extension RequestOptionsCurl on RequestOptions {
  String get curl {
    List<String> components = ['curl -i'];
    components.add('-X ${method}');

    headers.forEach((key, value) {
      components.add('-H "$key: $value"');
    });

    if (data != null) {
      final encodedData = jsonEncode(data).replaceAll('"', '\\"');
      components.add('-d "$encodedData"');
    }

    components.add('"${uri.toString()}"');

    return components.join(' ');
  }
}
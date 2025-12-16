import 'package:dio/dio.dart';

extension RequestOptionsCurl on RequestOptions {
  String get curl => 'curl -i';
}
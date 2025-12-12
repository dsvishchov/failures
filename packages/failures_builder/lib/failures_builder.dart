import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/failure_enum_generator.dart';

Builder failures(BuilderOptions options) {
  return SharedPartBuilder(
    [FailureEnumGenerator()],
    'failures',
  );
}
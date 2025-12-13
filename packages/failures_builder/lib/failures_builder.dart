import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/failures_generator.dart';

Builder failures(BuilderOptions options) {
  return SharedPartBuilder(
    [FailuresGenerator()],
    'failures',
  );
}
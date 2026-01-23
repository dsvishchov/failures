import 'package:meta/meta_meta.dart';

import '/src/failures/failure.dart';

/// An annotation used to specify that [Failure] subclass should be
/// generated and annotated enum used as error type.
@Target({TargetKind.enumType})
class AsFailure {
  const AsFailure({
    this.name,
    this.type = .exception,
  });

  final String? name;
  final FailureType type;
}

const asFailure = AsFailure();

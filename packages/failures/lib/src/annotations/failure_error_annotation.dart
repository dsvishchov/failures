import 'package:meta/meta_meta.dart';

/// An annotation used to specify that [Failure] subclass should be
/// generated and annotated enum used as error type.
@Target({TargetKind.enumType})
class FailureError {
  const FailureError({
    this.name,
  });

  final String? name;
}

const failureError = FailureError();

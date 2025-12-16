import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:failures/failures.dart';
import 'package:source_gen/source_gen.dart';

import 'failure_enum_generator.dart';

class FailuresGenerator extends GeneratorForAnnotation<FailureError> {
  @override
  String generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! EnumElement2) {
      _throwInvalidTargetError(element);
    }

    final generator = FailureEnumGenerator(
      definingEnum: element as EnumElement2,
      definingAnnotation: _getAnnotation(element),
    );

    return generator.generate();
  }

  FailureError _getAnnotation(Element2 element) {
    final annotation = const TypeChecker
      .typeNamed(FailureError)
      .firstAnnotationOf(element);

    final reader = ConstantReader(annotation);
    final name = reader.peek('name');

    return FailureError(
      name: name?.stringValue,
    );
  }

  void _throwInvalidTargetError(Element2 element) {
    throw InvalidGenerationSourceError(
      '@FailureError can only be applied to enumeration.',
      element: element,
    );
  }
}

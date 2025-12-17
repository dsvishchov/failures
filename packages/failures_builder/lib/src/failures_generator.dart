import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:failures/failures.dart';
import 'package:source_gen/source_gen.dart';

import 'failure_enum_generator.dart';

class FailuresGenerator extends GeneratorForAnnotation<FailureError> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! EnumElement) {
      _throwInvalidTargetError(element);
    }

    final generator = FailureEnumGenerator(
      definingEnum: element as EnumElement,
      definingAnnotation: _getAnnotation(element),
    );

    return generator.generate();
  }

  FailureError _getAnnotation(Element element) {
    final annotation = const TypeChecker
      .typeNamed(FailureError)
      .firstAnnotationOf(element);

    final reader = ConstantReader(annotation);
    final name = reader.peek('name');

    return FailureError(
      name: name?.stringValue,
    );
  }

  void _throwInvalidTargetError(Element element) {
    throw InvalidGenerationSourceError(
      '@FailureError can only be applied to enumeration.',
      element: element,
    );
  }
}

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
    final type = reader.peek('type');

    return FailureError(
      name: name?.stringValue,
      type: FailureType.values.firstWhere(
        (value) => type?.objectValue.getField('_name')?.toStringValue() == value.toString().split('.')[1],
        orElse: () => FailureType.exception,
      ),
    );
  }

  void _throwInvalidTargetError(Element element) {
    throw InvalidGenerationSourceError(
      '@FailureError can only be applied to enumeration.',
      element: element,
    );
  }
}

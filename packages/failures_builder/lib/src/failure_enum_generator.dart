import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:failures/failures.dart';
import 'package:source_gen/source_gen.dart';

class FailureEnumGenerator extends GeneratorForAnnotation<FailureEnum> {
  @override
  String generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! EnumElement2) {
      _throwInvalidTargetError(element);
    }

    final generator = _Generator(
      definingEnum: element as EnumElement2,
      definingAnnotation: _getAnnotation(element),
    );

    return generator.generate();
  }

  FailureEnum _getAnnotation(Element2 element) {
    final annotation = const TypeChecker
      .typeNamed(FailureEnum)
      .firstAnnotationOf(element);

    final reader = ConstantReader(annotation);
    final name = reader.peek('name');

    return FailureEnum(
      name: name?.stringValue,
    );
  }

  void _throwInvalidTargetError(Element2 element) {
    throw InvalidGenerationSourceError(
      '@EnumFailure can only be applied to enumeration.',
      element: element,
    );
  }
}


class _Generator {
  const _Generator({
    required this.definingEnum,
    required this.definingAnnotation,
  });

  final EnumElement2 definingEnum;
  final FailureEnum definingAnnotation;

  String generate() {
    String factoryConstructors = '';
    String subclasses = '';

    enumValuesNames.forEach((enumValueName) {
      final capitalizedEnumValueName = '${enumValueName[0].toUpperCase()}${enumValueName.substring(1)}';
      final subclassName = '$className$capitalizedEnumValueName';

      factoryConstructors += '''
        const factory $className.$enumValueName() = $subclassName;
      ''';

      subclasses += '''
        final class $subclassName extends $className {
          const $subclassName() : super($enumName.$enumValueName);
        }
      ''';
    });

    return '''
      sealed class $className extends Failure<$enumName> {
        const $className(super.error);

        $factoryConstructors
      }

      $subclasses
    ''';
  }

  String get enumName => definingEnum.firstFragment.name2!;

  List<String> get enumValuesNames
    => definingEnum.constants2.map((constant) => constant.firstFragment.name2!).toList();

  String get className {
    if (definingAnnotation.name != null) {
      return definingAnnotation.name!;
    }

    final enumPrefix = enumName.endsWith('Error')
      ? enumName.split('Error').first
      : enumName;

    return '${enumPrefix}Failure';
  }
}
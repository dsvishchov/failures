import 'package:analyzer/dart/element/element2.dart';
import 'package:failures/failures.dart';

class FailureEnumGenerator {
  const FailureEnumGenerator({
    required this.definingEnum,
    required this.definingAnnotation,
  });

  final EnumElement2 definingEnum;
  final MakeFailure definingAnnotation;

  String generate() => generateWithNamedConstructors();

  String generateWithNamedConstructors() {
    String namedConstructors = '';

    enumValuesNames.forEach((enumValueName) {
      namedConstructors += '''
        const $className.$enumValueName() : this._($enumName.$enumValueName);
      ''';
    });

    return '''
      class $className extends Failure<$enumName> {
        const $className._(super.error);

        $namedConstructors
      }
    ''';
  }

  String generateWithFactoryConstructors() {
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
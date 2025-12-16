import 'package:analyzer/dart/element/element2.dart';
import 'package:failures/failures.dart';

class FailureEnumGenerator {
  const FailureEnumGenerator({
    required this.definingEnum,
    required this.definingAnnotation,
  });

  final EnumElement2 definingEnum;
  final MakeFailure definingAnnotation;

  String generate() {
    String namedConstructors = '';
    String getters = '';

    enumValuesNames.forEach((name) {
      final capitalizedName = '${name[0].toUpperCase()}${name.substring(1)}';

      namedConstructors += '''
        const $className.$name([StackTrace? stackTrace])
          : this($enumName.$name, stackTrace);
      ''';

      getters += '''
        bool get is$capitalizedName => error == $enumName.$name;
      ''';
    });

    return '''
      class $className extends Failure<$enumName> {
        const $className(
          super.error,
          super.stackTrace,
        );

        $namedConstructors
        $getters
      }
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
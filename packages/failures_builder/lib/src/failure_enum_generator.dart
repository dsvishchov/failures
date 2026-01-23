import 'package:analyzer/dart/element/element.dart';
import 'package:failures/failures.dart';

class FailureEnumGenerator {
  const FailureEnumGenerator({
    required this.definingEnum,
    required this.definingAnnotation,
  });

  final EnumElement definingEnum;
  final AsFailure definingAnnotation;

  String generate() {
    String namedConstructors = '';
    String getters = '';

    for (final name in enumValuesNames) {
      final capitalizedName = '${name[0].toUpperCase()}${name.substring(1)}';

      namedConstructors += '''
        $className.$name({
          super.message,
          super.extra,
          super.underlyingError,
          super.stackTrace,
        }) : super(.$name);

      ''';

      getters += '''
        bool get is$capitalizedName => error == .$name;
      ''';
    }

    return '''
      class $className extends Failure<$enumName> {
        $className(
          super.error, {
          super.message,
          super.extra,
          super.underlyingError,
          super.stackTrace,
        });

        @override
        String get summary => '\$runtimeType (.\${error.name})';

        @override
        FailureType get type => .${definingAnnotation.type.name};

        $namedConstructors
        $getters
      }
    ''';
  }

  String get enumName => definingEnum.firstFragment.name!;

  List<String> get enumValuesNames
    => definingEnum.constants.map((constant) => constant.firstFragment.name!).toList();

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
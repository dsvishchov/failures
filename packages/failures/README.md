[failures] provides a unified way to deal with errors.

`Failure` is essentially a generic wrapper on an `error` which might happen for example
as a result of an exceptional situation during the program execution or be a logical
error happened within the business logic layer.

Each `Failure` type is defined by the error type it handles and provides an unified way
to describe the underlying error from the technical standpoint. Each failure has:
- `summary`: a short summary of the failure
- `message`: a message describing the error in more details, when necessary
- `type`: error type, either exception or logical
- `stackTrace`: a stack trace allowing to track down the error root cause
- `extra`: an arbitrary set of additional data which might be associated with the error

Each `Failure` type might have an associated `FailureDescriptor` which provides a way
to describe failure for the end user using two additional optional fields:
- `title`: typically a title in an error widget
- `description`: typically a text in an error widget

In the center of the stage there is a `Failures` class which allows to register specific
failure and error types they hanndle to automatically create corresponding failures based
on the error provided.

There are some built-in failure types provided, one of them being `GenericFailure` which
handles all errors not handled by the rest of failures registered.

Also there is a convenient way to generate a failure class from any enumeration just by
adding an annotation `@FailureError`. Then enumeration becomes an underlying error and
you get convenient named constructors, getters and default `summary` and `message`.

# How to use

## Install

To use [failures], simply add it to your `pubspec.yaml` file:

```console
dart pub add failures
```

To use code generation, you will need to add development dependecy for [failures_builder]
along with the common setup required to use [build_runner]:

```console
dart pub add dev:failures_builder
dart pub add dev:build_runner
```

## Subclass

In order to handle custom errors you need to subclass `Failure` and override methods
`summary`, `message` and `type`. The very minimalistic example would be:

```dart
import 'package:failures/failures.dart';

class LocationFailure extends Failure<LocationError> {
  LocationFailure(
    super.error, {
    super.extra,
    super.stackTrace,
  });

  @override
  String get summary => error.name;

  @override
  String? get message => error.message;

  @override
  FailureType get type => .logical;
}
```

## Provide descriptor

This step is optional and only required if you want to notify users about errors
using additional more user-friendly, probably also localized, texts.

```dart
final class LocationFailureDescriptor implements FailureDescriptor<LocationFailure> {
  @override
  String? title(LocationFailure failure) {
    return switch (failure.error) {
      // Your titles here
    };
  }

  @override
  String? description(LocationFailure failure) {
    return switch (failure.error) {
      // Your descriptions here
    };
  }
}
```

## Register

Each failure type and corresponding error type need be registered explicitly:

```dart
import 'package:failures/failures.dart';

failures.register<LocationFailure, LocationError>(
  create: LocationFailure.new,
  descriptor: LocationFailureDescriptor(),
);
```

## Handle

There are two different scenarios to deal with:
- error is thrown using `throw` and not handled by try/catch block, i.e. it's an
unhandled error which __halts execution__ and will end up in an appropriate global
exception handler
- error is thrown but caught by the catch clause or it's not thrown at all, and just
created as a part of normal program execution flow, and in this case it needs to be
handled explicitly

First step you need to register a global failures handler, for example:

```dart
failures.onFailure = (failure) {
  if (failure.isException) {
    logger.error(failure);
  } else {
    logger.warning(failure);
  }
}
```

To deal with the first scenario it's recommended to override [FlutterError.onError]
and [PlatformDispatcher.instance.onError] like this:

```dart
FlutterError.onError = (details) {
  failures.handle(
    details.exception,
    details.stack,
  );
};

PlatformDispatcher.instance.onError = (error, stackTrace) {
  failures.handle(error, stackTrace);
  return true;
};
```

To deal with the second scenario you need to explicitly call the `handle` method:

```dart
final failure = ...
failures.handle(failure);
```

Also a typical scenario is to catch and handle all errors in local try/catch block:

```dart
try {
  ...
} catch (error, stackTrace) {
  failures.handle(error, stackTrace);
}
```

Now all errors will end up in a single place where you can log them, show in a nicely
widget to the user etc. Enjoy!

## Code generation

There is a handy way to convert any enum to be an error of a Failure subclass by annotating
corresponding enum with `AsFailure()` annotation and running code generation:

```dart
@AsFailure(type: .logical)
enum LocationError {
  placeNotFound,
  locationUnavailble,
}
```

The above code will generate a class `LocationFailure` with error type `LocationError` with
convenient named constructors and getters provided, so you can use it as:

```dart
final failure = LocationFailure.placeNotFound();
```
```dart
if (failure.isPlaceNotFound) { ... }
```

[failures]: https://pub.dartlang.org/packages/failures
[failures_builder]: https://pub.dartlang.org/packages/failures_builder
[build_runner]: https://pub.dev/packages/build_runner

import 'package:failures/failures.dart';

import '/i18n/translations.g.dart';

part 'location_failures.g.dart';

@MakeFailure(name: 'LocationFailure')
enum LocationError {
  placeNotFound,
  locationUnavailble,
}

final class LocationFailureDescriptor with FailureDescriptor<LocationFailure> {
  @override
  String? title(LocationFailure failure) {
    return switch (failure.error) {
      LocationError.placeNotFound
        => t.common.failures.location.placeNotFound.title,
      LocationError.locationUnavailble
        => t.common.failures.location.locationUnavailable.title,
    };
  }

  @override
  String? message(LocationFailure failure) {
    return switch (failure.error) {
      LocationError.placeNotFound
        => t.common.failures.location.placeNotFound.message,
      LocationError.locationUnavailble
        => t.common.failures.location.locationUnavailable.message,
    };
  }
}
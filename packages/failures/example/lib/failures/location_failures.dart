import 'package:failures/failures.dart';

import '/i18n/translations.g.dart';

part 'location_failures.g.dart';

@FailureError()
enum LocationError {
  placeNotFound,
  locationUnavailble,
}

final class LocationFailureDescriptor implements FailureDescriptor<LocationFailure> {
  @override
  String? message(LocationFailure failure) {
    return switch (failure.error) {
      LocationError.placeNotFound
        => t.common.failures.location.placeNotFound.message,
      LocationError.locationUnavailble
        => t.common.failures.location.locationUnavailable.message,
    };
  }

  @override
  String? details(LocationFailure failure) {
    return switch (failure.error) {
      LocationError.placeNotFound
        => t.common.failures.location.placeNotFound.details,
      LocationError.locationUnavailble
        => t.common.failures.location.locationUnavailable.details,
    };
  }
}
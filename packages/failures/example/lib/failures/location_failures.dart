import 'package:failures/failures.dart';

import '/i18n/translations.g.dart';

part 'location_failures.g.dart';

@AsFailure(type: .logical)
enum LocationError {
  placeNotFound,
  locationUnavailble,
}

final class LocationFailureDescriptor implements FailureDescriptor<LocationFailure> {
  @override
  String? title(LocationFailure failure) {
    return switch (failure.error) {
      .placeNotFound
        => t.common.failures.location.placeNotFound.title,
      .locationUnavailble
        => t.common.failures.location.locationUnavailable.title,
    };
  }

  @override
  String? description(LocationFailure failure) {
    return switch (failure.error) {
      .placeNotFound
        => t.common.failures.location.placeNotFound.description,
      .locationUnavailble
        => t.common.failures.location.locationUnavailable.description,
    };
  }
}
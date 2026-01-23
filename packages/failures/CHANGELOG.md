## 0.0.11

- Remove runtime types from default summaries
- Fix issue with stack trace not being preseved when failure is handled

## 0.0.10

- Rename @FailureError annotation to @AsFailure
- Add info about code generation to README

## 0.0.9

- Allow failures.handle to handle both failures and errors

## 0.0.8

- More robust type checking when creating failure from error
- Add support for passing underlying error when creating a failure

## 0.0.7

- Make title and description getters optional in descriptor
- Adjust generator to use named constructors instead of redirecting

## 0.0.6

- Add stack trace to enum generated failures

## 0.0.5

- Show full URL in DioFailure if base URL is not set, otherwise show only path

## 0.0.4

- Allow passing custom messages to failures
- Allow passing message and extra to enum generated failures

## 0.0.1

- Initial release
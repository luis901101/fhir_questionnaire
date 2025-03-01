The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Types of changes
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

## 4.0.0
### Changed
- **Breaking Change**: `onGenerateItemResponse` callback changed to also provide the generated `QuestionnaireResponseItem` as an argument of this callback. This way when this callback is being implemented it is also possible to just modify the `QuestionnaireResponseItem` and return it. Thanks [easazade](https://github.com/easazade) [PR-12](https://github.com/luis901101/fhir_questionnaire/pull/12)
- **Breaking Change**: `onBuildItemBundle` changed to `onBuildItemView` since almost always it is just desired an item view to be customized for a type of `questionnaireItem`. Thanks [easazade](https://github.com/easazade) [PR-12](https://github.com/luis901101/fhir_questionnaire/pull/12)
 
### Fixed
- Fixed rendering nested questionnaire items. Thanks [easazade](https://github.com/easazade) [PR-12](https://github.com/luis901101/fhir_questionnaire/pull/12)
- Fixes the enableWhen not working when the enable.question was not in the same group. Thanks [easazade](https://github.com/easazade) [PR-12](https://github.com/luis901101/fhir_questionnaire/pull/12)
- Fix enable-when not working when target question is a checkbox. Thanks [easazade](https://github.com/easazade) [PR-13](https://github.com/luis901101/fhir_questionnaire/pull/13)
- Fix text field starting to validate input before user types anything. Thanks [easazade](https://github.com/easazade) [PR-14](https://github.com/luis901101/fhir_questionnaire/pull/14)
- Fixed UI bug on hidden components using `enableWhen` [ISSUE-16](https://github.com/luis901101/fhir_questionnaire/issues/16)
- Validation added to ensure an open answer manually added is unique in the list of available answer options.

## 3.0.0
### Added
- Added support for [Calculated Expression](http://hl7.org/fhir/uv/sdc/STU3/StructureDefinition-sdc-questionnaire-calculatedExpression.html). Thanks [tigloo](https://github.com/tigloo).
- Added `uid` on `QuestionnaireItemBundle`, functions for item builder override and response override and other improvements. Thanks [easazade](https://github.com/easazade).

## 2.0.0
### Added
- Added support for `group` item type.
- Added `QuestionnaireController? controller` as param to `QuestionnaireView` to allow control over how the items and response are generated for `QuestionnaireView`.

### Changed
- `QuestionnaireController` refactored to support extension and function override.

## 1.0.1
### Added
- `CodeableConcept` extension added to easily access title.

## 1.0.0
### Added
- First release
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Types of changes
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

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
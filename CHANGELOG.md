The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Types of changes
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

## 3.0.0
### Changed
- Updated `QuestionnaireDisplayItemView` to use `bodyMedium` text style instead of `titleMedium`.
- BREAKING: Updated FHIR dependencies to `^0.7.0` for compatibility with the latest FHIR R4 library.

### Fixed
- Fixed items with a `sdc-questionnaire-calculatedExpression` never being calculated when the item view already produced an answer, such as `boolean` items defaulting to `false`.
- Fixed calculated expressions resolving to a `FhirCode`, `FhirMarkdown`, `FhirId`, `FhirCanonical`, `FhirUrl`, `FhirPositiveInt`, `FhirUnsignedInt` or `FhirInstant` producing an invalid `answer.value[x]`.

## 2.0.1
### Fixed
- Fixed `buildSignatureExtension` to ensure `onBehalfOf` is null if it matches `whoSigns`.

## 2.0.0
### Added
- Added `subject`, `author`, `source`, `whoSigns` and `signsOnBehalfOf` `QuestionnairePerson` parameters to `QuestionnaireView`, plus the corresponding `subjectProvider`, `authorProvider`, `sourceProvider`, `whoSignsProvider` and `signsOnBehalfOfProvider` callbacks on `QuestionnaireController`. The generated `QuestionnaireResponse` now populates `subject`, `author` and `source` when provided.
- Added support for hand written signatures. When a `Questionnaire` declares the `questionnaire-signatureRequired` extension at root level or on an item (typically a `group`), a required `QuestionnaireSignatureView` is rendered: a tappable signature preview that opens a drawing pad dialog (powered by [hand_signature](https://pub.dev/packages/hand_signature)). Root level signatures are shown at the end of the form; item level signatures are shown together with the item content.
- The generated `QuestionnaireResponse` now embeds each drawn signature as a PNG in a `questionnaireresponse-signature` `valueSignature`, on the response for root level and on the matching item for item level, reusing the marker's `valueCodeableConcept.coding` as the `Signature.type`.
- Added the `QuestionnairePerson` model, `SignatureController` and the public, overridable `SignaturePadDialog`, plus `hasSignature` and `signatureTypeCoding` extensions on `Questionnaire` and `QuestionnaireItem`.
- Added a `FhirConstants` class centralizing the FHIR extension/coding URLs previously scattered as inline string literals.

## 1.0.1
### Fixed
- Fixed `QuestionnaireSingleChoiceItemView` to correctly match initial values against available options.
- Fixed `QuestionnaireMultiChoiceItemView` to correctly match initial values against available options.
- Fixed disabled state in `CustomDropDownButtonFormField`

## 1.0.0
- First release
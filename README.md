
# FHIR Questionnaire

A Flutter package for working with FHIR® Questionnaires. FHIR® is the registered trademark of HL7 and is used with the permission of HL7. Use of the FHIR trademark does not constitute endorsement of this product by HL7.

This package takes care building the UI of a **FHIR R4 Questionnaire**, handle behavior and validations and finally generates the **QuestionnaireResponse** from the user answers.

# Important
This package is now based on [fhir_plus](https://pub.dev/packages/fhir_plus) if you need a version based on [fhir_r4](https://pub.dev/packages/fhir_r4) from [fhirfli.dev](https://fhirfli.dev) use [fhir_questionnaire_r4](https://pub.dev/packages/fhir_questionnaire_r4)

## Supported Questionnaire Items
So far this package only supports [FHIR R4 Item Types](https://hl7.org/fhir/R4/valueset-item-type.html)
| Item | Supported |  
| ------ | ------ |  
| Group | :white_check_mark: |  
| Display | :white_check_mark: |  
| Question | :ballot_box_with_check: |  
| Boolean | :white_check_mark: |  
| Decimal | :white_check_mark: |  
| Integer | :white_check_mark: |  
| Date | :white_check_mark: |  
| DateTime | :white_check_mark: |  
| Time | :white_check_mark: |  
| String | :white_check_mark: |  
| Text | :white_check_mark: |  
| Url | :white_check_mark: |  
| Choice | :white_check_mark: |  
| OpenChoice | :white_check_mark: |  
| Attachment | :white_check_mark: |  
| Reference | :ballot_box_with_check: |  
| Quantity | :white_check_mark: |

## Supported extra features
1. [enableWhen](http://hl7.org/fhir/R4/questionnaire-definitions.html#Questionnaire.item.enableWhen) supported
2. [enableBehavior](http://hl7.org/fhir/R4/questionnaire-definitions.html#Questionnaire.item.enableBehavior) supported.
3. [Calculated Expression](http://hl7.org/fhir/uv/sdc/STU3/StructureDefinition-sdc-questionnaire-calculatedExpression.html) supported
4. Extension for [translation](http://hl7.org/fhir/R4/extension-translation.html) supported.
5. Extension for [questionnaire-hidden](http://hl7.org/fhir/R4/extension-questionnaire-hidden.html) supported.
6. Extension for [minLength](http://hl7.org/fhir/R4/extension-minlength.html) extension.
7. Extesion for [minValue](http://hl7.org/fhir/R4/extension-minvalue.html) extension.
8. Extesion for [maxValue](http://hl7.org/fhir/R4/extension-maxvalue.html) extension. 
9. Extesion for hint texts using [entryFormat](http://hl7.org/fhir/R4/extension-entryformat.html) extension.
10. Extension for helper text or helper button using [questionnaire-displayCategory](https://hl7.org/fhir/R4/extension-questionnaire-displaycategory.html) and [questionnaire-itemControl](https://hl7.org/fhir/R4/extension-questionnaire-itemcontrol.html) with the codes `help` and `flyover`.
11. Hand written signature capture via the [questionnaire-signatureRequired](http://hl7.org/fhir/R4/extension-questionnaire-signaturerequired.html) extension (root or item level), emitted in the response as a [questionnaireresponse-signature](http://hl7.org/fhir/R4/extension-questionnaireresponse-signature.html). See the [Signatures](#signatures) section.


## How to use
Just add a `QuestionnaireView` widget to your widget tree and you will have your Questionnaire UI.

```dart
QuestionnaireView(
    questionnaire: questionnaire, // A FHIR R4 Questionnaire instance
    onAttachmentLoaded: onAttachmentLoaded, // A callback to handle attachment loading (explained below) 
    locale: locale, // The specific locale for the Button and validation texts
    localizations: localizations, // To add support for extra localization 
    isLoading: loading, // Wether is some ongoing operation before loading the UI 
    onSubmit: onSubmit, // Callback to get the QuestionnaireResponse
    controller: controller, // The QuestionnaireController to use for item view and response generation.
    subject: patient, // QuestionnairePerson subject of the QuestionnaireResponse
    author: practitioner, // QuestionnairePerson author of the QuestionnaireResponse
    source: practitioner, // QuestionnairePerson who provided the answers
    whoSigns: practitioner, // QuestionnairePerson who signs the QuestionnaireResponse / signatures
    signsOnBehalfOf: patient, // QuestionnairePerson the response is signed on behalf of
)
```

## QuestionnaireView
1. **Questionnaire questionnaire:** `QuestionnaireView` requires an object of type **Questionnaire** this is the definition of the Questionnaire and will be used to build the Form UI and generate the Questions and Answers.
2. **Locale? locale**: Optionally you can specify the language like "es" or "en" or "fr", etc. you want to use for validation messages and Submit button, by default the system language will be used.
3. **List<QuestionnaireBaseLocalization>? localizations**: this is a list allows you to add extra language translations to the Questionnaire, currently the package supports only English and Spanish, so you can add other Languages, you just need to create a class for each new Language you want to support and extend **QuestionnaireBaseLocalization**.
4. **QuestionnaireBaseLocalization? defaultLocalization**: Indicates what should be the fallback localization if the specified language or the system language is not supported, by default English is the fallback.
5. **bool isLoading**: use this to indicate there is an ongoing operation, for instance if you need to make an API request to load your **Questionnaire** you can set `isLoading = true` so the `QuestionnaireView` will show a Shimmer loading effect view.
6. **Future<Attachment?> Function()? onAttachmentLoaded**: To make this package simpler and compatible with all Flutter supported platforms, the feature to load an attachment is delegated to the App, so you have to handle this logic by implementing this function and returning an [Attachment](https://hl7.org/fhir/R4/datatypes.html#attachment) instance according to FHIR.
7. **ValueChanged<QuestionnaireResponse> onSubmit**: This is the callback that will be triggered once the user taps on the Submit button, and you will get a `QuestionnaireResponse` instance ready with the answers covered, and with the `subject`, `author` and `source` already set if you provided them (see below). You can still set any extra data you consider necessary.
8. **QuestionnaireController? controller**: This is the controller to be used for items and response generation within the `QuestionnaireView`, the purpose of this controller here is to allow you to use an instance of an extension of `QuestionnaireController` so you can override the behavior and widgets.
9. **QuestionnairePerson? subject**: Optional [`QuestionnairePerson`](#signer-information-questionnaireperson) for the subject of the `QuestionnaireResponse` (e.g. the `Patient` the answers are about). When provided its `reference` is set on the generated `QuestionnaireResponse.subject`.
10. **QuestionnairePerson? author**: Optional person for the author of the `QuestionnaireResponse` (the person or device that received and recorded the answers). When provided its `reference` is set on `QuestionnaireResponse.author`.
11. **QuestionnairePerson? source**: Optional person for the individual who provided the information reflected in the answers. When provided its `reference` is set on `QuestionnaireResponse.source`.
12. **QuestionnairePerson? whoSigns**: Optional person who signs the `QuestionnaireResponse`. Its `reference` is used as `Signature.who`, and its `name`/`title` are shown beneath each signature pad.
13. **QuestionnairePerson? signsOnBehalfOf**: Optional person on behalf of which the `QuestionnaireResponse` is signed. Its `reference` is used as `Signature.onBehalfOf`.

> If you use your own `controller` instead of letting `QuestionnaireView` create one, the `subject`, `author`, `source`, `whoSigns` and `signsOnBehalfOf` properties are ignored; provide the corresponding `subjectProvider`, `authorProvider`, `sourceProvider`, `whoSignsProvider` and `signsOnBehalfOfProvider` callbacks to your `QuestionnaireController` instead.

## Signatures
This package can capture hand written signatures and embed them into the generated `QuestionnaireResponse`, powered by the [hand_signature](https://pub.dev/packages/hand_signature) package.

### Declaring a required signature
A signature is requested wherever a [`questionnaire-signatureRequired`](http://hl7.org/fhir/R4/extension-questionnaire-signaturerequired.html) extension is present, either at the **root** of the `Questionnaire` or on any **item** (typically a `group`). The extension's `valueCodeableConcept.coding` declares the kind of signature required and is reused verbatim as the `Signature.type` in the response.

```json
{
  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-signatureRequired",
  "valueCodeableConcept": {
    "coding": [
      {
        "system": "urn:iso-astm:E1762-95:2013",
        "code": "1.2.840.10065.1.12.1.7",
        "display": "Consent Signature"
      }
    ]
  }
}
```

A questionnaire may declare several signatures at once (root level plus one or more item level markers); each one is captured and validated independently. A signature declared this way is **always required** before the form can be submitted, regardless of the item's own `required` flag.

### Capturing the signature (UI)
For each signature marker a `QuestionnaireSignatureView` renders a tappable preview:
- Empty: a placeholder ("Tap to sign") inviting the user to sign.
- Tapping it opens a `SignaturePadDialog` with the actual drawing pad; the user draws and taps **Done** to commit or **Cancel** to discard. Drawing happens in a dialog so the pad's gesture is not stolen by the surrounding scrolling form.
- Once signed, the preview shows the drawn signature, with a button to clear it and sign again.

Placement depends on where the marker is declared:
- **Root level**: shown at the end of the form.
- **Group item**: shown inside the group's container, after the group's own items.
- **Non-group item**: shown together with the item's normal content.

### The generated response
On submit, each drawn signature is embedded as a PNG (base64) inside a [`questionnaireresponse-signature`](http://hl7.org/fhir/R4/extension-questionnaireresponse-signature.html) extension holding a FHIR `Signature`:
- on `QuestionnaireResponse.extension` for a root level signature,
- on the matching `QuestionnaireResponseItem.extension` for an item level signature.

The `Signature.type` is taken from the marker's coding (falling back to a default `Author's Signature` coding only when the marker declares none), `sigFormat` is `image/png`, `when` is the submit time, and `who` / `onBehalfOf` come from the `whoSigns` / `signsOnBehalfOf` you provide.

### Signer information (`QuestionnairePerson`)
`subject`, `author`, `source`, `whoSigns` and `signsOnBehalfOf` are of type `QuestionnairePerson`:

```dart
QuestionnairePerson(
  reference: practitionerReference, // FHIR Reference written into the response
  name: 'Dr. Jane Doe',             // Display name
  title: 'Attending Physician',     // Optional subtitle
)
```

When `whoSigns` (and optionally `signsOnBehalfOf`) is provided, the signature field also shows the signer's name/title beneath the pad ("By: …" / "On behalf of: …"), and the `reference` is written into the response `Signature.who` / `Signature.onBehalfOf`.

### Overriding the UI
All signature widgets are public and can be extended/overridden: `QuestionnaireSignatureView`, `SignaturePadDialog` (with its public generic `SignaturePadDialogState`) and `SignatureController`. Detection helpers `hasSignature` and `signatureTypeCoding` are exposed as extensions on `Questionnaire` and `QuestionnaireItem`.

## Some extra notes
1. This widget will use the app Theme to build, so if you want to change colors, InputDecorations, etc, you just have to change it in your app Theme. Also all the package widgets are public and exposed so you could override it if necessary.
2. The `QuestionnaireView` implementation takes care of validations depending on each `QuestionnaireItem` definition.
3. Check the example project which shows all the features in action.

## Demo
### [Try the demo app here](https://luis901101.github.io/fhir_questionnaire/).
<div>
 <a href="https://raw.githubusercontent.com/luis901101/fhir_questionnaire/main/example/docs/gif/demo.gif">
<img src="https://raw.githubusercontent.com/luis901101/fhir_questionnaire/main/example/docs/gif/demo.gif" width="230"/>
</a>
</div>
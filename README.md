
# FHIR Questionnaire

A Flutter package for working with FHIR® Questionnaires. FHIR® is the registered trademark of HL7 and is used with the permission of HL7. Use of the FHIR trademark does not constitute endorsement of this product by HL7.

This package takes care building the UI of a **FHIR R4 Questionnaire**, handle behavior and validations and finally generates the **QuestionnaireResponse** from the user answers.

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
)
```

## QuestionnaireView
1. **Questionnaire questionnaire:** `QuestionnaireView` requires an object of type **Questionnaire** this is the definition of the Questionnaire and will be used to build the Form UI and generate the Questions and Answers.
2. **String? locale**: Optionally you can specify the language like "es" or "en" or "fr", etc. you want to use for validation messages and Submit button, by default the system language will be used.
3. **List<QuestionnaireBaseLocalization>? localizations**: this is a list allows you to add extra language translations to the Questionnaire, currently the package supports only English and Spanish, so you can add other Languages, you just need to create a class for each new Language you want to support and extend **QuestionnaireBaseLocalization**.
4. **QuestionnaireBaseLocalization? defaultLocalization**: Indicates what should be the fallback localization if the specified language or the system language is not supported, by default English is the fallback.
5. **bool isLoading**: use this to indicate there is an ongoing operation, for instance if you need to make an API request to load your **Questionnaire** you can set `isLoading = true` so the `QuestionnaireView` will show a Shimmer loading effect view.
6. **Future<Attachment?> Function()? onAttachmentLoaded**: To make this package simpler and compatible with all Flutter supported platforms, the feature to load an attachment is delegated to the App, so you have to handle this logic by implementing this function and returning an [Attachment](https://hl7.org/fhir/R4/datatypes.html#attachment) instance according to FHIR.
7. **ValueChanged<QuestionnaireResponse> onSubmit**: This is the callback that will be triggered once the user taps on the Submit button, and you will get a `QuestionnaireResponse` instance ready, you just have to set the subject or whatever extra data you consider necessary but the answers will covered.
8. **QuestionnaireController? controller**: This is the controller to be used for items and response generation within the `QuestionnaireView`, the purpose of this controller here is to allow you to use an instance of an extension of `QuestionnaireController` so you can override the behavior and widgets.

## Some extra notes
1. This widget will use the app Theme to build, so if you want to change colors, InputDecorations, etc, you just have to change it in your app Theme. Also all the package widgets are public and exposed so you could override it if necessary.
2. The `QuestionnaireView` implementation takes care of validations depending on each `QuestionnaireItem` definition.
3. Check the example project which shows all the features in action.

## Demo
<div>
 <a href="https://raw.githubusercontent.com/luis901101/fhir_questionnaire/main/example/doc/gif/demo.gif">
<img src="https://raw.githubusercontent.com/luis901101/fhir_questionnaire/main/example/doc/gif/demo.gif" width="230"/>
</a>
</div>
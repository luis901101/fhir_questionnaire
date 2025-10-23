import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:example/attachment_utils.dart';
import 'package:example/questionnaire_samples.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_field_editor/json_field_editor.dart';

void main() {
  runApp(const MyApp());
}

StreamController<InputDecorationTheme?> inputDecorationThemeStream =
    StreamController<InputDecorationTheme>.broadcast();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InputDecorationTheme?>(
      stream: inputDecorationThemeStream.stream,
      initialData: null,
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'FHIR Questionnaire Demo',
          scrollBehavior: const CustomScrollBehavior(),
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
              inputDecorationTheme: snapshot.data),
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<({String name, Locale? value})> locales = [
    (name: 'System default', value: null),
    (name: 'English', value: const Locale('en', 'US')),
    (name: 'Spanish', value: const Locale('es', 'ES')),
    (name: 'French', value: const Locale('fr', 'FR')),
  ];
  final List<({String name, String value})> questionnaires = [
    (name: 'Generic', value: QuestionnaireSamples.sampleGeneric),
    (name: 'PRAPARE', value: QuestionnaireSamples.samplePrapare),
    (name: 'PHQ-9', value: QuestionnaireSamples.samplePHQ9),
    (name: 'GAD-7', value: QuestionnaireSamples.sampleGAD7),
    (name: 'BMI', value: QuestionnaireSamples.sampleBMI),
    (name: 'FDR Communs', value: QuestionnaireSamples.fdrCommuns),
  ];
  final List<({String name, InputDecorationTheme? value})>
      inputDecorationThemes = [
    (name: 'Default', value: null),
    (
      name: 'Outline',
      value: const InputDecorationTheme(
        contentPadding: EdgeInsets.only(left: 16, top: 12, bottom: 12),
        border: OutlineInputBorder(),
      )
    ),
    (
      name: 'Outline Streched Rounded',
      value: const InputDecorationTheme(
        contentPadding: EdgeInsets.only(left: 16, top: 12, bottom: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      )
    ),
    (
      name: 'Outline Streched Rounded Filled',
      value: const InputDecorationTheme(
        contentPadding: EdgeInsets.only(left: 16, top: 12, bottom: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        filled: true,
      )
    ),
    (
      name: 'Outline Streched Rounded Filled No Borders',
      value: const InputDecorationTheme(
        contentPadding: EdgeInsets.only(left: 16, top: 12, bottom: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          borderSide: BorderSide(
            style: BorderStyle.none,
            width: 0,
          ),
        ),
        isDense: true,
        alignLabelWithHint: true,
        filled: true,
      )
    ),
  ];
  static bool isValidJson(String? jsonString) {
    if (jsonString == null) {
      return false;
    }
    try {
      json.decode(jsonString);
      return true;
    } on FormatException catch (_) {
      return false;
    }
  }

  Locale? selectedLocale;
  String selectedQuestionnaire = QuestionnaireSamples.sampleGeneric;
  InputDecorationTheme? selectedInputDecorationTheme;
  final extraLocalizations = [QuestionnaireFrLocalization()];
  ThemeData theme = ThemeData();
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FHIR Questionnaire Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      label: Text('Select a Questionnaire sample')),
                  initialValue: selectedQuestionnaire,
                  items: questionnaires
                      .map((e) => DropdownMenuItem<String>(
                            value: e.value,
                            child: Text(e.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedQuestionnaire = value;
                    }
                  }),
              const SizedBox(height: 8.0),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        String? nameError;
                        String? jsonError;
                        final nameController = JsonTextFieldController();
                        final jsonController = JsonTextFieldController();
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: StatefulBuilder(
                                builder: (context, dialogSetState) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Add a Questionnaire from JSON',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            labelText: 'Questionnaire Name',
                                            errorText: nameError,
                                            contentPadding: EdgeInsets.only(
                                                left: 16, top: 12, bottom: 12),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(28)),
                                            ),
                                            filled: true,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.6),
                                          child: SingleChildScrollView(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              child: JsonField(
                                                controller: jsonController,
                                                isFormatting: true,
                                                showErrorMessage: true,
                                                maxLines: null,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Questionnaire JSON',
                                                  errorText: jsonError,
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 16,
                                                          top: 12,
                                                          bottom: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                28)),
                                                  ),
                                                  filled: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () => jsonController
                                                    .formatJson(sortJson: true),
                                                child:
                                                    const Text('Format JSON'),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  nameError = jsonError = null;
                                                  if (nameController
                                                      .text.isEmpty) {
                                                    nameError =
                                                        'Name is required';
                                                  }
                                                  if (nameError == null &&
                                                      questionnaires.any(
                                                          (item) =>
                                                              item.name ==
                                                              nameController
                                                                  .text)) {
                                                    nameError =
                                                        'A Questionnaire with this name already exists';
                                                  }
                                                  if (jsonController
                                                      .text.isEmpty) {
                                                    jsonError =
                                                        'JSON is required';
                                                  }
                                                  if (jsonError == null &&
                                                      !isValidJson(
                                                          jsonController
                                                              .text)) {
                                                    jsonError = 'Invalid JSON';
                                                  }
                                                  if (jsonError == null &&
                                                      questionnaires.any(
                                                          (item) =>
                                                              item.value ==
                                                              jsonController
                                                                  .text)) {
                                                    jsonError =
                                                        'A Questionnaire with this JSON already exists';
                                                  }
                                                  if (nameError != null ||
                                                      jsonError != null) {
                                                    dialogSetState(() {});
                                                    return;
                                                  }
                                                  questionnaires.add((
                                                    name: nameController.text,
                                                    value: jsonController.text
                                                  ));
                                                  selectedQuestionnaire =
                                                      jsonController.text;
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      theme.colorScheme.primary,
                                                  foregroundColor: theme
                                                      .colorScheme.onPrimary,
                                                ),
                                                child: const Text('Add'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                          ),
                        );
                      });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add a Questionnaire from JSON'),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<Locale?>(
                  decoration: const InputDecoration(
                      label: Text('Select the Questionnaire locale')),
                  initialValue: selectedLocale,
                  items: locales
                      .map((e) => DropdownMenuItem<Locale>(
                            value: e.value,
                            child: Text(e.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedLocale = value;
                  }),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<InputDecorationTheme?>(
                  decoration: const InputDecoration(
                      label: Text('Select input decoration theme ')),
                  initialValue: selectedInputDecorationTheme,
                  items: inputDecorationThemes
                      .map((e) => DropdownMenuItem<InputDecorationTheme>(
                            value: e.value,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.78,
                              child: Text(e.name),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedInputDecorationTheme = value;
                    inputDecorationThemeStream
                        .add(selectedInputDecorationTheme);
                  }),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        extendedPadding: const EdgeInsets.symmetric(horizontal: 32.0),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionnairePage(
                  questionnaire: questionnaire,
                  locale: selectedLocale,
                  localizations: extraLocalizations,
                ),
              ));
        },
        label: const Text('Open Questionnaire'),
      ),
    );
  }

  Questionnaire get questionnaire =>
      Questionnaire.fromJsonString(selectedQuestionnaire);
}

class QuestionnairePage extends StatefulWidget {
  final Questionnaire questionnaire;
  final Locale? locale;
  final List<QuestionnaireBaseLocalization>? localizations;
  const QuestionnairePage({
    super.key,
    required this.questionnaire,
    this.locale,
    this.localizations,
  });

  @override
  State createState() => QuestionnairePageState();
}

class QuestionnairePageState extends State<QuestionnairePage> {
  bool loading = true;
  ThemeData theme = ThemeData();

  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(seconds: 1), () => setState(() => loading = false));
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaire'),
      ),
      body: QuestionnaireView(
        key: ValueKey(loading),
        questionnaire: widget.questionnaire,
        onAttachmentLoaded: onAttachmentLoaded,
        locale: widget.locale,
        localizations: widget.localizations,
        isLoading: loading,
        onSubmit: onSubmit,
      ),
    );
  }

  Future<Attachment?> onAttachmentLoaded() async {
    return AttachmentUtils.pickAttachment(context);
  }

  void onSubmit(QuestionnaireResponse questionnaireResponse) async {
    String json = jsonEncode(questionnaireResponse.toJson());
    var prettyJson = const JsonEncoder.withIndent('  ')
        .convert(questionnaireResponse.toJson());
    debugPrint('''
      ========================================================================
      $prettyJson
      ========================================================================
      ''');
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Questionnaire Response',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: JsonField(
                            controller: JsonTextFieldController()..text = json,
                            isFormatting: true,
                            showErrorMessage: true,
                            doInitFormatting: true,
                            readOnly: true,
                            showCursor: true,
                            enableInteractiveSelection: true,
                            maxLines: null,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 16, top: 12, bottom: 12),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(28)),
                              ),
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}

/// French localizations
class QuestionnaireFrLocalization extends QuestionnaireBaseLocalization {
  QuestionnaireFrLocalization() : super(const Locale('fr', 'FR'));

  @override
  String get btnSubmit => 'Soumettre';
  @override
  String get btnUpload => 'Télécharger';
  @override
  String get btnChange => 'Changement';
  @override
  String get btnRemove => 'Retirer';
  @override
  String get textOtherOption => 'Autre option';
  @override
  String get textDate => 'Date';
  @override
  String get textTime => 'Temps';
  @override
  String get exceptionNoEmptyField => 'Ce champ est obligatoire.';
  @override
  String get exceptionValueMustBeAPositiveIntegerNumber =>
      'La valeur doit être un nombre entier positif.';
  @override
  String get exceptionValueMustBeAPositiveNumber =>
      'La valeur doit être un nombre positif.';
  @override
  String get exceptionInvalidUrl => 'Invalid url.';
  @override
  String exceptionValueOutOfRange(dynamic minValue, dynamic maxValue) =>
      'La valeur doit être comprise entre $minValue et $maxValue.';
  @override
  String exceptionTextLength(dynamic minLength, dynamic maxLength) =>
      'Le texte doit contenir au moins des caractères $minLength et au maximum $maxLength.';
  @override
  String exceptionTextMaxLength(dynamic maxLength) =>
      'Le texte doit contenir au maximum des caractères $maxLength.';
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  static const _webScrollPhysics =
      BouncingScrollPhysics(parent: RangeMaintainingScrollPhysics());

  const CustomScrollBehavior() : super();

  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      kIsWeb ? _webScrollPhysics : super.getScrollPhysics(context);
}

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fhir/r4.dart';

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
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<({String name, String? value})> locales = [
    (name: 'System default', value: null),
    (name: 'English', value: 'en'),
    (name: 'Spanish', value: 'es'),
    (name: 'French', value: 'fr'),
  ];
  final List<({String name, int value})> questionnaires = [
    (name: 'Generic', value: 0),
    (name: 'PRAPARE', value: 1),
    (name: 'PHQ-9', value: 2),
    (name: 'GAD-7', value: 3),
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
  String? selectedLocale;
  int selectedQuestionnaire = 0;
  InputDecorationTheme? selectedInputDecorationTheme;
  final extraLocalizations = [QuestionnaireFrLocalization()];
  @override
  Widget build(BuildContext context) {
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
              DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                      label: Text('Select a Questionnaire sample')),
                  value: selectedQuestionnaire,
                  items: questionnaires
                      .map((e) => DropdownMenuItem<int>(
                            value: e.value,
                            child: Text(e.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedQuestionnaire = value;
                    }
                  }),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(
                      label: Text('Select the Questionnaire locale')),
                  value: selectedLocale,
                  items: locales
                      .map((e) => DropdownMenuItem<String>(
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
                  value: selectedInputDecorationTheme,
                  items: inputDecorationThemes
                      .map((e) => DropdownMenuItem<InputDecorationTheme>(
                            value: e.value,
                            child: Text(e.name),
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
      Questionnaire.fromJsonString(switch (selectedQuestionnaire) {
        1 => QuestionnaireUtils.samplePrapare,
        2 => QuestionnaireUtils.samplePHQ9,
        3 => QuestionnaireUtils.sampleGAD7,
        0 || _ => QuestionnaireUtils.sampleGeneric,
      });
}

class QuestionnairePage extends StatefulWidget {
  final Questionnaire questionnaire;
  final String? locale;
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

  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(seconds: 1), () => setState(() => loading = false));
  }

  @override
  Widget build(BuildContext context) {
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
    // return AttachmentUtils.pickAttachment(context);
    return null;
  }

  void onSubmit(QuestionnaireResponse questionnaireResponse) async {
    var prettyString = const JsonEncoder.withIndent('  ')
        .convert(questionnaireResponse.toJson());
    // ignore: avoid_print
    print('''
      ========================================================================
      $prettyString
      ========================================================================
      ''');
  }
}

/// French localizations
class QuestionnaireFrLocalization extends QuestionnaireBaseLocalization {
  QuestionnaireFrLocalization() : super('fr');

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

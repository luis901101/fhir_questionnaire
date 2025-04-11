import 'package:fhir_r4/fhir_r4.dart';

extension QuestionnaireSamples on Questionnaire {
  static String get sampleGeneric => '''
  {
  "resourceType": "Questionnaire",
  "id": "example-all-item-types",
  "version": "1",
  "name": "AllItemTypesExample",
  "title": "Questionnaire with All Possible Item Types",
  "status": "draft",
  "date": "2024-03-05",
  "subjectType": ["Patient"],
  "item": [
    {
      "linkId": "intro",
      "text": "Welcome to the Health and Wellness Survey! Please read the instructions carefully before proceeding.",
      "type": "display"
    },
    {
      "linkId": "501",
      "text": "Have you experienced any symptoms of a common cold in the last 14 days?",
      "type": "boolean"
    },
    {
      "linkId": "502",
      "text": "Please upload your most recent blood test results.",
      "type": "attachment"
    },
    {
      "linkId": "401",
      "text": "What is the URL of your personal website?",
      "type": "url"
    },
    {
      "linkId": "402",
      "text": "Please provide the URL of your LinkedIn profile.",
      "type": "url",
      "initial": [
        {
          "valueUri": "http://example.com/your-default-linkedin"
        }
      ]
    },
    {
      "linkId": "300",
      "text": "Body Info",
      "type": "group",
      "item": [
        {
          "linkId": "301",
          "text": "What is your height?",
          "type": "quantity",
          "initial": [
            {
              "valueQuantity": {
                "value": 170,
                "unit": "cm",
                "system": "http://unitsofmeasure.org",
                "code": "cm"
              }
            }
          ]
        },
        {
          "linkId": "302",
          "text": "What is your weight?",
          "type": "quantity",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-unit",
              "valueCodeableConcept": {
                "coding": [
                  {
                    "system": "http://unitsofmeasure.org",
                    "code": "kg",
                    "display": "kilograms"
                  }
                ]
              }
            }
          ]
        },
        {
          "linkId": "303",
          "text": "What is your waist circumference?",
          "type": "quantity",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-unit",
              "valueCodeableConcept": {
                "coding": [
                  {
                    "system": "http://unitsofmeasure.org",
                    "code": "in",
                    "display": "inches"
                  }
                ]
              }
            }
          ]
        }
      ]
    },
    {
      "linkId": "2",
      "text": "What is your date of birth?",
      "type": "date"
    },
    {
      "linkId": "2.1",
      "text": "What time did you take your medication this morning?",
      "type": "time"
    },
    {
      "linkId": "2.2",
      "text": "When was your last doctor's appointment?",
      "type": "dateTime"
    },
    {
      "linkId": "1",
      "text": "Your full name",
      "type": "string",
      "required": true
    },
    {
      "linkId": "104",
      "text": "Do you have any dietary restrictions?",
      "type": "choice",
      "answerOption": [
        { "valueCoding": { "code": "yes", "display": "Yes" } },
        { "valueCoding": { "code": "no", "display": "No" } }
      ]
    },
    {
      "linkId": "105",
      "text": "Please specify your dietary restrictions.",
      "type": "text",
      "enableWhen": [
        {
          "question": "104",
          "operator": "=",
          "answerCoding": { "code": "yes" }
        },
        {
          "question": "1",
          "operator": "=",
          "answerCoding": { "code": "Luis" }
        }
      ],
      "enableBehavior": "all"
    },
    {
      "linkId": "200",
      "text": "How many is 2 + 2?",
      "type": "integer"
    },
    {
      "linkId": "201",
      "text": "Elaborate your answer on how many is 2 + 2?.",
      "type": "text",
      "enableWhen": [
        {
          "question": "200",
          "operator": ">",
          "answerInteger": 2
        },
        {
          "question": "200",
          "operator": "<",
          "answerInteger": 9
        },
        {
          "question": "200",
          "operator": ">=",
          "answerInteger": 3
        },
        {
          "question": "200",
          "operator": "<=",
          "answerInteger": 10
        }
      ],
      "enableBehavior": "all"
    },
    {
      "linkId": "202",
      "text": "How many colors has a rainbow?",
      "type": "integer"
    },
    {
      "linkId": "203",
      "text": "Elaborate your answer on how many colors has a rainbow?",
      "type": "text",
      "enableWhen": [
        {
          "question": "202",
          "operator": "exists",
          "answerBoolean": true
        },
        {
          "question": "200",
          "operator": "exists",
          "answerBoolean": false
        }
      ],
      "enableBehavior": "any"
    },
    {
      "linkId": "4",
      "text": "Please specify your gender",
      "required": true,
      "type": "choice",
      "answerOption": [
        { "valueCoding": { "code": "male", "display": "Male" } },
        { "valueCoding": { "code": "female", "display": "Female" } },
        { "valueCoding": { "code": "other", "display": "Other" } },
        { "valueCoding": { "code": "unknown", "display": "Prefer not to say" } }
      ]
    },
    {
      "linkId": "5",
      "text": "List your current medications",
      "type": "open-choice",
      "answerOption": [
        { "valueCoding": { "code": "med1", "display": "Medication A" } },
        { "valueCoding": { "code": "med2", "display": "Medication B" } }
      ]
    },
    {
      "linkId": "100",
      "text": "Which of the following dietary preferences apply to you? (Select all that apply)",
      "type": "choice",
      "repeats": true,
      "answerOption": [
        {
          "valueCoding": {
            "system": "http://example.org/dietary-preferences",
            "code": "vegetarian",
            "display": "Vegetarian"
          }
        },
        {
          "valueCoding": {
            "system": "http://example.org/dietary-preferences",
            "code": "vegan",
            "display": "Vegan"
          }
        },
        {
          "valueCoding": {
            "system": "http://example.org/dietary-preferences",
            "code": "glutenFree",
            "display": "Gluten-Free"
          }
        },
        {
          "valueCoding": {
            "system": "http://example.org/dietary-preferences",
            "code": "ketogenic",
            "display": "Ketogenic"
          }
        }
      ]
    },
    {
      "linkId": "101",
      "text": "Which of the following type of exercises do you practice? (Select all that apply)",
      "type": "open-choice",
      "repeats": true,
      "answerOption": [
        {
          "valueCoding": {
            "code": "yoga",
            "display": "Yoga"
          }
        },
        {
          "valueCoding": {
            "code": "pilates",
            "display": "Pilates"
          }
        },
        {
          "valueCoding": {
            "code": "zumba",
            "display": "Zumba"
          }
        }
      ]
    },
    {
      "linkId": "102",
      "text": "Select your age range:",
      "required": true,
      "type": "choice",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "answerOption": [
        {
          "valueCoding": {
            "system": "http://example.org/age-ranges",
            "code": "18-25",
            "display": "18-25"
          }
        },
        {
          "valueCoding": {
            "system": "http://example.org/age-ranges",
            "code": "26-35",
            "display": "26-35"
          }
        },
        {
          "valueCoding": {
            "system": "http://example.org/age-ranges",
            "code": "36-45",
            "display": "36-45"
          }
        }
      ]
    },
    {
      "linkId": "103",
      "text": "How many hours do you sleep?",
      "required": true,
      "type": "open-choice",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "answerOption": [
        {
          "valueCoding": {
            "code": "6 hours",
            "display": "6 hours"
          }
        },
        {
          "valueCoding": {
            "code": "8 hours",
            "display": "8 hours"
          }
        },
        {
          "valueCoding": {
            "code": "10 hours",
            "display": "10 hours"
          }
        }
      ]
    },
    {
      "linkId": "6",
      "text": "Please rate your general health",
      "type": "integer"
    },
    {
      "linkId": "7",
      "text": "Enter your body height in cm",
      "type": "decimal",
      "readOnly": true,
      "initial": [
        {
          "valueDecimal": 190.5
        }
      ]
    },
    {
      "linkId": "8",
      "text": "Describe your symptoms",
      "type": "text",
      "maxLength": 160
    }
  ]
}
''';
  static String get samplePrapare => '''
{
    "resourceType": "Questionnaire",
    "meta": {
      "profile": [
        "http://hl7.org/fhir/4.0/StructureDefinition/Questionnaire"
      ],
      "tag": [
        {
          "code": "lformsVersion: 34.3.0"
        }
      ],
      "versionId": "932299ee-fbe4-4540-b826-dcabed049fb1",
      "lastUpdated": "2024-02-24T03:06:47.680Z",
      "author": {
        "reference": "Practitioner/18e39305-b190-406f-bdb7-62a6abd44f78",
        "display": "John Doe"
      },
      "project": "b8676c66-4612-4fe0-a52a-735e181a4df8",
      "compartment": [
        {
          "reference": "Project/b8676c66-4612-4fe0-a52a-735e181a4df8"
        }
      ]
    },
    "title": "Family & Home",
    "status": "draft",
    "copyright": "© 2019. This item comes from the national PRAPARE social determinants of health assessment protocol, developed and owned by the National Association of Community Health Centers (NACHC), in partnership with the Association of Asian Pacific Community Health Organization (AAPCHO), the Oregon Primary Care Association (OPCA), and the Institute for Alternative Futures (IAF). For more information, visit www.nachc.org/prapare Used with permission.",
    "code": [
      {
        "system": "http://loinc.org",
        "code": "93042-0",
        "display": "Family & Home"
      }
    ],
    "item": [
      {
        "type": "decimal",
        "code": [
          {
            "code": "63512-8",
            "display": "How many family members, including yourself, do you currently live with?",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-unit",
            "valueCoding": {
              "code": "{#}",
              "display": "{#}",
              "system": "http://unitsofmeasure.org"
            }
          }
        ],
        "required": false,
        "linkId": "/63512-8",
        "text": "How many family members, including yourself, do you currently live with?"
      },
      {
        "type": "choice",
        "code": [
          {
            "code": "71802-3",
            "display": "What is your housing situation today?",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
            "valueCodeableConcept": {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/questionnaire-item-control",
                  "code": "drop-down",
                  "display": "Drop down"
                }
              ],
              "text": "Drop down"
            }
          }
        ],
        "required": false,
        "linkId": "/71802-3",
        "text": "What is your housing situation today?",
        "answerOption": [
          {
            "valueCoding": {
              "code": "LA30189-7",
              "display": "I have housing",
              "system": "http://loinc.org"
            }
          },
          {
            "valueCoding": {
              "code": "LA30190-5",
              "display": "I do not have housing (staying with others, in a hotel, in a shelter, living outside on the street, on a beach, in a car, or in a park)",
              "system": "http://loinc.org"
            }
          },
          {
            "valueCoding": {
              "code": "LA30122-8",
              "display": "I choose not to answer this question",
              "system": "http://loinc.org"
            }
          }
        ],
        "item": [
          {
            "text": "Describes patients living arrangement",
            "type": "display",
            "linkId": "/71802-3-help",
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                "valueCodeableConcept": {
                  "text": "Help-Button",
                  "coding": [
                    {
                      "code": "help",
                      "display": "Help-Button",
                      "system": "http://hl7.org/fhir/questionnaire-item-control"
                    }
                  ]
                }
              }
            ]
          }
        ]
      },
      {
        "type": "choice",
        "code": [
          {
            "code": "93033-9",
            "display": "Are you worried about losing your housing?",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
            "valueCodeableConcept": {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/questionnaire-item-control",
                  "code": "drop-down",
                  "display": "Drop down"
                }
              ],
              "text": "Drop down"
            }
          }
        ],
        "required": false,
        "linkId": "/93033-9",
        "text": "Are you worried about losing your housing?",
        "answerOption": [
          {
            "valueCoding": {
              "code": "LA33-6",
              "display": "Yes",
              "system": "http://loinc.org"
            }
          },
          {
            "valueCoding": {
              "code": "LA32-8",
              "display": "No",
              "system": "http://loinc.org"
            }
          },
          {
            "valueCoding": {
              "code": "LA30122-8",
              "display": "I choose not to answer this question",
              "system": "http://loinc.org"
            }
          }
        ]
      },
      {
        "type": "string",
        "code": [
          {
            "code": "56799-0",
            "display": "What address do you live at?",
            "system": "http://loinc.org"
          }
        ],
        "required": false,
        "linkId": "/56799-0",
        "text": "What address do you live at?"
      }
    ],
    "id": "cc6d76d5-3d6b-4cbe-827e-5f424dd278be"
  }
''';
  static String get samplePHQ9 => '''
{
  "resourceType": "Questionnaire",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/4.0/StructureDefinition/Questionnaire"
    ],
    "tag": [
      {
        "code": "lformsVersion: 34.3.0"
      }
    ],
    "versionId": "d8afac81-673e-4e0d-8d5b-5f5012ecf244",
    "lastUpdated": "2024-02-24T03:06:29.261Z",
    "author": {
      "reference": "Practitioner/18e39305-b190-406f-bdb7-62a6abd44f78",
      "display": "John Doe"
    },
    "project": "b8676c66-4612-4fe0-a52a-735e181a4df8",
    "compartment": [
      {
        "reference": "Project/b8676c66-4612-4fe0-a52a-735e181a4df8"
      }
    ]
  },
  "title": "PHQ-9 quick depression assessment panel [Reported.PHQ]",
  "status": "draft",
  "copyright": "Copyright © Pfizer Inc. All rights reserved. Developed by Drs. Robert L. Spitzer, Janet B.W. Williams, Kurt Kroenke and colleagues, with an educational grant from Pfizer Inc. No permission required to reproduce, translate, display or distribute.",
  "code": [
    {
      "system": "http://loinc.org",
      "code": "44249-1",
      "display": "PHQ-9 quick depression assessment panel [Reported.PHQ]"
    }
  ],
  "item": [
    {
      "type": "choice",
      "code": [
        {
          "code": "44250-9",
          "display": "Little interest or pleasure in doing things",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "required": false,
      "linkId": "/44250-9",
      "text": "Little interest or pleasure in doing things",
      "answerOption": [
        {
          "valueCoding": {
            "code": "LA6568-5",
            "display": "Not at all",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "0"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 0
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6569-3",
            "display": "Several days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "1"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 1
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6570-1",
            "display": "More than half the days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "2"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 2
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6571-9",
            "display": "Nearly every day",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "3"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 3
            }
          ]
        }
      ]
    },
    {
      "type": "choice",
      "code": [
        {
          "code": "44255-8",
          "display": "Feeling down, depressed, or hopeless",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "required": false,
      "linkId": "/44255-8",
      "text": "Feeling down, depressed, or hopeless",
      "answerOption": [
        {
          "valueCoding": {
            "code": "LA6568-5",
            "display": "Not at all",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "0"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 0
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6569-3",
            "display": "Several days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "1"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 1
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6570-1",
            "display": "More than half the days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "2"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 2
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6571-9",
            "display": "Nearly every day",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "3"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 3
            }
          ]
        }
      ]
    },
    {
      "type": "choice",
      "code": [
        {
          "code": "44259-0",
          "display": "Trouble falling or staying asleep, or sleeping too much",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "required": false,
      "linkId": "/44259-0",
      "text": "Trouble falling or staying asleep, or sleeping too much",
      "answerOption": [
        {
          "valueCoding": {
            "code": "LA6568-5",
            "display": "Not at all",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "0"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 0
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6569-3",
            "display": "Several days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "1"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 1
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6570-1",
            "display": "More than half the days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "2"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 2
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6571-9",
            "display": "Nearly every day",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "3"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 3
            }
          ]
        }
      ]
    },
    {
      "type": "choice",
      "code": [
        {
          "code": "44254-1",
          "display": "Feeling tired or having little energy",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "required": false,
      "linkId": "/44254-1",
      "text": "Feeling tired or having little energy",
      "answerOption": [
        {
          "valueCoding": {
            "code": "LA6568-5",
            "display": "Not at all",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "0"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 0
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6569-3",
            "display": "Several days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "1"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 1
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6570-1",
            "display": "More than half the days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "2"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 2
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6571-9",
            "display": "Nearly every day",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "3"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 3
            }
          ]
        }
      ]
    },
    {
      "type": "choice",
      "code": [
        {
          "code": "44251-7",
          "display": "Poor appetite or overeating",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "required": false,
      "linkId": "/44251-7",
      "text": "Poor appetite or overeating",
      "answerOption": [
        {
          "valueCoding": {
            "code": "LA6568-5",
            "display": "Not at all",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "0"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 0
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6569-3",
            "display": "Several days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "1"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 1
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6570-1",
            "display": "More than half the days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "2"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 2
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6571-9",
            "display": "Nearly every day",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "3"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 3
            }
          ]
        }
      ]
    },
    {
      "type": "choice",
      "code": [
        {
          "code": "44258-2",
          "display": "Feeling bad about yourself-or that you are a failure or have let yourself or your family down",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "required": false,
      "linkId": "/44258-2",
      "text": "Feeling bad about yourself-or that you are a failure or have let yourself or your family down",
      "answerOption": [
        {
          "valueCoding": {
            "code": "LA6568-5",
            "display": "Not at all",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "0"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 0
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6569-3",
            "display": "Several days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "1"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 1
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6570-1",
            "display": "More than half the days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "2"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 2
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6571-9",
            "display": "Nearly every day",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "3"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 3
            }
          ]
        }
      ]
    },
    {
      "type": "choice",
      "code": [
        {
          "code": "44252-5",
          "display": "Trouble concentrating on things, such as reading the newspaper or watching television",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "required": false,
      "linkId": "/44252-5",
      "text": "Trouble concentrating on things, such as reading the newspaper or watching television",
      "answerOption": [
        {
          "valueCoding": {
            "code": "LA6568-5",
            "display": "Not at all",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "0"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 0
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6569-3",
            "display": "Several days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "1"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 1
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6570-1",
            "display": "More than half the days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "2"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 2
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6571-9",
            "display": "Nearly every day",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "3"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 3
            }
          ]
        }
      ]
    },
    {
      "type": "choice",
      "code": [
        {
          "code": "44253-3",
          "display": "Moving or speaking so slowly that other people could have noticed. Or the opposite-being so fidgety or restless that you have been moving around a lot more than usual",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "required": false,
      "linkId": "/44253-3",
      "text": "Moving or speaking so slowly that other people could have noticed. Or the opposite-being so fidgety or restless that you have been moving around a lot more than usual",
      "answerOption": [
        {
          "valueCoding": {
            "code": "LA6568-5",
            "display": "Not at all",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "0"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 0
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6569-3",
            "display": "Several days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "1"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 1
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6570-1",
            "display": "More than half the days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "2"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 2
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6571-9",
            "display": "Nearly every day",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "3"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 3
            }
          ]
        }
      ]
    },
    {
      "type": "choice",
      "code": [
        {
          "code": "44260-8",
          "display": "Thoughts that you would be better off dead, or of hurting yourself in some way",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "required": false,
      "linkId": "/44260-8",
      "text": "Thoughts that you would be better off dead, or of hurting yourself in some way",
      "answerOption": [
        {
          "valueCoding": {
            "code": "LA6568-5",
            "display": "Not at all",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "0"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 0
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6569-3",
            "display": "Several days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "1"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 1
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6570-1",
            "display": "More than half the days",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "2"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 2
            }
          ]
        },
        {
          "valueCoding": {
            "code": "LA6571-9",
            "display": "Nearly every day",
            "system": "http://loinc.org"
          },
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
              "valueString": "3"
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
              "valueDecimal": 3
            }
          ]
        }
      ]
    },
    {
      "type": "choice",
      "code": [
        {
          "code": "69722-7",
          "display": "How difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ],
            "text": "Drop down"
          }
        }
      ],
      "required": false,
      "linkId": "/69722-7",
      "text": "How difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?",
      "answerOption": [
        {
          "valueCoding": {
            "code": "LA6572-7",
            "display": "Not difficult at all",
            "system": "http://loinc.org"
          }
        },
        {
          "valueCoding": {
            "code": "LA6573-5",
            "display": "Somewhat difficult",
            "system": "http://loinc.org"
          }
        },
        {
          "valueCoding": {
            "code": "LA6575-0",
            "display": "Very difficult",
            "system": "http://loinc.org"
          }
        },
        {
          "valueCoding": {
            "code": "LA6574-3",
            "display": "Extremely difficult",
            "system": "http://loinc.org"
          }
        }
      ],
      "item": [
        {
          "text": "If you checked off any problems on this questionnaire",
          "type": "display",
          "linkId": "/69722-7-help",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
              "valueCodeableConcept": {
                "text": "Help-Button",
                "coding": [
                  {
                    "code": "help",
                    "display": "Help-Button",
                    "system": "http://hl7.org/fhir/questionnaire-item-control"
                  }
                ]
              }
            }
          ]
        }
      ]
    },
    {
      "type": "decimal",
      "code": [
        {
          "code": "44261-6",
          "display": "Patient health questionnaire 9 item total score",
          "system": "http://loinc.org"
        }
      ],
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-unit",
          "valueCoding": {
            "code": "{score}",
            "display": "{score}",
            "system": "http://unitsofmeasure.org"
          }
        }
      ],
      "required": false,
      "linkId": "/44261-6",
      "text": "Patient health questionnaire 9 item total score",
      "item": [
        {
          "text": "The PHQ-9 is the standard (and most commonly used) depression measure, and it ranges from 0-27 Scoring: Add up all checked boxes on PHQ-9. For every check: Not at all = 0; Several days = 1; More than half the days = 2; Nearly every day = 3 (the scores are the codes that appear in the answer list for each of the PHQ-9 problem panel terms). Interpretation: 1-4 = Minimal depression; 5-9 = Mild depression; 10-14 = Moderate depression; 15-19 = Moderately severe depression; 20-27 = Severed depression.",
          "type": "display",
          "linkId": "/44261-6-help",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
              "valueCodeableConcept": {
                "text": "Help-Button",
                "coding": [
                  {
                    "code": "help",
                    "display": "Help-Button",
                    "system": "http://hl7.org/fhir/questionnaire-item-control"
                  }
                ]
              }
            }
          ]
        }
      ]
    }
  ],
  "id": "9bca2d21-ace0-4da2-af34-b6d20b44c560"
}
''';
  static String get sampleGAD7 => '''
{
    "resourceType": "Questionnaire",
    "meta": {
      "profile": [
        "http://hl7.org/fhir/4.0/StructureDefinition/Questionnaire"
      ],
      "tag": [
        {
          "code": "lformsVersion: 34.3.0"
        }
      ],
      "versionId": "be91c63a-1037-41f2-abcf-23c6e4346fd2",
      "lastUpdated": "2024-02-24T03:06:41.191Z",
      "author": {
        "reference": "Practitioner/18e39305-b190-406f-bdb7-62a6abd44f78",
        "display": "John Doe"
      },
      "project": "b8676c66-4612-4fe0-a52a-735e181a4df8",
      "compartment": [
        {
          "reference": "Project/b8676c66-4612-4fe0-a52a-735e181a4df8"
        }
      ]
    },
    "title": "Generalized anxiety disorder 7 item (GAD-7)",
    "status": "draft",
    "copyright": "Copyright © Pfizer Inc. All rights reserved. Developed by Drs. Robert L. Spitzer, Janet B.W. Williams, Kurt Kroenke and colleagues, with an educational grant from Pfizer Inc. No permission required to reproduce, translate, display or distribute.",
    "code": [
      {
        "system": "http://loinc.org",
        "code": "69737-5",
        "display": "Generalized anxiety disorder 7 item (GAD-7)"
      }
    ],
    "item": [
      {
        "type": "choice",
        "code": [
          {
            "code": "69725-0",
            "display": "Feeling nervous, anxious or on edge",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
            "valueCodeableConcept": {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/questionnaire-item-control",
                  "code": "drop-down",
                  "display": "Drop down"
                }
              ],
              "text": "Drop down"
            }
          }
        ],
        "required": false,
        "linkId": "/69725-0",
        "text": "Feeling nervous, anxious or on edge",
        "answerOption": [
          {
            "valueCoding": {
              "code": "LA6568-5",
              "display": "Not at all",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "0"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 0
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6569-3",
              "display": "Several days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "1"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 1
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6570-1",
              "display": "More than half the days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "2"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 2
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6571-9",
              "display": "Nearly every day",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "3"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 3
              }
            ]
          }
        ]
      },
      {
        "type": "choice",
        "code": [
          {
            "code": "68509-9",
            "display": "Over the past 2 weeks have you not been able to stop or control worrying",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
            "valueCodeableConcept": {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/questionnaire-item-control",
                  "code": "drop-down",
                  "display": "Drop down"
                }
              ],
              "text": "Drop down"
            }
          }
        ],
        "required": false,
        "linkId": "/68509-9",
        "text": "Over the past 2 weeks have you not been able to stop or control worrying",
        "answerOption": [
          {
            "valueCoding": {
              "code": "LA6568-5",
              "display": "Not at all",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "0"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 0
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6569-3",
              "display": "Several days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "1"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 1
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA18938-3",
              "display": "More days than not",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "2"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 2
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6571-9",
              "display": "Nearly every day",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "3"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 3
              }
            ]
          }
        ]
      },
      {
        "type": "choice",
        "code": [
          {
            "code": "69733-4",
            "display": "Worrying too much about different things",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
            "valueCodeableConcept": {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/questionnaire-item-control",
                  "code": "drop-down",
                  "display": "Drop down"
                }
              ],
              "text": "Drop down"
            }
          }
        ],
        "required": false,
        "linkId": "/69733-4",
        "text": "Worrying too much about different things",
        "answerOption": [
          {
            "valueCoding": {
              "code": "LA6568-5",
              "display": "Not at all",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "0"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 0
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6569-3",
              "display": "Several days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "1"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 1
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6570-1",
              "display": "More than half the days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "2"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 2
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6571-9",
              "display": "Nearly every day",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "3"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 3
              }
            ]
          }
        ]
      },
      {
        "type": "choice",
        "code": [
          {
            "code": "69734-2",
            "display": "Trouble relaxing",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
            "valueCodeableConcept": {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/questionnaire-item-control",
                  "code": "drop-down",
                  "display": "Drop down"
                }
              ],
              "text": "Drop down"
            }
          }
        ],
        "required": false,
        "linkId": "/69734-2",
        "text": "Trouble relaxing",
        "answerOption": [
          {
            "valueCoding": {
              "code": "LA6568-5",
              "display": "Not at all",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "0"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 0
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6569-3",
              "display": "Several days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "1"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 1
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6570-1",
              "display": "More than half the days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "2"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 2
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6571-9",
              "display": "Nearly every day",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "3"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 3
              }
            ]
          }
        ]
      },
      {
        "type": "choice",
        "code": [
          {
            "code": "69735-9",
            "display": "Being so restless that it is hard to sit still",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
            "valueCodeableConcept": {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/questionnaire-item-control",
                  "code": "drop-down",
                  "display": "Drop down"
                }
              ],
              "text": "Drop down"
            }
          }
        ],
        "required": false,
        "linkId": "/69735-9",
        "text": "Being so restless that it is hard to sit still",
        "answerOption": [
          {
            "valueCoding": {
              "code": "LA6568-5",
              "display": "Not at all",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "0"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 0
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6569-3",
              "display": "Several days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "1"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 1
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6570-1",
              "display": "More than half the days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "2"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 2
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6571-9",
              "display": "Nearly every day",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "3"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 3
              }
            ]
          }
        ]
      },
      {
        "type": "choice",
        "code": [
          {
            "code": "69689-8",
            "display": "Becoming easily annoyed or irritable.",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
            "valueCodeableConcept": {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/questionnaire-item-control",
                  "code": "drop-down",
                  "display": "Drop down"
                }
              ],
              "text": "Drop down"
            }
          }
        ],
        "required": false,
        "linkId": "/69689-8",
        "text": "Becoming easily annoyed or irritable.",
        "answerOption": [
          {
            "valueCoding": {
              "code": "LA6568-5",
              "display": "Not at all",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "0"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 0
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6569-3",
              "display": "Several days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "1"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 1
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6570-1",
              "display": "More than half the days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "2"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 2
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6571-9",
              "display": "Nearly every day",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "3"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 3
              }
            ]
          }
        ]
      },
      {
        "type": "choice",
        "code": [
          {
            "code": "69736-7",
            "display": "Feeling afraid as if something awful might happen",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
            "valueCodeableConcept": {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/questionnaire-item-control",
                  "code": "drop-down",
                  "display": "Drop down"
                }
              ],
              "text": "Drop down"
            }
          }
        ],
        "required": false,
        "linkId": "/69736-7",
        "text": "Feeling afraid as if something awful might happen",
        "answerOption": [
          {
            "valueCoding": {
              "code": "LA6568-5",
              "display": "Not at all",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "0"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 0
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6569-3",
              "display": "Several days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "1"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 1
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6570-1",
              "display": "More than half the days",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "2"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 2
              }
            ]
          },
          {
            "valueCoding": {
              "code": "LA6571-9",
              "display": "Nearly every day",
              "system": "http://loinc.org"
            },
            "extension": [
              {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-optionPrefix",
                "valueString": "3"
              },
              {
                "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                "valueDecimal": 3
              }
            ]
          }
        ]
      },
      {
        "type": "decimal",
        "code": [
          {
            "code": "70274-6",
            "display": "Generalized anxiety disorder 7 item total score",
            "system": "http://loinc.org"
          }
        ],
        "extension": [
          {
            "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-unit",
            "valueCoding": {
              "code": "{score}",
              "display": "{score}",
              "system": "http://unitsofmeasure.org"
            }
          }
        ],
        "required": false,
        "linkId": "/70274-6",
        "text": "Generalized anxiety disorder 7 item total score"
      }
    ],
    "id": "13d63616-203c-4dcb-a9f1-faa4d45e76ca"
  }
  ''';
  static String get sampleBMI => '''
  {
          "resourceType": "Questionnaire",
          "id": "example-bmi-with-fhirpath",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/variable",
              "valueExpression": {
                "name": "weight",
                "language": "text/fhirpath",
                "expression": "%resource.repeat(item).where(linkId='3.3.1').answer.value"
              }
            },
            {
              "url": "http://hl7.org/fhir/StructureDefinition/variable",
              "valueExpression": {
                "name": "height",
                "language": "text/fhirpath",
                "expression": "%resource.repeat(item).where(linkId='3.3.2').answer.value*0.0254"
              }
            }
          ],
          "item": [
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-unit",
                  "valueCoding": {
                    "system": "http://unitsofmeasure.org",
                    "code": "kg"
                  }
                }
              ],
              "linkId": "3.3.1",
              "text": "Weight (kg)",
              "type": "decimal"
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-unit",
                  "valueCoding": {
                    "system": "http://unitsofmeasure.org",
                    "code": "[in_i]"
                  }
                }
              ],
              "linkId": "3.3.2",
              "text": "Body Height (inches)",
              "type": "decimal"
            },
            {
              "extension": [
                {
                  "url": "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression",
                  "valueExpression": {
                    "description": "BMI Calculation",
                    "language": "text/fhirpath",
                    "expression": "(%weight/(%height.power(2))).round(1)"
                  }
                },
                {
                "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-hidden",
                "valueBoolean": true
              }
              ],
              "linkId": "3.3.3",
              "text": "Your Body Mass Index (BMI) is ",
              "type": "decimal",
              "readOnly": true
            }
          ]
        }
  ''';
  static String get fdrCommuns => '''
  {
  "resourceType": "Questionnaire",
  "title": "Facteurs de risques communs",
  "status": "draft",
  "item": [
    {
      "type": "choice",
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "http://hl7.org/fhir/questionnaire-item-control",
                "code": "drop-down",
                "display": "Drop down"
              }
            ]
          }
        }
      ],
      "linkId": "5674304189455",
      "text": "Origine du patient",
      "required": true,
      "repeats": false,
      "answerOption": [
        {
          "valueCoding": {
            "display": "Européen / Nord-Américain"
          }
        },
        {
          "valueCoding": {
            "display": "Japonais"
          }
        },
        {
          "valueCoding": {
            "display": "Finlandais"
          }
        },
        {
          "valueCoding": {
            "display": "Autre"
          }
        }
      ]
    },
    {
      "linkId": "29f63888-11e7-4aeb-b454-6a8e060a3e52",
      "type": "decimal",
      "text": "taille cm",
      "required": false
    },
    {
      "linkId": "ccdf1a0b-ea35-4eef-9279-3ec34e36677c",
      "type": "decimal",
      "text": "poids Kg",
      "required": false
    },
    {
      "type": "boolean",
      "linkId": "5870138793339",
      "text": "Obésité"
    },
    {
      "type": "boolean",
      "linkId": "4257690781066",
      "text": "Sédentarité"
    },
    {
      "type": "boolean",
      "linkId": "9733868952092",
      "text": "Contraception orale "
    },
    {
      "type": "group",
      "linkId": "484238521278",
      "text": "Tabac",
      "item": [
        {
          "type": "boolean",
          "linkId": "101164469062",
          "text": "actif ou passé"
        },
        {
          "type": "choice",
          "extension": [
            {
              "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
              "valueCodeableConcept": {
                "coding": [
                  {
                    "system": "http://hl7.org/fhir/questionnaire-item-control",
                    "code": "drop-down",
                    "display": "Drop down"
                  }
                ]
              }
            }
          ],
          "linkId": "367898136001",
          "enableWhen": [
            {
              "question": "101164469062",
              "operator": "=",
              "answerBoolean": true
            }
          ],
          "answerOption": [
            {
              "valueCoding": {
                "display": "Tabagisme actif"
              }
            },
            {
              "valueCoding": {
                "display": "Tabagisme sevré depuis + de 3 ans"
              }
            },
            {
              "valueCoding": {
                "display": "Tabagisme sevré au moment de l'incident"
              }
            }
          ]
        },
        {
          "type": "integer",
          "linkId": "187631376555",
          "text": "Nombre de paquets / ans",
          "enableWhen": [
            {
              "question": "101164469062",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        }
      ]
    },
    {
      "type": "group",
      "linkId": "7746070282139",
      "text": "Alcool",
      "item": [
        {
          "type": "boolean",
          "linkId": "749802088942",
          "text": "chronique"
        },
        {
          "type": "boolean",
          "linkId": "688902126785",
          "text": "Sevré",
          "enableWhen": [
            {
              "question": "749802088942",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "integer",
          "linkId": "790511635595",
          "text": "Nombre de verres / jours",
          "enableWhen": [
            {
              "question": "688902126785",
              "operator": "=",
              "answerBoolean": false
            },
            {
              "question": "749802088942",
              "operator": "=",
              "answerBoolean": true
            }
          ],
          "enableBehavior": "all"
        }
      ]
    },
    {
      "type": "group",
      "linkId": "8487110872266",
      "text": "Dyslipidémie et Diabète",
      "item": [
        {
          "type": "boolean",
          "linkId": "1391730154214",
          "text": "Hypercholestérolémie"
        },
        {
          "type": "boolean",
          "linkId": "35403850135",
          "text": "Diabète insulino Dépendant"
        },
        {
          "type": "boolean",
          "linkId": "1214047899327",
          "text": "Diabète non insulino Dépendant"
        }
      ]
    },
    {
      "type": "group",
      "linkId": "4191009498316",
      "text": "HTA",
      "item": [
        {
          "type": "boolean",
          "linkId": "5747971388810",
          "text": "Hypertension artérielle"
        },
        {
          "type": "boolean",
          "linkId": "9622897201905",
          "text": "Traitements anti-hypertenseurs"
        },
        {
          "type": "boolean",
          "linkId": "4be61289-2fd8-43dc-ba25-f0b2c124a86d",
          "text": "Inhibiteurs calciques",
          "enableWhen": [
            {
              "question": "9622897201905",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "dad45290-de75-4e51-9607-b11dd51440d8",
          "text": "Béta bloquants",
          "enableWhen": [
            {
              "question": "9622897201905",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "ad6f3e47-076f-41c5-c8cb-008a02fb9b6c",
          "text": "Diurétiques",
          "enableWhen": [
            {
              "question": "9622897201905",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "78574cad-0cf2-4c88-8a39-ddb04f8aba88",
          "text": "IEC ",
          "enableWhen": [
            {
              "question": "9622897201905",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "1c220ce5-7ab6-43c8-efa3-2de430156ee0",
          "text": "ARA2",
          "enableWhen": [
            {
              "question": "9622897201905",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "43e7c462-d03c-48ce-9195-cde7170f0e07",
          "text": "Anti-hypertenseurs centraux",
          "enableWhen": [
            {
              "question": "9622897201905",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "linkId": "f1666c7a-9968-496b-8a3c-aa0079f8ac47",
          "type": "string",
          "text": "Autres",
          "required": false,
          "enableWhen": [
            {
              "question": "9622897201905",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        }
      ]
    },
    {
      "linkId": "0af457a4-afa9-4413-89d3-3aa290f16306",
      "type": "group",
      "text": "Gestion de la coagulation",
      "required": false,
      "item": [
        {
          "type": "boolean",
          "linkId": "8667186506686",
          "text": "Trouble de la coagulation "
        },
        {
          "type": "boolean",
          "linkId": "6737d4dc-9009-4037-f371-778174cc6200",
          "text": "Traitements anti-coagulants"
        },
        {
          "type": "boolean",
          "linkId": "70c6c68c-c2de-4d2e-a3a8-7e550eb14295",
          "text": "AVK",
          "enableWhen": [
            {
              "question": "6737d4dc-9009-4037-f371-778174cc6200",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "d5d71493-5af2-451e-8fcb-d04d22cf306c",
          "text": "AOD",
          "enableWhen": [
            {
              "question": "6737d4dc-9009-4037-f371-778174cc6200",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "2badac2c-584b-4419-bf4e-29e3aab5b073",
          "text": "Héparine",
          "enableWhen": [
            {
              "question": "6737d4dc-9009-4037-f371-778174cc6200",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "linkId": "4f33e316-fe1d-4f8f-86e9-d6be24bf160f",
          "type": "string",
          "text": "Posologie",
          "required": false,
          "enableWhen": [
            {
              "question": "6737d4dc-9009-4037-f371-778174cc6200",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        }
      ]
    },
    {
      "type": "group",
      "linkId": "5858932492599",
      "text": "Pathologie cardio vasculaire ",
      "item": [
        {
          "type": "boolean",
          "linkId": "338399835362",
          "text": "Antécédent d'AVC hémorragique"
        },
        {
          "type": "boolean",
          "linkId": "510968399171",
          "text": "Antécédent d'AVC ischémique ou d'AIT"
        },
        {
          "type": "boolean",
          "linkId": "916970049081",
          "text": "Sténose carotidienne"
        },
        {
          "type": "boolean",
          "linkId": "254208235989",
          "text": "Anévrisme de l'aorte abdominale"
        },
        {
          "type": "boolean",
          "linkId": "644394216722",
          "text": "AOMI"
        },
        {
          "type": "boolean",
          "linkId": "4926287209739",
          "text": "Angioplastie",
          "enableWhen": [
            {
              "question": "644394216722",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "245694795304",
          "text": "Stenting",
          "enableWhen": [
            {
              "question": "644394216722",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "869674658561",
          "text": "Pontage femoral",
          "enableWhen": [
            {
              "question": "644394216722",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "linkId": "1e490bfa-2c9c-47ad-a672-9118e2757a94",
          "type": "choice",
          "text": "Latéralité",
          "required": false,
          "answerOption": [
            {
              "valueCoding": {
                "id": "75c25c93-b082-4ad2-965a-99039b0bea1e",
                "code": "droit",
                "system": "urn:uuid:4dae5314-a3cf-471d-f399-3eb3ef4c161f",
                "display": "Droit"
              }
            },
            {
              "valueCoding": {
                "id": "c1f350be-9cd2-41ef-cb36-498e6c8cdf93",
                "code": "gauche",
                "system": "urn:uuid:4dae5314-a3cf-471d-f399-3eb3ef4c161f",
                "display": "Gauche"
              }
            },
            {
              "valueCoding": {
                "id": "e8433735-8f96-43b4-f678-03a37cc01453",
                "code": "bilateral",
                "system": "urn:uuid:4dae5314-a3cf-471d-f399-3eb3ef4c161f",
                "display": "Bilateral"
              }
            }
          ],
          "enableWhen": [
            {
              "question": "869674658561",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "218274238727",
          "text": "Coronaropathie"
        },
        {
          "type": "boolean",
          "linkId": "8631246892524",
          "text": "Pontage coronarien",
          "enableWhen": [
            {
              "question": "218274238727",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "b8607d0f-1c28-4ba9-da85-97819afddc6b",
          "text": "Stenting",
          "enableWhen": [
            {
              "question": "218274238727",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "a4b40406-4600-4ce7-f20d-5bf590fd9385",
          "text": "Angioplastie",
          "enableWhen": [
            {
              "question": "218274238727",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "63edf78b-ed2c-48a9-909e-9e9a21d715df",
          "text": "Trouble du rythme"
        },
        {
          "type": "boolean",
          "linkId": "36739ff4-772a-4054-8377-4649ba1160e4",
          "text": "Cardioversion électrique",
          "enableWhen": [
            {
              "question": "63edf78b-ed2c-48a9-909e-9e9a21d715df",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "be5a5af4-ad22-4d0f-8158-b4227aa27357",
          "text": "Ablation par cathéter",
          "enableWhen": [
            {
              "question": "63edf78b-ed2c-48a9-909e-9e9a21d715df",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        }
      ]
    },
    {
      "linkId": "801cd473-ae2f-491a-8819-30aca6cd3cc5",
      "type": "group",
      "text": "Gestion des anti-agrégants",
      "required": false,
      "item": [
        {
          "type": "boolean",
          "linkId": "68755fca-94a7-497c-89de-39e82cc70682",
          "text": "Traitements anti-agrégants"
        },
        {
          "type": "boolean",
          "linkId": "4a571e09-5d0c-4901-9ac9-cd7829b4036a",
          "text": "Aspirine",
          "enableWhen": [
            {
              "question": "68755fca-94a7-497c-89de-39e82cc70682",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "0f6e957e-879e-45b1-adb5-7f53f5a85c2f",
          "text": "Plavix",
          "enableWhen": [
            {
              "question": "68755fca-94a7-497c-89de-39e82cc70682",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "7cfb2bd4-c8e7-4382-897f-ca73e40efc6a",
          "text": "Brilique",
          "enableWhen": [
            {
              "question": "68755fca-94a7-497c-89de-39e82cc70682",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "c25a94c0-2507-4085-a0ef-ed3157425e99",
          "text": "Cangrelor",
          "enableWhen": [
            {
              "question": "68755fca-94a7-497c-89de-39e82cc70682",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "25ef1a8f-1b91-4239-a455-678fdf675872",
          "text": "Prasugrel",
          "enableWhen": [
            {
              "question": "68755fca-94a7-497c-89de-39e82cc70682",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "linkId": "df65da82-f4a1-4693-8d07-8a46664ee3a1",
          "type": "string",
          "text": "Posologie",
          "required": false,
          "enableWhen": [
            {
              "question": "68755fca-94a7-497c-89de-39e82cc70682",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        }
      ]
    },
    {
      "linkId": "de2c8558-92fd-45ce-b52b-a3dc6a7fe320",
      "type": "group",
      "text": "Gestion des anti-angineux",
      "required": false,
      "item": [
        {
          "type": "boolean",
          "linkId": "4866166883283",
          "text": "Sous médication anti-angineuse"
        },
        {
          "type": "boolean",
          "linkId": "1f86fdca-c5f8-48d4-82a4-ed621d83dd19",
          "text": "Trinitine",
          "enableWhen": [
            {
              "question": "4866166883283",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "linkId": "ce63f605-b7df-48f2-8032-c3e14b7e7bf4",
          "type": "string",
          "text": "Autre",
          "required": false,
          "enableWhen": [
            {
              "question": "4866166883283",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "linkId": "d9e28aea-09eb-4923-ee26-354d0f9be5cd",
          "type": "string",
          "text": "Posologie",
          "required": false,
          "enableWhen": [
            {
              "question": "4866166883283",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        }
      ]
    },
    {
      "type": "boolean",
      "linkId": "61716947507",
      "text": "Antécédant de traumatisme crânien "
    },
    {
      "type": "boolean",
      "linkId": "fce05ce4-bf9e-49f1-8642-c18fb482e701",
      "text": "Chirurgie recente craniale ou cerebrale"
    },
    {
      "type": "boolean",
      "linkId": "fcbc5c72-e036-4db7-81ea-c7674c998689",
      "text": "Antécédant de traumatisme nasale"
    },
    {
      "type": "boolean",
      "linkId": "6147493018859",
      "text": "Antécédant de thrombose veineuse cérébrale"
    },
    {
      "type": "boolean",
      "linkId": "4626427211110",
      "text": "Sténose veineuse cérébrale"
    },
    {
      "linkId": "0f2b629b-7e47-4784-8f6f-71af188d3f50",
      "type": "group",
      "text": "Antécédants familiaux en rapport avec le motif de passage",
      "required": false,
      "item": [
        {
          "type": "boolean",
          "linkId": "340424568542",
          "text": "1er degré (père/mère, frère/sœur, enfants)"
        },
        {
          "type": "integer",
          "linkId": "234668637437",
          "text": "Nombre",
          "enableWhen": [
            {
              "question": "340424568542",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        },
        {
          "type": "boolean",
          "linkId": "3999783084778",
          "text": "2d degré (oncles/tantes, cousins, Gd-parents) "
        },
        {
          "type": "integer",
          "linkId": "264025292554",
          "text": "Nombre",
          "enableWhen": [
            {
              "question": "3999783084778",
              "operator": "=",
              "answerBoolean": true
            }
          ]
        }
      ]
    },
    {
      "linkId": "91882144-0930-4f41-86f5-ea9a3a8258d7",
      "type": "group",
      "text": "Contexte génétique",
      "required": false,
      "item": [
        {
          "type": "boolean",
          "linkId": "104422542240",
          "text": "Syndrome vasculaire d'Ehlers-Danlos"
        },
        {
          "type": "boolean",
          "linkId": "7519712968523",
          "text": "Syndrome de Marfan"
        },
        {
          "type": "boolean",
          "linkId": "5193436007814",
          "text": "Syndrome de Loeys-Dietz"
        },
        {
          "type": "boolean",
          "linkId": "9004503279748",
          "text": "Syndrome de Turner"
        },
        {
          "type": "boolean",
          "linkId": "74271973-0df2-4060-8698-a37fae9a7667",
          "text": "Syndrome de Rendu-Osler-Weber (Télangiectasie Hémorragique Héréditaire)"
        },
        {
          "type": "boolean",
          "linkId": "4954583577619",
          "text": "Dysplasie Fibromusculaire (FMD)"
        },
        {
          "type": "boolean",
          "linkId": "498660082672",
          "text": "Drépanocytose"
        },
        {
          "type": "boolean",
          "linkId": "f25b293a-b797-4171-8b8e-04f82cc3294f",
          "text": "Hémophilie"
        },
        {
          "type": "boolean",
          "linkId": "911750704106",
          "text": "Maladie constitutionnelle de la paroi vasculaire"
        },
        {
          "type": "boolean",
          "linkId": "d37787d0-bc07-473a-8637-f4c5c2aa8827",
          "text": "Polykystose Rénale Autosomique Dominante"
        },
        {
          "linkId": "a939515e-cbdc-4741-8367-a380c06f643b",
          "type": "string",
          "text": "maladie de Behcet",
          "required": false
        },
        {
          "linkId": "b6f73583-9da8-45bf-8df8-d03e50ba9090",
          "type": "string",
          "text": "Autre",
          "required": false
        }
      ]
    },
    {
      "type": "group",
      "linkId": "4541200765302",
      "text": "Autres antécédants ",
      "item": [
        {
          "type": "boolean",
          "linkId": "050be447-0e03-4763-eebf-eccc644a5030",
          "text": "Syndrome de Wyburn-Mason/ Bonnet-Dechaume-Blanc"
        },
        {
          "type": "boolean",
          "linkId": "3973624496820",
          "text": "Maladie parodontale gingivale, dentaire"
        },
        {
          "type": "boolean",
          "linkId": "7761058841639",
          "text": "Cancer solide"
        },
        {
          "type": "boolean",
          "linkId": "3529174317714",
          "text": "Hémopathie maligne"
        },
        {
          "type": "boolean",
          "linkId": "2182645325877",
          "text": "Maladie du système ou auto-immune"
        },
        {
          "type": "boolean",
          "linkId": "81411164-830b-4e71-f996-67bbb615737b",
          "text": "Endocardite infectieuse"
        },
        {
          "linkId": "4fa834ea-cd9e-46dc-8fe5-1677e76e65e0",
          "type": "string",
          "text": "Autre",
          "required": false
        },
        {
          "linkId": "52f74860-d225-4b86-9dc5-a54ce0279423",
          "type": "string",
          "text": "HTIC",
          "required": false
        }
      ]
    }
  ]
}
  ''';
}

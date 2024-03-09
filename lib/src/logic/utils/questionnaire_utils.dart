import 'package:fhir/r4.dart';

extension QuestionnaireUtils on Questionnaire {
  FhirCanonical get asFhirCanonical =>
      FhirCanonical('${R4ResourceType.Questionnaire.name}/$fhirId');
  static const sampleGeneric = '''
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
      "linkId": "1",
      "text": "Your full name",
      "type": "string",
      "required": true
    },
    {
      "linkId": "2",
      "text": "Date of birth",
      "type": "date"
    },
    {
      "linkId": "3",
      "text": "Do you have any allergies?",
      "type": "boolean"
    },
    {
      "linkId": "4",
      "text": "Please specify your gender",
      "required": true,
      "type": "choice",
      "answerOption": [
        {"valueCoding": {"code": "male", "display": "Male"}},
        {"valueCoding": {"code": "female", "display": "Female"}},
        {"valueCoding": {"code": "other", "display": "Other"}},
        {"valueCoding": {"code": "unknown", "display": "Prefer not to say"}}
      ]
    },
    {
      "linkId": "5",
      "text": "List your current medications",
      "type": "open-choice",
      "answerOption": [
        {"valueCoding": {"code": "med1", "display": "Medication A"}},
        {"valueCoding": {"code": "med2", "display": "Medication B"}}
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
      "text": "Select your age range:",
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
      "text": "Blood Pressure (systolic/diastolic)",
      "type": "group",
      "item": [
        {
          "linkId": "8.1",
          "text": "Systolic (mmHg)",
          "type": "decimal"
        },
        {
          "linkId": "8.2",
          "text": "Diastolic (mmHg)",
          "type": "decimal"
        }
      ]
    },
    {
      "linkId": "9",
      "text": "Upload your recent lab results",
      "type": "attachment"
    },
    {
      "linkId": "10",
      "text": "Describe your symptoms",
      "type": "text",
      "maxLength": 160
    },
    {
      "linkId": "11",
      "text": "Appointment date and time",
      "type": "dateTime"
    },
    {
      "linkId": "12",
      "text": "Time since last meal",
      "type": "quantity",
      "item": [
        {
          "linkId": "11.1",
          "text": "Hours",
          "type": "integer"
        }
      ]
    },
    {
      "linkId": "13",
      "text": "Select your ethnic background",
      "type": "choice",
      "answerValueSet": "#ethnicBackgroundValueSet",
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
      ]
    }
  ]
}
''';
  static const samplePrapare = '''
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
  static const samplePHQ9 = '''
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
  static const sampleGAD7 = '''
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
}

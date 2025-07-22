import 'package:fhir_r4/fhir_r4.dart';

extension QuestionnaireItemTypeEnumX on QuestionnaireItemTypeEnum {
  bool get isGroup => this == QuestionnaireItemTypeEnum.group;
  bool get isDisplay => this == QuestionnaireItemTypeEnum.display_;
  bool get isQuestion => this == QuestionnaireItemTypeEnum.question;
  bool get isBoolean => this == QuestionnaireItemTypeEnum.boolean;
  bool get isDecimal => this == QuestionnaireItemTypeEnum.decimal;
  bool get isInteger => this == QuestionnaireItemTypeEnum.integer;
  bool get isDate => this == QuestionnaireItemTypeEnum.date;
  bool get isDateTime => this == QuestionnaireItemTypeEnum.dateTime;
  bool get isTime => this == QuestionnaireItemTypeEnum.time;
  bool get isString => this == QuestionnaireItemTypeEnum.string;
  bool get isText => this == QuestionnaireItemTypeEnum.text;
  bool get isUrl => this == QuestionnaireItemTypeEnum.url;
  bool get isChoice => this == QuestionnaireItemTypeEnum.choice;
  bool get isOpenChoice => this == QuestionnaireItemTypeEnum.openChoice;
  bool get isAttachment => this == QuestionnaireItemTypeEnum.attachment;
  bool get isReference => this == QuestionnaireItemTypeEnum.reference;
  bool get isQuantity => this == QuestionnaireItemTypeEnum.quantity;
}

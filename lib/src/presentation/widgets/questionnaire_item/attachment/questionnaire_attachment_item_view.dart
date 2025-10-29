import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/fhir_questionnaire.dart';
import 'package:flutter/material.dart';

/// Created by luis901101 on 3/22/24.
class QuestionnaireAttachmentItemView extends QuestionnaireItemView {
  final Future<Attachment?> Function()? onAttachmentLoaded;
  QuestionnaireAttachmentItemView({
    super.key,
    CustomValueController<Attachment>? controller,
    required super.item,
    required this.onAttachmentLoaded,
    super.enableWhenController,
  }) : super(
         controller:
             controller ??
             CustomValueController<Attachment>(focusNode: FocusNode()),
       );

  @override
  State createState() => QuestionnaireAttachmentItemViewState();
}

class QuestionnaireAttachmentItemViewState
    extends QuestionnaireItemViewState<QuestionnaireAttachmentItemView> {
  bool isLoading = false;
  @override
  CustomValueController<Attachment> get controller =>
      super.controller as CustomValueController<Attachment>;
  Attachment? get value => controller.value;
  set value(Attachment? value) => controller.value = value;

  @override
  void initState() {
    super.initState();
    if (value == null) {
      final initial = item.initial
          ?.firstWhereOrNull((item) => item.valueAttachment != null)
          ?.valueAttachment;
      value = initial;
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          child: ClipRect(
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              height: value == null ? 0 : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Icon(
                    (value?.contentType?.value?.endsWith('jpeg') ?? false)
                        ? Icons.image
                        : Icons.file_copy,
                    color: theme.disabledColor,
                    size: 96,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 48.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: mediaQuery.size.width.percent(
                      value == null ? 80 : 40,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onBtnUpload,
                      icon: Icon(
                        value == null ? Icons.upload_rounded : Icons.refresh,
                      ),
                      label: Text(
                        value == null
                            ? QuestionnaireLocalization
                                  .instance
                                  .localization
                                  .btnUpload
                            : QuestionnaireLocalization
                                  .instance
                                  .localization
                                  .btnChange,
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: SizedBox(width: value == null ? 0 : 8),
              ),
              Flexible(
                flex: value == null ? 0 : 1,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: value == null
                        ? 0
                        : mediaQuery.size.width.percent(40),
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onBtnRemove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        iconColor: theme.colorScheme.onError,
                      ),
                      icon: const Icon(Icons.delete_forever_rounded),
                      label: Text(
                        QuestionnaireLocalization
                            .instance
                            .localization
                            .btnRemove,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> onBtnUpload() async {
    setState(() {
      isLoading = true;
    });
    final temp = await widget.onAttachmentLoaded?.call();
    setState(() {
      if (temp != null) {
        value = temp;
      }
      isLoading = false;
    });
  }

  Future<void> onBtnRemove() async {
    value = null;
    setState(() {});
  }
}

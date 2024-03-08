import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Created by luis901101 on 3/7/24.
class QuestionnaireLoadingView extends StatelessWidget {
  const QuestionnaireLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shimmerFieldRadius = (theme.inputDecorationTheme.border
            is OutlineInputBorder)
        ? (theme.inputDecorationTheme.border as OutlineInputBorder).borderRadius
        : const BorderRadius.all(Radius.circular(4));
    final baseColor = theme.brightness == Brightness.light
        ? Colors.grey.shade300
        : const Color(0xFF797770);
    final highlightColor = theme.brightness == Brightness.light
        ? Colors.grey.shade100
        : const Color(0xFF939089);
    final shimmerDecoration = BoxDecoration(
      borderRadius: shimmerFieldRadius,
      color: Colors.white,
    );
    final shimmerGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.centerRight,
        colors: <Color>[
          baseColor,
          baseColor,
          highlightColor,
          baseColor,
          baseColor,
        ],
        stops: const <double>[
          0.0,
          0.35,
          0.5,
          0.65,
          1.0
        ]);
    final random = Random();
    return ListView.separated(
        primary: false,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        separatorBuilder: (context, index) => const SizedBox(height: 20.0),
        itemBuilder: (context, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    bottom: 8.0,
                  ),
                  child: Shimmer(
                    gradient: shimmerGradient,
                    child: Container(
                      width: 100.0 + random.nextInt(200),
                      height: 18,
                      decoration: shimmerDecoration,
                    ),
                  ),
                ),
                Shimmer(
                  gradient: shimmerGradient,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: shimmerDecoration,
                  ),
                ),
              ],
            ),
        itemCount: 20);
  }
}

import 'package:eqmonitor/common/component/button/action_button.dart';
import 'package:eqmonitor/feature/setup/component/background_image.dart';
import 'package:eqmonitor/feature/setup/component/earthquake_restriction.dart';
import 'package:flutter/material.dart';

class QuickGuideAboutEewPage extends StatelessWidget {
  const QuickGuideAboutEewPage({required this.onNext, super.key});
  final void Function() onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SetupBackgroundImageWidget(
        child: Column(
          children: [
            // 画面上部のタイトル
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '4つの注意事項',
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'EQMonitorでは、緊急地震速報をはじめとする様々な地震情報をお伝えします。\n'
                'ただし、以下の点に注意してください。',
                style: theme.textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: EarthquakeRestrictionWidget(),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ActionButton(
                isEnabled: true,
                onPressed: onNext,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        '次へ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

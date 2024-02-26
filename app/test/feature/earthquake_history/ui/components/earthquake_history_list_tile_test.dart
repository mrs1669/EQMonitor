// ignore_for_file: scoped_providers_should_specify_dependencies
import 'package:eqapi_types/eqapi_types.dart';
import 'package:eqmonitor/core/provider/config/theme/intensity_color/intensity_color_provider.dart';
import 'package:eqmonitor/core/provider/config/theme/intensity_color/model/intensity_color_model.dart';
import 'package:eqmonitor/core/provider/jma_code_table_provider.dart';
import 'package:eqmonitor/feature/earthquake_history/data/model/earthquake_v1_extended.dart';
import 'package:eqmonitor/feature/earthquake_history/ui/components/earthquake_history_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jma_code_table_types/jma_code_table_types.dart';

void main() async {
  const baseV1 = EarthquakeV1(
    eventId: 20240102235959,
    status: '通常',
  );

  Widget buildWidget(Widget child) => ProviderScope(
        overrides: [
          jmaCodeTableProvider.overrideWithValue(
            JmaCodeTable(
              areaEpicenter: AreaEpicenter(
                items: [
                  AreaEpicenter_AreaEpicenterItem(
                    code: '100',
                    name: '石狩地方北部',
                  ),
                ],
              ),
              areaEpicenterDetail: AreaEpicenterDetail(
                items: [
                  AreaEpicenterDetail_AreaEpicenterDetailItem(
                    code: '1001',
                    name: '米国、アラスカ州中央部',
                  ),
                ],
              ),
            ),
          ),
          intensityColorProvider.overrideWith(FakeIntensityColor.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      );

  group(
    'マグニチュード',
    () {
      testWidgets(
        'マグニチュードがある場合、マグニチュードが表示されること',
        (WidgetTester tester) async {
          // Arrange
          final v1Extended = EarthquakeV1Extended(
            earthquake: baseV1.copyWith(
              magnitude: 5.1,
            ),
            maxIntensityRegionNames: null,
          );
          // Act
          await tester.pumpWidget(
            buildWidget(
              EarthquakeHistoryListTile(
                item: v1Extended,
              ),
            ),
          );
          // Assert
          expect(find.text('M5.1'), findsOneWidget);
        },
      );
      testWidgets(
        'マグニチュードが整数の場合、小数第1位まで表示されること',
        (WidgetTester tester) async {
          // Arrange
          final v1Extended = EarthquakeV1Extended(
            earthquake: baseV1.copyWith(
              magnitude: 5,
            ),
            maxIntensityRegionNames: null,
          );
          // Act
          await tester.pumpWidget(
            buildWidget(
              EarthquakeHistoryListTile(
                item: v1Extended,
              ),
            ),
          );
          // Assert
          expect(find.text('M5.0'), findsOneWidget);
        },
      );
      testWidgets(
        'マグニチュードが小数第2位以降ある場合、四捨五入されて小数第1位まで表示されること(繰り下げケース)',
        (WidgetTester tester) async {
          // Arrange
          final v1Extended = EarthquakeV1Extended(
            earthquake: baseV1.copyWith(
              magnitude: 5.123,
            ),
            maxIntensityRegionNames: null,
          );
          // Act
          await tester.pumpWidget(
            buildWidget(
              EarthquakeHistoryListTile(
                item: v1Extended,
              ),
            ),
          );
          // Assert
          expect(find.text('M5.1'), findsOneWidget);
        },
      );
      testWidgets(
        'マグニチュードが小数第2位以降ある場合、四捨五入されて小数第1位まで表示されること(繰り上げケース)',
        (WidgetTester tester) async {
          // Arrange
          final v1Extended = EarthquakeV1Extended(
            earthquake: baseV1.copyWith(
              magnitude: 5.162,
            ),
            maxIntensityRegionNames: null,
          );
          // Act
          await tester.pumpWidget(
            buildWidget(
              EarthquakeHistoryListTile(
                item: v1Extended,
              ),
            ),
          );
          // Assert
          expect(find.text('M5.2'), findsOneWidget);
        },
      );
    },
  );
}

class FakeIntensityColor extends IntensityColor {
  @override
  IntensityColorModel build() => IntensityColorModel.eqmonitor();
}

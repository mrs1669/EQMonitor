import 'package:collection/collection.dart';
import 'package:eqapi_types/eqapi_types.dart';
import 'package:eqapi_types/lib.dart';
import 'package:eqmonitor/core/provider/jma_code_table_provider.dart';
import 'package:eqmonitor/core/provider/jma_parameter/jma_parameter.dart';
import 'package:eqmonitor/feature/earthquake_history/data/model/earthquake_v1_extended.dart';
import 'package:eqmonitor/feature/earthquake_history/ui/components/earthquake_history_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Earthquake History List Tile',
  type: EarthquakeHistoryListTile,
)
Widget earthquakeHistoryListTile(BuildContext context) {
  return const Scaffold(
    body: _Body(),
  );
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jmaParameter = ref.watch(jmaParameterProvider);
    final jmaParameterWidget = jmaParameter.whenOrNull(
      error: (error, stackTrace) => Text('Error: $error'),
    );
    if (jmaParameterWidget != null) {
      return jmaParameterWidget;
    }
    final earthquakeParameter = jmaParameter.requireValue.earthquake;

    final codeTable = ref.watch(jmaCodeTableProvider);
    final epicenters = codeTable.areaEpicenter.items;
    final detailedEpicenters = codeTable.areaEpicenterDetail.items;
    final v1 = EarthquakeV1(
      arrivalTime: context.knobs.dateTimeOrNull(
        label: 'arrival_time',
        start: DateTime(2000),
        end: DateTime(2100),
        initialValue: DateTime.now(),
        description: '検出時刻',
      ),
      originTime: context.knobs.dateTimeOrNull(
        label: 'origin_time',
        start: DateTime(2000),
        end: DateTime(2100),
        initialValue: DateTime.now(),
        description: '発生時刻',
      ),
      eventId: 2024010203042359,
      status: '通常',
      depth: context.knobs.int.input(
        label: 'depth',
        initialValue: 10,
        description: '震源の深さ\n(0 -> "ごく浅い", 700 -> "700km以上")',
      ),
      epicenterCode: context.knobs.listOrNull(
        options: epicenters.map((e) => int.parse(e.code)).toList(),
        label: 'epicenter_code',
        labelBuilder: (value) => value.toString(),
        description: '震央地名(コード表41: AreaEpicenter)より',
      ),
      epicenterDetailCode: context.knobs.listOrNull(
        options: detailedEpicenters.map((e) => int.parse(e.code)).toList(),
        label: 'epicenter_detail_code',
        description: '詳細震央地名(コード表43: AreaEpicenterDetail)より\n(遠地地震で利用)',
        initialOption: null,
        labelBuilder: (value) => value.toString(),
      ),
      magnitude: context.knobs.doubleOrNull.slider(
        label: 'magnitude',
        initialValue: 5,
        max: 8,
        description: 'マグニチュード',
      ),
      maxIntensity: context.knobs.listOrNull(
        options: JmaIntensity.values,
        label: 'max_intensity',
        initialOption: JmaIntensity.fiveLower,
        labelBuilder: (value) => '震度$value',
        description: '最大震度',
      ),
    );
    return Material(
      child: EarthquakeHistoryListTile(
        item: EarthquakeV1Extended(
          earthquake: v1,
          maxIntensityRegionNames: [
            context.knobs.listOrNull(
              label: '最大震度観測地域',
              description: '一次細分化地域',
              options: earthquakeParameter.regions.map((e) => e.name).toList(),
              labelBuilder: (data) => data.toString(),
            ),
          ].whereNotNull().toList(),
        ),
        onTap: () {},
      ),
    );
  }
}

class EarthquakeV1Knob extends Knob<EarthquakeV1> {
  EarthquakeV1Knob({
    required super.label,
    required super.initialValue,
  });

  @override
  List<Field> get fields => [
        IntInputField(
          name: 'event_id',
          initialValue: 20211020123456,
        ),
        StringField(
          name: 'status',
          initialValue: '通常',
        ),
        DoubleInputField(
          name: 'latitude',
          initialValue: 35,
        ),
        DoubleInputField(
          name: 'longitude',
          initialValue: 135,
        ),
        IntInputField(
          name: 'epicenter_code',
          initialValue: 101,
        ),
        DateTimeField(
          name: 'arrival_time',
          start: DateTime(2000),
          end: DateTime(2100),
          initialValue: DateTime.now(),
        ),
        DateTimeField(
          name: 'origin_time',
          start: DateTime(2000),
          end: DateTime(2100),
          initialValue: DateTime.now(),
        ),
        DoubleInputField(
          name: 'magnitude',
          initialValue: null,
        ),
        IntInputField(
          name: 'depth',
          initialValue: null,
        ),
        ListField<JmaIntensity>(
          name: 'max_intensity',
          values: JmaIntensity.values,
          initialValue: JmaIntensity.fiveLower,
          labelBuilder: (value) => value.type,
        ),
        ListField<JmaLgIntensity>(
          name: 'max_lpgm_intensity',
          values: JmaLgIntensity.values,
          initialValue: JmaLgIntensity.zero,
          labelBuilder: (value) => value.type,
        ),
      ];

  @override
  EarthquakeV1 valueFromQueryGroup(Map<String, String> group) => EarthquakeV1(
        eventId: valueOf('event_id', group)!,
        status: valueOf('status', group)!,
        latitude: valueOf('latitude', group),
        longitude: valueOf('longitude', group),
        arrivalTime: valueOf('arrival_time', group),
        originTime: valueOf('origin_time', group),
        depth: valueOf('depth', group),
        epicenterCode: valueOf('epicenter_code', group),
        intensityCities: [],
        intensityPrefectures: [],
        intensityRegions: [],
        intensityStations: [],
        magnitude: valueOf('magnitude', group),
        maxIntensity: valueOf('max_intensity', group),
        maxLpgmIntensity: valueOf('max_lpgm_intensity', group),
      );
}

extension EarthquakeV1KnobBuilder on KnobsBuilder {
  EarthquakeV1 earthquakeV1({
    required String label,
    EarthquakeV1 initialValue = const EarthquakeV1(
      eventId: 20211020123456,
      status: '通常',
      latitude: 35,
      longitude: 135,
      depth: 10,
      epicenterCode: 101,
      intensityCities: [],
      intensityPrefectures: [],
      intensityRegions: [],
      intensityStations: [],
      magnitude: 5,
      maxIntensity: JmaIntensity.fiveLower,
    ),
  }) =>
      onKnobAdded(
        EarthquakeV1Knob(
          label: label,
          initialValue: initialValue,
        ),
      )!;
}
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:eqapi_types/eqapi_types.dart' as eqapi_types;
import 'package:eqapi_types/eqapi_types.dart';
import 'package:eqapi_types/lib.dart';
import 'package:eqmonitor/core/provider/capture/intensity_icon_render.dart';
import 'package:eqmonitor/core/provider/config/theme/intensity_color/intensity_color_provider.dart';
import 'package:eqmonitor/core/provider/config/theme/intensity_color/model/intensity_color_model.dart';
import 'package:eqmonitor/feature/earthquake_history/model/state/earthquake_history_item.dart';
import 'package:eqmonitor/feature/home/features/eew/provider/eew_alive_telegram.dart';
import 'package:eqmonitor/feature/home/features/kmoni/viewmodel/kmoni_view_model.dart';
import 'package:eqmonitor/feature/home/features/kmoni_observation_points/model/kmoni_observation_point.dart';
import 'package:eqmonitor/feature/home/features/travel_time/provider/travel_time_provider.dart';
import 'package:eqmonitor/feature/map_libre/provider/map_style.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lat_lng/lat_lng.dart' as lat_lng;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_map_viewmodel.freezed.dart';
part 'main_map_viewmodel.g.dart';

@Riverpod(dependencies: [EewAliveTelegram])
class MainMapViewModel extends _$MainMapViewModel {
  @override
  void build() {
    ref
      ..listen(
        kmoniViewModelProvider,
        (_, value) {
          final analyzedPoints = value.analyzedPoints;
          if (analyzedPoints == null) {
            return;
          }
          _onKmoniStateChanged(analyzedPoints);
        },
      )
      ..listen(
        eewAliveTelegramProvider,
        (_, value) => _onEewStateChanged(value ?? []),
      );
  }

  MaplibreMapController? _controller;

  /// 実行前に `travelTimeDepthMapProvider`, `hypocenterIconRenderProvider`,
  /// `hypocenterLowPreciseIconRenderProvider` が初期化済みであることを確認すること
  Future<void> onMapControllerRegistered() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    _kmoniObservationPointService = _KmoniObservationPointService(
      controller: controller,
    );
    _eewHypocenterService = _EewHypocenterService(
      controller: controller,
    );
    _eewPsWaveService = _EewPsWaveService(
      controller: controller,
      travelTimeMap: ref.read(travelTimeDepthMapProvider).requireValue,
    );
    _eewEstimatedIntensityService = _EewEstimatedIntensityService(
      controller: controller,
    );
    await (
      _kmoniObservationPointService!.init(),
      _eewHypocenterService!.init(
        hypocenterIcon: ref.read(hypocenterIconRenderProvider)!,
        hypocenterLowPreciseIcon:
            ref.read(hypocenterLowPreciseIconRenderProvider)!,
      ),
      _eewPsWaveService!.init(),
      _eewEstimatedIntensityService!.init(
        ref.read(intensityColorProvider),
      ),
    ).wait;

    ref.onDispose(() async {
      await (
        _kmoniObservationPointService!.dispose(),
        _eewHypocenterService!.dispose(),
        _eewPsWaveService!.dispose(),
        _eewEstimatedIntensityService!.dispose(),
      ).wait;
    });
  }

  Future<void> onTick(DateTime now) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    if (_eewPsWaveService == null || _eewHypocenterService == null) {
      return;
    }
    try {
      await (
        _eewPsWaveService!.tick(now: now),
        _eewHypocenterService!.tick(),
      ).wait;
    } catch (e) {}
  }

  // *********** EEW Related ***********
  bool _isEewInitialized = false;

  _EewHypocenterService? _eewHypocenterService;
  _EewPsWaveService? _eewPsWaveService;
  _EewEstimatedIntensityService? _eewEstimatedIntensityService;

  Future<void> _onEewStateChanged(List<EarthquakeHistoryItem> values) async {
    // 初期化が終わっていない場合は何もしない
    if (!_isEewInitialized) {
      return;
    }
    final aliveBodies = values
        .map((e) => e.latestEew)
        .whereType<TelegramVxse45Body>()
        .where((e) => e.hypocenter != null && e.hypocenter!.coordinate != null)
        .toList();
    final normalEews = aliveBodies
        .where((e) => !(e.isIpfOnePoint || e.isLevelEew || e.isPlum))
        .toList();
    _eewPsWaveService!.update(normalEews);
    await _eewHypocenterService!.update(aliveBodies);
    final transformed = _EewEstimatedIntensityService.transform(
      aliveBodies
          .map((e) => e.regions)
          .whereType<List<EewRegion>>()
          .flattened
          .toList(),
    );
    await _eewEstimatedIntensityService!.update(transformed);
  }

  // *********** Kyoshin Monitor Related ***********
  _KmoniObservationPointService? _kmoniObservationPointService;
  Future<void> _onKmoniStateChanged(
    List<AnalyzedKmoniObservationPoint> values,
  ) async {
    if (_controller == null) {
      return;
    }
    final service = _KmoniObservationPointService(
      controller: _controller!,
    );
    await service.update(values);
  }

  Future<void> startUpdateEew() async {
    if (_isEewInitialized || _controller == null) {
      return;
    }

    _isEewInitialized = true;
    // 初回EEW State更新
    await _onEewStateChanged(
      ref.read(eewAliveTelegramProvider) ?? [],
    );
  }

  // *********** Utilities ***********
  Future<void> updateImage({
    required String name,
    required Uint8List bytes,
  }) async =>
      _controller?.addImage(name, bytes);

  // ignore: use_setters_to_change_properties
  void registerMapController(MaplibreMapController controller) =>
      // ignore: void_checks
      _controller = controller;

  Future<void> moveCameraToDefaultPosition({
    double bottom = 0,
  }) async {
    if (_controller == null) {
      throw Exception('MaplibreMapController is null');
    }
    await _controller!.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: const LatLng(30, 128.8),
          northeast: const LatLng(45.8, 145.1),
        ),
        bottom: bottom,
      ),
    );
  }

  Future<void> animateCameraToDefaultPosition({
    double bottom = 50,
    Duration duration = const Duration(
      milliseconds: 250,
    ),
  }) async {
    final controller = _controller;
    if (controller == null) {
      throw Exception('MaplibreMapController is null');
    }
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: const LatLng(30, 128.8),
          northeast: const LatLng(45.8, 145.1),
        ),
        bottom: bottom,
        left: 10,
        right: 10,
        top: 10,
      ),
      duration: duration,
    );
  }
}

class _KmoniObservationPointService {
  _KmoniObservationPointService({required this.controller});

  final MaplibreMapController controller;

  Future<void> init() async {
    await dispose();
    await controller.addGeoJsonSource(
      layerId,
      {
        'type': 'FeatureCollection',
        'features': <void>[],
      },
    );
    await controller.addCircleLayer(
      layerId,
      layerId,
      const CircleLayerProperties(
        circleRadius: [
          'interpolate',
          ['linear'],
          ['zoom'],
          3,
          1,
          10,
          10,
        ],
        circleColor: [
          'get',
          'color',
        ],
      ),
      sourceLayer: layerId,
      belowLayerId: BaseLayer.areaForecastLocalELine.name,
    );
  }

  Future<void> update(List<AnalyzedKmoniObservationPoint> points) =>
      controller.setGeoJsonSource(
        layerId,
        createGeoJson(points),
      );

  Future<void> dispose() async {
    await controller.removeLayer(layerId);
    await controller.removeSource(layerId);
  }

  static const String layerId = 'kmoni-circle';

  Map<String, dynamic> createGeoJson(
    List<AnalyzedKmoniObservationPoint> points,
  ) =>
      {
        'type': 'FeatureCollection',
        'features': points
            .where((e) => e.intensityValue != null)
            .map(
              (e) => {
                'type': 'Feature',
                'geometry': {
                  'type': 'Point',
                  'coordinates': [e.point.latLng.lon, e.point.latLng.lat],
                },
                'properties': {
                  'color': e.intensityValue != null
                      ? e.intensityColor?.toHexStringRGB()
                      : null,
                  'intensity': e.intensityValue,
                },
              },
            )
            .toList(),
      };
}

class _EewEstimatedIntensityService {
  _EewEstimatedIntensityService({required this.controller});

  final MaplibreMapController controller;
  Future<void> init(IntensityColorModel colorModel) async {
    await dispose();
    await [
      // 各予想震度ごとにFill Layerを追加
      for (final intensity in JmaForecastIntensity.values)
        controller.addLayer(
          'eqmonitor_map',
          getFillLayerId(intensity),
          FillLayerProperties(
            fillColor: colorModel
                .fromJmaForecastIntensity(intensity)
                .background
                .toHexStringRGB(),
          ),
          filter: [
            'in',
            'code',
            [
              'literal',
              <String>[
                '100',
                if (intensity == JmaForecastIntensity.four) '102',
              ],
            ]
          ],
          sourceLayer: 'areaForecastLocalE',
          //belowLayerId: 'areaForecastLocalEew_line',
        ),
    ].wait;
  }

  /// 予想震度を更新する
  /// [areas] は Map<予想震度, List<地域コード>>
  Future<void> update(Map<JmaForecastIntensity, List<String>> areas) => [
        for (final MapEntry(:key, :value) in areas.entries)
          controller.setFilter(
            getFillLayerId(key),
            [
              'in',
              'code',
              [
                'literal',
                value,
              ],
            ],
          ),
      ].wait;

  Future<void> dispose() => [
        for (final intensity in JmaForecastIntensity.values)
          controller.removeLayer(getFillLayerId(intensity)),
      ].wait;

  Future<void> onIntensityColorModelChanged(IntensityColorModel model) =>
      dispose().then(
        (_) => init(model),
      );
  static Map<JmaForecastIntensity, List<String>> transform(
    List<EewRegion> regions,
  ) {
    // 同じ地域をまとめる
    final regionsGrouped = regions.groupListsBy(
      (e) => e.code,
    );
    // 予想震度が最も大きいものを取り出す
    final regionsIntensityMax = <String, ForecastMaxInt>{};
    for (final entry in regionsGrouped.entries) {
      final max = entry.value
          .map((e) => e.forecastMaxInt)
          .whereType<ForecastMaxInt>()
          .reduce(
            (value, element) => value.toDisplayMaxInt().maxInt >
                    element.toDisplayMaxInt().maxInt
                ? value
                : element,
          );
      regionsIntensityMax[entry.key] = max;
    }
    // Map<予想震度, List<地域コード>> に変換する
    final regionsIntensityGrouped = <JmaForecastIntensity, List<String>>{};
    for (final entry in regionsIntensityMax.entries) {
      final key = entry.value.toDisplayMaxInt().maxInt;
      if (!regionsIntensityGrouped.containsKey(key)) {
        regionsIntensityGrouped[key] = [];
      }
      regionsIntensityGrouped[key]!.add(entry.key);
    }
    return regionsIntensityGrouped;
  }

  static String getFillLayerId(JmaForecastIntensity intensity) {
    final base = intensity.type
        .replaceAll('-', 'low')
        .replaceAll('+', 'high')
        .replaceAll('不明', 'unknown');
    return '$_EewEstimatedIntensityService-fill-$base';
  }
}

class _EewHypocenterService {
  _EewHypocenterService({required this.controller});

  final MaplibreMapController controller;

  bool hasInitialized = false;

  Future<void> init({
    required Uint8List hypocenterIcon,
    required Uint8List hypocenterLowPreciseIcon,
  }) async {
    await (
      controller.addImage(
        hypocenterIconId,
        hypocenterIcon,
      ),
      controller.addImage(
        hypocenterLowPreciseIconId,
        hypocenterLowPreciseIcon,
      ),
    ).wait;
    await controller.removeSource(sourceLayerId);
    await controller.addGeoJsonSource(
      sourceLayerId,
      createGeoJson([]),
    );

    // adding Symbol Layers
    await (
      controller.addSymbolLayer(
        sourceLayerId,
        hypocenterIconId,
        SymbolLayerProperties(
          iconImage: hypocenterIconId,
          iconSize: [
            'interpolate',
            ['linear'],
            ['zoom'],
            3,
            0.3,
            20,
            5,
          ],
          iconOpacity: [
            'interpolate',
            ['linear'],
            ['zoom'],
            6,
            1.0,
            10,
            0.5,
          ],
          iconAllowOverlap: true,
        ),
        filter: [
          '==',
          ['get', 'isLowPrecise'],
          false,
        ],
        sourceLayer: sourceLayerId,
      ),
      controller.addSymbolLayer(
        sourceLayerId,
        hypocenterLowPreciseIconId,
        SymbolLayerProperties(
          iconImage: hypocenterLowPreciseIconId,
          iconSize: [
            'interpolate',
            ['linear'],
            ['zoom'],
            3,
            0.3,
            20,
            5,
          ],
          iconOpacity: [
            'interpolate',
            ['linear'],
            ['zoom'],
            6,
            1.0,
            10,
            0.5,
          ],
          iconAllowOverlap: true,
        ),
        // where isLowPrecise == true
        filter: [
          '==',
          ['get', 'isLowPrecise'],
          true,
        ],
        sourceLayer: sourceLayerId,
      ),
    ).wait;
    hasInitialized = true;
  }

  Future<void> update(List<TelegramVxse45Body> items) =>
      controller.setGeoJsonSource(
        sourceLayerId,
        createGeoJson(items),
      );

  double _lastOpacity = 0;

  Future<void> tick() async {
    if (!hasInitialized) {
      return;
    }
    final milliseconds = DateTime.now().millisecondsSinceEpoch;
    if (milliseconds % 1000 < 500) {
      if (_lastOpacity == 1.0) {
        return;
      }
      _lastOpacity = 1.0;
      await controller.setLayerProperties(
        hypocenterIconId,
        const SymbolLayerProperties(
          iconOpacity: 1.0,
        ),
      );
    } else {
      if (_lastOpacity == 0.5) {
        return;
      }
      _lastOpacity = 0.5;
      await controller.setLayerProperties(
        hypocenterIconId,
        const SymbolLayerProperties(
          iconOpacity: 0.5,
        ),
      );
    }
  }

  Future<void> dispose() async {
    await controller.removeLayer(sourceLayerId);
    await controller.removeSource(sourceLayerId);
    hasInitialized = false;
  }

  static Map<String, dynamic> createGeoJson(List<TelegramVxse45Body> items) =>
      <String, dynamic>{
        'type': 'FeatureCollection',
        'features': items
            .map(
              (e) => {
                'type': 'Feature',
                'geometry': {
                  'type': 'Point',
                  'coordinates': [
                    e.hypocenter!.coordinate!.lon,
                    e.hypocenter!.coordinate!.lat,
                  ],
                },
                'properties': _EewHypocenterProperties(
                  depth: e.depth ?? 0,
                  magnitude: e.magnitude ?? 0,
                  isLowPrecise: e.isPlum || e.isIpfOnePoint || e.isLevelEew,
                ).toJson(),
              },
            )
            .toList(),
      };

  static String get hypocenterIconId => 'hypocenter';
  static String get hypocenterLowPreciseIconId => 'hypocenter-low-precise';

  static String get sourceLayerId => 'hypocenter';
}

class _EewPsWaveService {
  _EewPsWaveService({
    required this.controller,
    required this.travelTimeMap,
  }) : _children = (
          _EewPWaveLineService(controller: controller),
          _EewSWaveLineService(controller: controller),
          //  _EewPWaveFillService(controller: controller),
          // _EewSWaveFillService(controller: controller),
        );

  final MaplibreMapController controller;
  final TravelTimeDepthMap travelTimeMap;

  late final (
    _EewPWaveLineService,
    _EewSWaveLineService,
    // _EewPWaveFillService,
    // _EewSWaveFillService
  ) _children;

  Future<void> init() async {
    // datasource
    await controller.removeSource(sourceId);
    await controller.addGeoJsonSource(
      sourceId,
      createGeoJson([]),
    );
    // line
    await (
      _children.$1.init(),
      _children.$2.init(),
    ).wait;
    // fill
    // await _children.$3.init();
    //_children.$4.init(),
  }

  List<TelegramVxse45Body> _cachedEews = [];

  /// 表示するEEWが0件になってから GeoJSON Sourceを更新したかどうか
  bool didUpdatedSinceZero = false;

  Future<void> tick({
    required DateTime now,
  }) async {
    final results = <(TravelTimeResult, lat_lng.LatLng)>[];
    // 表示EEWが1件以上だったら、didUpdatedSinceZeroをfalseにする
    if (_cachedEews.isNotEmpty) {
      didUpdatedSinceZero = false;
    }
    // 表示EEWが0件 かつ GeoJSON Sourceを更新したことがある場合は何もしない
    if (_cachedEews.isEmpty && didUpdatedSinceZero) {
      return;
    }
    for (final eew in _cachedEews) {
      final hypocenter = eew.hypocenter?.coordinate;
      final depth = eew.depth;
      final originTime = eew.originTime;
      if (hypocenter == null || depth == null || originTime == null) {
        continue;
      }
      final travel = travelTimeMap.getTravelTime(
        depth,
        //  as sec
        now
                .difference(
                  originTime,
                )
                .inMicroseconds /
            1000 /
            1000,
      );
      results.add(
        (
          travel,
          hypocenter,
        ),
      );
    }
    // update GeoJSON
    final geoJson = createGeoJson(results);
    await controller.setGeoJsonSource(
      sourceId,
      geoJson,
    );
    if (results.isEmpty) {
      didUpdatedSinceZero = true;
    }
  }

  // ignore: use_setters_to_change_properties
  void update(List<TelegramVxse45Body> items) => _cachedEews = items;

  static Map<String, dynamic> createGeoJson(
    List<(TravelTimeResult, lat_lng.LatLng)> results,
  ) =>
      {
        'type': 'FeatureCollection',
        'features': [
          // S-wave
          for (final type in _WaveType.values)
            for (final result in results)
              {
                'type': 'Feature',
                'geometry': {
                  'type': 'LineString',
                  'coordinates': () {
                    final base = [
                      for (final bearing
                          in List<int>.generate(360, (index) => index))
                        () {
                          final latLng = const latlong2.Distance().offset(
                            latlong2.LatLng(
                              result.$2.lat,
                              result.$2.lon,
                            ),
                            ((type == _WaveType.sWave
                                        ? result.$1.sDistance!
                                        : result.$1.pDistance!) *
                                    1000)
                                .toInt(),
                            bearing,
                          );
                          return [latLng.longitude, latLng.latitude];
                        }(),
                    ];
                    return [
                      ...base,
                      base.first,
                    ];
                  }(),
                },
                'properties': {
                  'distance': result.$1.sDistance,
                  'hypocenter': {
                    'type': 'Point',
                    'coordinates': [
                      result.$2.lon,
                      result.$2.lat,
                    ],
                  },
                  'type': type.name,
                },
              },
        ],
      };

  Future<void> dispose() => (
        controller.removeLayer(sourceId),
        _children.$1.dispose(),
        _children.$2.dispose(),
        //_children.$3.dispose(),
        //_children.$4.dispose(),
      ).wait.then(
            (_) => controller.removeSource(sourceId),
          );

  static String get sourceId => 'ps-wave';
}

enum _WaveType {
  pWave,
  sWave,
  ;
}

class _EewPWaveLineService {
  _EewPWaveLineService({
    required this.controller,
  });

  final MaplibreMapController controller;

  Future<void> init() async {
    await dispose();
    await controller.addLineLayer(
      _EewPsWaveService.sourceId,
      layerId,
      LineLayerProperties(
        lineColor: const Color(0xff0000ff).toHexStringRGB(),
        lineOpacity: 0.9,
      ),
      filter: [
        '==',
        'type',
        _WaveType.pWave.name,
      ],
    );
  }

  Future<void> dispose() => controller.removeLayer(layerId);

  static String get layerId => 'p-wave-line';
}

class _EewSWaveLineService {
  _EewSWaveLineService({
    required this.controller,
  });

  final MaplibreMapController controller;

  Future<void> init() async {
    await dispose();
    await controller.addLineLayer(
      _EewPsWaveService.sourceId,
      layerId,
      LineLayerProperties(
        lineColor: const Color(0xffff0000).toHexStringRGB(),
        lineWidth: 2,
        lineOpacity: 0.9,
        lineBlur: 1,
      ),
      filter: [
        '==',
        'type',
        _WaveType.sWave.name,
      ],
    );
  }

  Future<void> dispose() => controller.removeLayer(layerId);

  static String get layerId => 's-wave-line';
}

/*
class _EewPWaveFillService {
  _EewPWaveFillService({
    required this.controller,
  });

  final MaplibreMapController controller;

  Future<void> init() async {
    await dispose();
    await controller.addFillLayer(
      _EewPsWaveService.sourceId,
      layerId,
      FillLayerProperties(
        fillColor: Colors.blue.toHexStringRGB(),
        fillOpacity: 0.2,
      ),
      filter: [
        '==',
        'type',
        _WaveType.pWave.name,
      ],
      belowLayerId: _EewPWaveLineService.layerId,
    );
  }

  Future<void> dispose() => controller.removeLayer(layerId);

  static String get layerId => 'p-wave-fill';
}

class _EewSWaveFillService {
  _EewSWaveFillService({
    required this.controller,
  });

  final MaplibreMapController controller;

  Future<void> init() async {
    await dispose();
    await controller.addFillLayer(
      _EewPsWaveService.sourceId,
      layerId,
      FillLayerProperties(
        fillColor: Colors.red.toHexStringRGB(),
        fillOpacity: 0.5,
      ),
      filter: [
        '==',
        'type',
        _WaveType.sWave.name,
      ],
      belowLayerId: _EewSWaveLineService.layerId,
    );
  }

  Future<void> dispose() => controller.removeLayer(layerId);

  static String get layerId => 's-wave-fill';
}
*/

@freezed
class _EewHypocenterProperties with _$EewHypocenterProperties {
  const factory _EewHypocenterProperties({
    required int depth,
    required double magnitude,
    required bool isLowPrecise,
  }) = __EewHypocenterProperties;

  factory _EewHypocenterProperties.fromJson(Map<String, dynamic> json) =>
      _$$_EewHypocenterPropertiesImplFromJson(json);
}

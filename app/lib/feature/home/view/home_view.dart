import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:eqapi_types/eqapi_types.dart';
import 'package:eqapi_types/model/components/eew_intensity.dart';
import 'package:eqmonitor/core/component/container/bordered_container.dart';
import 'package:eqmonitor/core/component/intenisty/intensity_icon_type.dart';
import 'package:eqmonitor/core/component/intenisty/jma_forecast_intensity_icon.dart';
import 'package:eqmonitor/core/component/sheet/basic_modal_sheet.dart';
import 'package:eqmonitor/core/component/sheet/sheet_floating_action_buttons.dart';
import 'package:eqmonitor/core/hook/use_sheet_controller.dart';
import 'package:eqmonitor/core/provider/capture/intensity_icon_render.dart';
import 'package:eqmonitor/core/provider/config/notification/fcm_topic_manager.dart';
import 'package:eqmonitor/core/provider/config/permission/permission_status_provider.dart';
import 'package:eqmonitor/core/provider/eew/eew_alive_telegram.dart';
import 'package:eqmonitor/core/provider/kmoni/viewmodel/kmoni_settings.dart';
import 'package:eqmonitor/core/provider/kmoni/viewmodel/kmoni_view_model.dart';
import 'package:eqmonitor/core/provider/kmoni/widget/kmoni_maintenance_widget.dart';
import 'package:eqmonitor/core/provider/ntp/ntp_provider.dart';
import 'package:eqmonitor/core/router/router.dart';
import 'package:eqmonitor/feature/home/component/eew/eew_widget.dart';
import 'package:eqmonitor/feature/home/component/kmoni/kmoni_scale.dart';
import 'package:eqmonitor/feature/home/component/kmoni/kmoni_settings_dialog.dart';
import 'package:eqmonitor/feature/home/component/parameter/parameter_loader_widget.dart';
import 'package:eqmonitor/feature/home/component/render/map_components_renderer.dart';
import 'package:eqmonitor/feature/home/component/sheet/earthquake_history_widget.dart';
import 'package:eqmonitor/feature/home/component/sheet/status_widget.dart';
import 'package:eqmonitor/feature/home/component/sheet/update_widget.dart';
import 'package:eqmonitor/feature/home/features/map/view/main_map_view.dart';
import 'package:eqmonitor/feature/home/features/map/viewmodel/main_map_viewmodel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sheet/sheet.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 0.8),
        child: AppBar(
          title: Text(
            'EQMonitor',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          forceMaterialTransparency: true,
        ),
      ),
      body: const _HomeBodyWidget(),
    );
  }
}

class _HomeBodyWidget extends HookConsumerWidget {
  const _HomeBodyWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ntpProvider);
    // 参照元が定数なので notifier から取得
    final sheetController = useSheetController();
    useEffect(
      () {
        WidgetsBinding.instance.endOfFrame.then((_) {
          (
            ref.read(kmoniViewModelProvider.notifier).initialize(),
            ref.read(permissionProvider.notifier).initialize(),
            ref.read(fcmTopicManagerProvider.notifier).setup(),
            ref.read(ntpProvider.notifier).sync(),
            Future.doWhile(() async {
              try {
                final renderer = MapComponentsRenderer();
                final futures = <Future<void>>[
                  for (final type in [
                    IntensityIconType.small,
                    IntensityIconType.smallWithoutText,
                  ]) ...[
                    for (final intensity in JmaIntensity.values)
                      renderer
                          .renderIntensityIcon(
                            context,
                            intensity,
                            type,
                          )
                          .then(
                            (value) => switch (type) {
                              IntensityIconType.small => ref
                                  .read(intensityIconRenderProvider.notifier)
                                  .onRendered(
                                    value,
                                    intensity,
                                  ),
                              IntensityIconType.smallWithoutText => ref
                                  .read(
                                    intensityIconFillRenderProvider.notifier,
                                  )
                                  .onRendered(
                                    value,
                                    intensity,
                                  ),
                              _ => null,
                            },
                          ),
                    for (final intensity in JmaLgIntensity.values)
                      renderer
                          .renderLpgmIntensityIcon(
                            context,
                            intensity,
                            type,
                          )
                          .then(
                            (value) => switch (type) {
                              IntensityIconType.small => ref
                                  .read(
                                    lpgmIntensityIconRenderProvider.notifier,
                                  )
                                  .onRendered(
                                    value,
                                    intensity,
                                  ),
                              IntensityIconType.smallWithoutText => ref
                                  .read(
                                    lpgmIntensityIconFillRenderProvider
                                        .notifier,
                                  )
                                  .onRendered(
                                    value,
                                    intensity,
                                  ),
                              _ => null,
                            },
                          ),
                  ],
                  for (final type in HypocenterType.values)
                    renderer
                        .renderHypocenterIcon(
                          context,
                          type,
                        )
                        .then(
                          (value) => switch (type) {
                            HypocenterType.normal => ref
                                .read(hypocenterIconRenderProvider.notifier)
                                .onRendered(
                                  value,
                                ),
                            HypocenterType.lowPrecise => ref
                                .read(
                                  hypocenterLowPreciseIconRenderProvider
                                      .notifier,
                                )
                                .onRendered(
                                  value,
                                ),
                          },
                        ),
                ];
                await futures.wait;
                // 画像のキャッシュが終わったかどうかを確認
                final images = (
                  intenistyIcon: ref.read(intensityIconRenderProvider),
                  intensityIconFill: ref.read(intensityIconFillRenderProvider),
                  hypocenterIcon: ref.read(hypocenterIconRenderProvider),
                  hypocenterLowPreciseIcon:
                      ref.read(hypocenterLowPreciseIconRenderProvider),
                );
                if (images.hypocenterIcon != null &&
                    images.hypocenterLowPreciseIcon != null &&
                    images.intenistyIcon.isAllRendered() &&
                    images.intensityIconFill.isAllRendered()) {
                  unawaited(FirebaseCrashlytics.instance.log('画像のキャッシュ 成功'));
                  return false;
                }
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                return true;
                // ignore: avoid_catches_without_on_clauses
              } catch (e) {
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                return true;
              }
            }),
          ).wait;
        });
        return null;
      },
      [],
    );

    final child = Stack(
      children: [
        const MainMapView(),
        SheetFloatingActionButtons(
          controller: sheetController,
          fab: const [
            _Fabs(),
          ],
        ),
        // Sheet
        const Align(
          alignment: Alignment.topRight,
          child: IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _KmoniScale(),
                _IntensityIcons(),
              ],
            ),
          ),
        ),
        _Sheet(sheetController: sheetController),
      ],
    );
    return child;
  }
}

class _IntensityIcons extends ConsumerWidget {
  const _IntensityIcons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aliveEews = ref.watch(eewAliveNormalTelegramProvider);
    final maxEstimatedIntensities = aliveEews
        .map(
          (e) => e.regions
              ?.map(
                (region) => region.forecastMaxInt.toDisplayMaxInt().maxInt,
              )
              .toList(),
        )
        .whereNotNull()
        .flattened
        .whereNotNull()
        .toList();
    final maxIntensity = maxEstimatedIntensities.isNotEmpty
        ? maxEstimatedIntensities.reduce((a, b) => a > b ? a : b)
        : null;
    final minIntensity = maxEstimatedIntensities.isNotEmpty
        ? maxEstimatedIntensities.reduce((a, b) => a < b ? a : b)
        : null;
    final intensities = maxIntensity != null && minIntensity != null
        ? [
            ...JmaForecastIntensity.values,
          ].where(
            (e) => e <= maxIntensity && e >= minIntensity,
          )
        : null;
    if (intensities == null || intensities.isEmpty) {
      return const SizedBox.shrink();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: BorderedContainer(
        key: ValueKey(
          maxIntensity,
        ),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(4),
        borderRadius: BorderRadius.circular((25 / 5) + 5),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (maxIntensity != null && minIntensity != null)
              for (final intensity in intensities)
                JmaForecastIntensityWidget(
                  intensity: intensity,
                  size: 25,
                ),
          ],
        ),
      ),
    );
  }
}

class _Fabs extends ConsumerWidget {
  const _Fabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: 'sheet',
          tooltip: '強震モニタの設定',
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (context) => const KmoniSettingsModal(),
          ),
          elevation: 4,
          child: const Icon(Icons.settings),
        ),
        FloatingActionButton.small(
          heroTag: 'home',
          tooltip: '表示領域領域を戻す',
          onPressed: () async {
            final notifier = ref.read(mainMapViewModelProvider.notifier);
            if (!notifier.isMapControllerRegistered()) {
              return;
            }
            await notifier.animateToHomeBoundary();
          },
          elevation: 4,
          child: const Icon(Icons.home),
        ),
      ],
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.sheetController,
  });

  final SheetController sheetController;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BasicModalSheet(
        useColumn: true,
        controller: sheetController,
        children: [
          const EewWidgets(),
          const SheetStatusWidget(),
          const KmoniMaintenanceWidget(),
          const ParameterLoaderWidget(),
          const UpdateWidget(),
          const EarthquakeHistorySheetWidget(),
          ListTile(
            title: const Text('地震・津波に関するお知らせ'),
            leading: const Icon(Icons.info),
            onTap: () => const InformationHistoryRoute().push<void>(context),
          ),
          ListTile(
            title: const Text('設定'),
            leading: const Icon(Icons.settings),
            onTap: () => const SettingsRoute().push<void>(context),
          ),
        ],
      ),
    );
  }
}

class _KmoniScale extends ConsumerWidget {
  const _KmoniScale();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kmoniSettingsProvider);
    final body = Padding(
      padding: const EdgeInsets.all(4),
      child: Tooltip(
        message: '強震モニタ リアルタイム震度のスケール',
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: InkWell(
            child: KmoniScaleWidget(
              markers: [
                if (state.minRealtimeShindo != null &&
                    state.minRealtimeShindo != -3.0)
                  state.minRealtimeShindo!,
              ],
            ),
            onTap: () {},
          ),
        ),
      ),
    );
    final Widget child;

    if (!state.showRealtimeShindoScale || !state.useKmoni) {
      child = const KeyedSubtree(
        key: ValueKey('kmoni_scale_none'),
        child: SizedBox.shrink(),
      );
    } else {
      child = KeyedSubtree(
        key: const ValueKey('kmoni_scale'),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 横幅は 画面2/3 もしくは 300px 以下
            final width = min(constraints.maxWidth * 2 / 3, 300);
            return Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: width.toDouble(),
                height: 40,
                child: body,
              ),
            );
          },
        ),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: child,
    );
  }
}

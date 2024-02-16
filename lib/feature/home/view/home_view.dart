import 'package:collection/collection.dart';
import 'package:eqapi_types/eqapi_types.dart';
import 'package:eqmonitor/core/component/container/bordered_container.dart';
import 'package:eqmonitor/core/component/intenisty/jma_forecast_intensity_icon.dart';
import 'package:eqmonitor/core/component/sheet/basic_modal_sheet.dart';
import 'package:eqmonitor/core/component/sheet/sheet_floating_action_buttons.dart';
import 'package:eqmonitor/core/hook/use_sheet_controller.dart';
import 'package:eqmonitor/core/provider/config/notification/fcm_topic_manager.dart';
import 'package:eqmonitor/core/provider/config/permission/permission_status_provider.dart';
import 'package:eqmonitor/core/provider/ntp/ntp_provider.dart';
import 'package:eqmonitor/core/router/router.dart';
import 'package:eqmonitor/feature/home/component/eew/eew_widget.dart';
import 'package:eqmonitor/feature/home/component/parameter/parameter_loader_widget.dart';
import 'package:eqmonitor/feature/home/component/render/hypocenter_render.dart';
import 'package:eqmonitor/feature/home/component/render/intensity_renderer_widget.dart';
import 'package:eqmonitor/feature/home/component/sheet/earthquake_history_widget.dart';
import 'package:eqmonitor/feature/home/component/sheet/status_widget.dart';
import 'package:eqmonitor/feature/home/component/sheet/update_widget.dart';
import 'package:eqmonitor/feature/home/features/eew/provider/eew_alive_telegram.dart';
import 'package:eqmonitor/feature/home/features/kmoni/viewmodel/kmoni_view_model.dart';
import 'package:eqmonitor/feature/home/features/kmoni/widget/kmoni_maintenance_widget.dart';
import 'package:eqmonitor/feature/home/features/map/view/main_map_view.dart';
import 'package:eqmonitor/feature/home/features/map/viewmodel/main_map_viewmodel.dart';
import 'package:eqmonitor/feature/home/features/telegram_ws/provider/telegram_provider.dart';
import 'package:flutter/foundation.dart';
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
          child: _IntensityIcons(),
        ),
        _Sheet(sheetController: sheetController),
        FractionalTranslation(
          translation: -const Offset(2, 2),
          child: const IntensityRendererWidget(),
        ),
        FractionalTranslation(
          translation: -const Offset(2, 2),
          // translation: -const Offset(2, 2),
          child: const HypocenterRenderWidget(),
        ),
      ],
    );
    return child;
  }
}

class _IntensityIcons extends ConsumerWidget {
  const _IntensityIcons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aliveEews = ref.watch(eewAliveNormalTelegramProvider);
    final maxEstimatedIntensities = aliveEews
        .map((e) => e.latestEew)
        .whereType<TelegramVxse45Body>()
        .map((e) => e.forecastMaxInt?.toDisplayMaxInt().maxInt)
        .whereNotNull();
    final maxIntensity = maxEstimatedIntensities.isNotEmpty
        ? maxEstimatedIntensities.reduce((a, b) => a > b ? a : b)
        : null;
    final intensities = maxIntensity != null
        ? [
            ...JmaForecastIntensity.values,
          ].where(
            (e) => e <= maxIntensity && e >= JmaForecastIntensity.four,
          )
        : null;
    if (intensities == null || intensities.isEmpty) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: AnimatedSwitcher(
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
              if (maxIntensity != null)
                for (final intensity in [
                  ...JmaForecastIntensity.values,
                ].where(
                  (e) => e <= maxIntensity && e >= JmaForecastIntensity.four,
                ))
                  JmaForecastIntensityWidget(
                    intensity: intensity,
                    size: 25,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fabs extends ConsumerWidget {
  const _Fabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
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
        if (kDebugMode)
          FloatingActionButton.small(
            onPressed: ref.read(telegramWsProvider.notifier).requestSample,
            heroTag: 'sample',
            child: const Icon(Icons.warning),
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

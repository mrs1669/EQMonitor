import 'package:eqmonitor/core/component/widget/kmoni_caution.dart';
import 'package:eqmonitor/core/provider/kmoni/viewmodel/kmoni_settings.dart';
import 'package:eqmonitor/feature/home/component/sheet/sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class KmoniSettingsPage extends ConsumerWidget {
  const KmoniSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kmoniSettingsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('強震モニタ設定'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              color: theme.colorScheme.primaryContainer,
              child: SwitchListTile.adaptive(
                value: state.useKmoni,
                onChanged: (value) async {
                  if (value) {
                    final result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SafeArea(
                        child: DraggableScrollableSheet(
                          expand: false,
                          builder: (context, scrollController) =>
                              SingleChildScrollView(
                            controller: scrollController,
                            child: const SafeArea(
                              child: Column(
                                children: [
                                  SheetHeader(title: '強震モニタの注意点'),
                                  KmoniCautionWidget(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                    final isAccepted = result == true;

                    if (isAccepted) {
                      ref.read(kmoniSettingsProvider.notifier).toggleUseKmoni();
                    }
                    return;
                  }
                  ref.read(kmoniSettingsProvider.notifier).toggleUseKmoni();
                },
                title: const Text('強震モニタを表示する'),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

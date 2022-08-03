import 'package:eqmonitor/const/travel_time_table/travel_time_table.dart';
import 'package:eqmonitor/model/travel_time_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class TravelTimeController extends StateNotifier<TravelTimeModel> {
  TravelTimeController()
      : super(
          const TravelTimeModel(
            travelTimeTable: [],
            loadDuration: null,
          ),
        ) {
    onInit();
  }

  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      printTime: true,
    ),
  );

  void onInit() {
    // 走時表読み込み開始
    loadTravelTimeCsv();
  }

  Future<void> loadTravelTimeCsv() async {
    // 走時表読み込み開始
    // ストップウォッチ
    final stopWatch = Stopwatch()..start();
    // CSV読みこみ
    final file = await rootBundle.loadString('assets/tjma2001.csv');
    // 改行で区切る
    final csv = file.split('\n');
    final travelTimeTable = <TravelTimeTable>[];
    for (final row in csv) {
      try {
        travelTimeTable.add(TravelTimeTable.fromList(row.split(',')));
      } on Exception catch (e) {
        print(e.toString());
      }
    }
    // 走時表読み込み終了
    stopWatch.stop();
    logger.d('走時表を読み込みました: ${stopWatch.elapsedMicroseconds / 1000}ms');

    state = state.copyWith(
      travelTimeTable: travelTimeTable,
      loadDuration: stopWatch.elapsed,
    );
  }
}

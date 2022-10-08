import 'dart:io';

import 'package:eqmonitor/schema/remote/supabase/telegram.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelegramApi {
  /// ## SupabaseからTelegramを取得します
  /// dataは除きます。
  /// [limit] 結果の最大数
  /// [offset] 結果のオフセット
  static Future<List<Telegram>> getTelegramsWithLimit({
    int? limit = 200,
    int offset = 0,
  }) async {
    if (offset != 0) {
      throw UnimplementedError('Telegram offset is not implemented yet');
    }
    final PostgrestResponse<dynamic> res;
    if (limit == null) {
      res = await Supabase.instance.client
          .from('telegram')
          .select(
            'id,'
            'data, '
            'type,'
            'time,'
            'url,'
            'image_url,'
            'headline,'
            'maxint,'
            'magnitude,'
            'magnitude_condition,'
            'depth,'
            'lat,'
            'lon,'
            'serial_no,'
            'event_id,'
            'hypo_name,'
            'hash,'
            'depth_condition',
          )
          .order('id')
          .execute();
    } else {
      res = await Supabase.instance.client
          .from('telegram')
          .select(
            'id,'
            'type,'
            'data, '
            'time,'
            'url,'
            'image_url,'
            'headline,'
            'maxint,'
            'magnitude,'
            'magnitude_condition,'
            'depth,'
            'lat,'
            'lon,'
            'serial_no,'
            'event_id,'
            'hypo_name,'
            'hash,'
            'depth_condition',
          )
          .order('id')
          .limit(limit)
          .execute();
    }

    if (res.hasError) {
      throw HttpException(res.error?.message ?? '原因不明のエラー');
    }
    final telegrams = <Telegram>[];
    for (final telegram in res.data) {
      telegrams.add(Telegram.fromJson(telegram));
    }
    return telegrams;
  }

  Future<int> getAllTelegramCount() async {
    final res = await Supabase.instance.client
        .from('telegram')
        .select('id')
        .order('id')
        .single()
        .execute(count: CountOption.exact);
    if (res.hasError || res.count == null) {
      throw Exception(res.error?.message);
    }
    return res.count!;
  }
}
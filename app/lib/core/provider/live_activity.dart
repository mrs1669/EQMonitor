import 'package:live_activities/live_activities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'live_activity.g.dart';

@Riverpod(keepAlive: true)
LiveActivities liveActivities(LiveActivitiesRef ref) => LiveActivities();

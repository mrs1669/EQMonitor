import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/live_activity_image.dart';
import 'package:live_activities/models/url_scheme_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _liveActivitiesPlugin = LiveActivities();
  String? _latestActivityId;
  StreamSubscription<UrlSchemeData>? urlSchemeSubscription;
  FootballGameLiveActivityModel? _footballGameLiveActivityModel;

  int teamAScore = 0;
  int teamBScore = 0;

  String teamAName = 'PSG';
  String teamBName = 'Chelsea';

  @override
  void initState() {
    super.initState();

    _liveActivitiesPlugin.init(
      appGroupId: 'group.eqmonitor.widget',
    );

    _liveActivitiesPlugin.activityUpdateStream.listen((event) {
      print('Activity update: $event');
    });

    urlSchemeSubscription =
        _liveActivitiesPlugin.urlSchemeStream().listen((schemeData) {
      setState(() {
        if (schemeData.path == '/stats') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Stats 📊'),
                content: Text(
                  'Now playing final world cup between $teamAName and $teamBName\n\n$teamAName score: $teamAScore\n$teamBName score: $teamBScore',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }

  @override
  void dispose() {
    urlSchemeSubscription?.cancel();
    _liveActivitiesPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Activities (Flutter)',
          style: TextStyle(
            fontSize: 19,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_latestActivityId != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: Row(
                        children: [
                          Expanded(
                            child: ScoreWidget(
                              score: teamAScore,
                              teamName: teamAName,
                              onScoreChanged: (score) {
                                setState(() {
                                  teamAScore = score < 0 ? 0 : score;
                                });
                                _updateScore();
                              },
                            ),
                          ),
                          Expanded(
                            child: ScoreWidget(
                              score: teamBScore,
                              teamName: teamBName,
                              onScoreChanged: (score) {
                                setState(() {
                                  teamBScore = score < 0 ? 0 : score;
                                });
                                _updateScore();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_latestActivityId == null)
                TextButton(
                  onPressed: () async {
                    final footballGameLiveActivityModel =
                        FootballGameLiveActivityModel(
                      matchName: 'World cup ⚽️',
                      teamAName: 'PSG',
                      teamAState: 'Home',
                      teamALogo: LiveActivityImageFromAsset(
                        'assets/images/hypocenter.png',
                      ),
                      teamBLogo: LiveActivityImageFromAsset(
                        'assets/images/hypocenter.png',
                      ),
                      teamBName: 'Chelsea',
                      teamBState: 'Guest',
                      matchStartDate: DateTime.now(),
                      matchEndDate: DateTime.now().add(
                        const Duration(
                          minutes: 6,
                          seconds: 30,
                        ),
                      ),
                    );

                    final activityId =
                        await _liveActivitiesPlugin.createActivity(
                      footballGameLiveActivityModel.toMap(),
                    );
                    _footballGameLiveActivityModel =
                        footballGameLiveActivityModel;
                    setState(() => _latestActivityId = activityId);
                  },
                  child: const Column(
                    children: [
                      Text('Start football match ⚽️'),
                      Text(
                        '(start a new live activity)',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_latestActivityId == null)
                TextButton(
                  onPressed: () async {
                    final supported =
                        await _liveActivitiesPlugin.areActivitiesEnabled();
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                              supported ? 'Supported' : 'Not supported',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Is live activities supported ? 🤔'),
                ),
              if (_latestActivityId != null)
                TextButton(
                  onPressed: () {
                    _liveActivitiesPlugin.endAllActivities();
                    _latestActivityId = null;
                    setState(() {});
                  },
                  child: const Column(
                    children: [
                      Text('Stop match ✋'),
                      Text(
                        '(end all live activities)',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future _updateScore() async {
    if (_footballGameLiveActivityModel == null) {
      return;
    }

    final data = _footballGameLiveActivityModel!.copyWith(
      teamAScore: teamAScore,
      teamBScore: teamBScore,
      // teamAName: null,
    );
    return _liveActivitiesPlugin.updateActivity(
      _latestActivityId!,
      data.toMap(),
    );
  }
}

class ScoreWidget extends StatelessWidget {
  const ScoreWidget({
    super.key,
    required this.teamName,
    required this.score,
    required this.onScoreChanged,
  });
  final String teamName;
  final int score;
  final Function(int) onScoreChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          teamName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              width: 35,
              height: 35,
              child: IconButton(
                iconSize: 18,
                icon: const Icon(
                  Icons.remove_rounded,
                  color: Colors.white,
                ),
                onPressed: () => onScoreChanged(score - 1),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              score.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              width: 35,
              height: 35,
              child: IconButton(
                iconSize: 16,
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                ),
                onPressed: () => onScoreChanged(score + 1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FootballGameLiveActivityModel {
  FootballGameLiveActivityModel({
    this.teamAName,
    this.matchName,
    this.teamAState,
    this.teamAScore = 0,
    this.teamBScore = 0,
    this.teamALogo,
    this.teamBName,
    this.teamBState,
    this.teamBLogo,
    this.matchEndDate,
    this.matchStartDate,
  });
  final DateTime? matchStartDate;
  final DateTime? matchEndDate;
  final String? matchName;

  final String? teamAName;
  final String? teamAState;
  final int? teamAScore;
  final LiveActivityImageFromAsset? teamALogo;

  final String? teamBName;
  final String? teamBState;
  final int? teamBScore;
  final LiveActivityImageFromAsset? teamBLogo;

  Map<String, dynamic> toMap() {
    final map = {
      'matchName': matchName,
      'teamAName': teamAName,
      'teamAState': teamAState,
      'teamALogo': teamALogo,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'teamBName': teamBName,
      'teamBState': teamBState,
      'teamBLogo': teamBLogo,
      'matchStartDate': matchStartDate?.millisecondsSinceEpoch,
      'matchEndDate': matchEndDate?.millisecondsSinceEpoch,
    };

    return map;
  }

  FootballGameLiveActivityModel copyWith({
    DateTime? matchStartDate,
    DateTime? matchEndDate,
    String? matchName,
    String? teamAName,
    String? teamAState,
    int? teamAScore,
    LiveActivityImageFromAsset? teamALogo,
    String? teamBName,
    String? teamBState,
    int? teamBScore,
    LiveActivityImageFromAsset? teamBLogo,
  }) {
    return FootballGameLiveActivityModel(
      matchStartDate: matchStartDate ?? this.matchStartDate,
      matchEndDate: matchEndDate ?? this.matchEndDate,
      matchName: matchName ?? this.matchName,
      teamAName: teamAName ?? this.teamAName,
      teamAState: teamAState ?? this.teamAState,
      teamAScore: teamAScore ?? this.teamAScore,
      teamALogo: teamALogo ?? this.teamALogo,
      teamBName: teamBName ?? this.teamBName,
      teamBState: teamBState ?? this.teamBState,
      teamBScore: teamBScore ?? this.teamBScore,
      teamBLogo: teamBLogo ?? this.teamBLogo,
    );
  }
}

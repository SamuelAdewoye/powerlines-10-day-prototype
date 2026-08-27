// Powerlines Flutter: mobile-first, local-first, and strictly linear from Secret to Power Move.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color sovereignBlack = Color(0xFF0A0A0A);
const Color reclaimRed = Color(0xFFC0001A);
const Color declarationWhite = Color(0xFFF5F5F3);
const Color mutedInk = Color(0xFF6C6C67);
const Color paperLine = Color(0xFFD6D6D1);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await Hive.initFlutter();
  final storage = await PracticeStorage.open();
  final preferences = await SharedPreferences.getInstance();
  final controller = PracticeController(storage, preferences);
  await controller.initialize();
  runApp(PowerlinesApp(controller: controller));
}

class DayContent {
  const DayContent({
    required this.secret,
    required this.storyTitle,
    required this.story,
    required this.lessons,
    required this.questions,
    required this.move,
  });

  final String secret;
  final String storyTitle;
  final String story;
  final List<String> lessons;
  final List<String> questions;
  final String move;
}

const List<DayContent> days = [
  DayContent(
    secret: 'ATTENTION IS THE FIRST TERRITORY YOU MUST GOVERN.',
    storyTitle: 'THE DAY YOU STOPPED NOTICING',
    story: 'You can lose a day without ever making a dramatic mistake. It happens through small surrenders: the tab you did not mean to open, the message you answered before you chose to, the opinion that became louder than your own. By evening, you are tired—but not always from work. Sometimes you are tired from being available to everything except the life you meant to lead.\n\nThe problem is not that distraction exists. The problem is that it begins to look normal when no one asks what it is costing. Attention is not a mood. It is a direction of force. What receives it begins to shape you.',
    lessons: [
      'Your attention decides what becomes emotionally important. What you revisit starts to feel true, urgent, or inevitable—even when it is only loud.',
      'Reclaiming attention is not about becoming perfectly focused. It is about noticing the moment your mind leaves your possession and choosing what happens next.',
      'The first useful question is simple: where did my attention go today, and did I send it there?',
    ],
    questions: [
      'What has been taking more of your attention than it deserves?',
      'When today did you feel most present and self-directed?',
      'What is one place you can reduce automatic access tomorrow?',
    ],
    move: 'Choose one attention leak you can interrupt today. Put it out of reach for one hour, then spend that hour on one task, conversation, or piece of rest you chose on purpose.',
  ),
  DayContent(
    secret: 'IMPULSE IS NOT A COMMAND.',
    storyTitle: 'THE GAP BEFORE THE ANSWER',
    story: 'Someone sends a message that lands badly. Your body makes a decision before your mind catches up: reply now, explain yourself, prove something, leave the room, buy the thing, open the app. The urge feels immediate because it is. That does not make it wise.\n\nPower begins in the short space between the first feeling and the first action. You do not need to become emotionless to use that space. You only need to learn that the first response is not always the response you owe the world.',
    lessons: [
      'An impulse often promises relief, not resolution. It wants the discomfort to end quickly, whether or not the next action helps you.',
      'Pausing creates information. When you wait, you can tell the difference between what you feel, what happened, and what you want to do about it.',
      'A deliberate response is not slow because you are weak. It is slow because you are choosing the terms.',
    ],
    questions: [
      'Which impulse most often makes decisions for you?',
      'What feeling usually arrives just before that impulse?',
      'What would a ten-minute pause make possible?',
    ],
    move: 'The next time you feel the urge to react immediately, set a ten-minute timer before acting. Name the feeling in one sentence. When the timer ends, choose your response rather than obeying the first one.',
  ),
  DayContent(
    secret: 'WHAT YOU REPEAT BECOMES THE EVIDENCE YOU BELIEVE.',
    storyTitle: 'THE RECORD YOU ARE MAKING',
    story: 'Identity is rarely decided by one grand declaration. It is built from the record you keep making in ordinary hours. Each avoided conversation, each kept promise, each choice to begin again becomes evidence. Over time, that evidence tells you what kind of person you are allowed to believe yourself to be.\n\nThis is why small actions matter without needing to be romanticized. They matter because repetition is persuasive. You do not need a perfect streak. You need a record that is honest enough to guide the next choice.',
    lessons: [
      'Habits are not only routines; they are arguments. They argue for the identity you are building through repetition.',
      'A single broken promise is not a verdict. The important question is whether you return to the standard after the break.',
      'Better evidence often starts smaller than your ambition. Make the next action easy to verify and hard to reinterpret.',
    ],
    questions: [
      'What repeated action is teaching you something unhelpful about yourself?',
      'What small action would give you better evidence this week?',
      'Where have you confused intensity with consistency?',
    ],
    move: 'Choose one action that takes less than fifteen minutes and repeat it today at a specific time. Record it when it is done. Let completion be evidence, not a performance.',
  ),
  DayContent(
    secret: 'DISCOMFORT IS OFTEN THE PRICE OF A CLEAN DECISION.',
    storyTitle: 'THE FEELING YOU KEEP NEGOTIATING WITH',
    story: 'There are choices you already understand but keep delaying because the first step would be awkward, disappointing, or uncertain. You call it needing more time. Sometimes that is true. Sometimes you are trying to make a necessary decision feel painless before you allow yourself to make it.\n\nA clean decision does not promise comfort. It gives you a direction. The discomfort may remain for a while, but it no longer gets to sit in the chair reserved for the person choosing your life.',
    lessons: [
      'Avoidance can look thoughtful when it wears the language of preparation. Look for the action that keeps moving without ever arriving.',
      'Discomfort is not proof that a choice is wrong. It may be proof that the choice matters and changes what others can expect from you.',
      'You can be compassionate with yourself without making every difficult feeling a reason to delay.',
    ],
    questions: [
      'What decision have you been waiting to feel ready for?',
      'What discomfort are you trying to avoid by postponing it?',
      'What would make the next step clean rather than dramatic?',
    ],
    move: 'Name one decision you have delayed. Take the smallest irreversible step toward it today: send the message, set the boundary, book the appointment, or remove the option that keeps you waiting.',
  ),
  DayContent(
    secret: 'SHAME GETS LOUDER WHEN IT IS LEFT UNEXAMINED.',
    storyTitle: 'THE PRIVATE PROSECUTOR',
    story: 'Shame is efficient at making every mistake feel like a permanent identity. It takes one missed deadline, one awkward exchange, one version of yourself you do not admire, and turns it into a case against your whole future. It speaks with certainty because certainty keeps you still.\n\nExamination interrupts that certainty. You can name what happened without pretending it did not matter. You can take responsibility without accepting a sentence that says you are only the worst thing you have done.',
    lessons: [
      "Shame says, 'this is what you are.' Responsibility says, 'this is what happened, and this is what I will do next.' The difference is action.",
      'When a thought is vague, it can become absolute. Specific language makes repair possible.',
      'You do not gain power by denying a mistake. You gain it by refusing to let the mistake become your only source of identity.',
    ],
    questions: [
      'What mistake are you still using as evidence against yourself?',
      'What are the plain facts, without the insult attached?',
      'What repair, learning, or boundary is still available to you?',
    ],
    move: 'Write the plain facts of one mistake in three sentences. Then write one repair or lesson you can act on within seven days. Keep the statement factual; do not let it become a verdict.',
  ),
  DayContent(
    secret: 'CLARITY IS OFTEN A DECISION TO STOP PRETENDING.',
    storyTitle: 'THE THING YOU ALREADY KNOW',
    story: 'Confusion sometimes protects you from an answer you do not want to admit. You gather more opinions, revisit the same possibilities, and wait for certainty to arrive from somewhere outside you. But beneath the noise, there may already be a truth you have been quietly editing.\n\nClarity does not always feel bright. It can feel like the end of a familiar excuse. Its value is not that it makes the next move easy. Its value is that it stops you from calling a known direction a mystery.',
    lessons: [
      'More information is useful until it becomes a substitute for choosing. Notice when research no longer changes the decision.',
      'A clear answer can include uncertainty. You can know what matters before you know every outcome.',
      'Honesty becomes practical when it is paired with a next step. Otherwise it is only a confession.',
    ],
    questions: [
      'What truth have you been editing to keep your options open?',
      'What decision would become simpler if you said that truth plainly?',
      'What information do you actually need before you move?',
    ],
    move: "Finish this sentence in writing: 'The truth I have been avoiding is…' Then identify one action that follows from it. Take that action before you seek another opinion.",
  ),
  DayContent(
    secret: 'CONSISTENCY IS A RELATIONSHIP WITH YOUR OWN WORD.',
    storyTitle: 'THE PROMISE YOU HEAR',
    story: 'Every promise you make to yourself has an audience: you. When you repeatedly say you will begin tomorrow, reply later, leave earlier, or protect your time—and then do not—your own word starts to lose weight. This is not a reason to make grander promises. It is a reason to make cleaner ones.\n\nTrust returns through follow-through that can be seen. You do not need to become a different person overnight. You need to become someone whose next promise is small enough to keep and serious enough to matter.',
    lessons: [
      'Self-trust is practical. It is built when your future self has evidence that your present self can be relied upon.',
      'Overpromising is often another form of avoidance. It lets you enjoy the idea of change without accepting the size of the work.',
      'A modest commitment completed repeatedly creates more power than a dramatic plan abandoned privately.',
    ],
    questions: [
      'What promise to yourself has become easy to dismiss?',
      'How could you make the promise smaller and more specific?',
      'What would keeping it tell you about your own word?',
    ],
    move: 'Make one promise for the next twenty-four hours that is measurable and modest. Put it in your calendar or on paper. Complete it before you make another promise to yourself.',
  ),
  DayContent(
    secret: 'A THOUGHT IS NOT A COMMAND, A FACT, OR A FORECAST.',
    storyTitle: 'THE SENTENCE THAT MOVED IN',
    story: 'Some thoughts arrive with the force of official news: I always ruin things. They will think I am ridiculous. It is too late. Because the sentence comes from inside you, it can sound more credible than it deserves. You follow it without noticing that it made a claim you never checked.\n\nYou do not have to argue with every thought. You can simply stop assigning it authority automatically. A thought can be present without becoming the person in charge of your next action.',
    lessons: [
      'The mind produces language quickly. Speed is not evidence of accuracy.',
      "Naming a thought as a thought gives you room to inspect its usefulness. 'I am having the thought that…' creates distance without denial.",
      'A more accurate sentence is often less dramatic and more actionable. It tells you what is happening, not who you are forever.',
    ],
    questions: [
      'Which recurring thought most often narrows your choices?',
      'What evidence supports it, and what evidence complicates it?',
      'What would a more accurate sentence sound like?',
    ],
    move: "Catch one limiting thought today. Write it exactly. Add the words 'I am having the thought that' before it, then take one useful action without waiting for the thought to disappear.",
  ),
  DayContent(
    secret: 'FEELINGS DESERVE INFORMATION, NOT AUTOMATIC AUTHORITY.',
    storyTitle: 'THE SIGNAL AND THE STEERING WHEEL',
    story: 'Feelings are real. They tell you when something has landed, when a need may be unmet, when a boundary may have been crossed, or when a memory is still active. But a feeling is a signal, not a complete instruction manual. If you hand it the steering wheel every time, it may drive you toward relief rather than where you want to go.\n\nThe practice is neither suppression nor obedience. It is listening closely enough to learn what the feeling knows, then choosing the action that fits your values and the facts.',
    lessons: [
      'A feeling can be valid without being the whole story. Its presence matters; its first interpretation may not be final.',
      'Naming the feeling precisely reduces its power to become a fog. Anger, disappointment, grief, jealousy, and fear each point to different work.',
      'Your values are most useful when a feeling is loud. They help you choose what you want to stand for after the signal has been heard.',
    ],
    questions: [
      'What feeling has been asking for your attention recently?',
      'What information might it be carrying?',
      'What action would honor both the feeling and your values?',
    ],
    move: 'When a strong feeling arrives today, name it without explanation. Take three slow breaths. Then write one action you can defend tomorrow, even if the feeling changes by tonight.',
  ),
  DayContent(
    secret: 'RESPONSIBILITY IS THE MOMENT YOU STOP WAITING TO BE RESCUED.',
    storyTitle: 'THE PART THAT IS STILL YOURS',
    story: 'Responsibility is often misunderstood as blame. It is not a claim that you caused everything that happened to you. It is the decision to identify what remains in your hands, even when circumstances are unfair, disappointing, or outside your design.\n\nWaiting for someone else to change may be understandable. Building your entire future around that wait is still a choice. Responsibility names the part you can influence and begins there—not because it is easy, but because it is the only part from which power can grow.',
    lessons: [
      'Responsibility starts with distinctions: what is mine, what is not mine, and what can I influence from here?',
      'Blaming yourself for everything is not responsibility. It is another way to avoid seeing the actual lever available.',
      'Agency often looks ordinary: one call, one request, one boundary, one schedule change, one honest acknowledgment of the next step.',
    ],
    questions: [
      'Where are you waiting for someone or something else to make the next move?',
      'What part of the situation is genuinely yours to influence?',
      'What would taking responsibility look like without blaming yourself?',
    ],
    move: "Choose one situation that has felt stuck. Make two columns: 'not mine to control' and 'mine to influence.' Take one action from the second column before the day ends.",
  ),
];

String formatDay(int day) => day.toString().padLeft(2, '0');

String displayTimestamp(String? value) {
  if (value == null || value.isEmpty) return 'Not yet committed';
  final date = DateTime.parse(value).toLocal();
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'PM' : 'AM';
  return '${months[date.month - 1]} ${date.day}, ${date.year}, $hour:$minute $suffix';
}

String _dateKey(String value) {
  final date = DateTime.parse(value).toLocal();
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

int calculateStreak(Map<int, PowerCommitment> commitments) {
  final committedDates = commitments.values
      .map((commitment) => _dateKey(commitment.timestamp))
      .toSet()
      .toList()
    ..sort();

  if (committedDates.isEmpty) return 0;
  var streak = 1;
  var cursor = DateTime.parse('${committedDates.last}T12:00:00');
  for (var index = committedDates.length - 2; index >= 0; index -= 1) {
    final previous = DateTime.parse('${committedDates[index]}T12:00:00');
    final difference = cursor.difference(previous).inDays;
    if (difference != 1) break;
    streak += 1;
    cursor = previous;
  }
  return streak;
}

class PowerCommitment {
  const PowerCommitment({required this.note, required this.timestamp});

  final String note;
  final String timestamp;

  Map<String, String> toJson() => {'note': note, 'timestamp': timestamp};

  factory PowerCommitment.fromJson(Map<String, dynamic> json) => PowerCommitment(
        note: json['note'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '',
      );
}

class SavedPractice {
  const SavedPractice({
    this.unlockedDay = 1,
    this.firstPracticeAt,
    this.responses = const {},
    this.commitments = const {},
  });

  final int unlockedDay;
  final String? firstPracticeAt;
  final Map<int, List<String>> responses;
  final Map<int, PowerCommitment> commitments;

  SavedPractice copyWith({
    int? unlockedDay,
    String? firstPracticeAt,
    bool clearFirstPracticeAt = false,
    Map<int, List<String>>? responses,
    Map<int, PowerCommitment>? commitments,
  }) => SavedPractice(
        unlockedDay: unlockedDay ?? this.unlockedDay,
        firstPracticeAt: clearFirstPracticeAt ? null : firstPracticeAt ?? this.firstPracticeAt,
        responses: responses ?? this.responses,
        commitments: commitments ?? this.commitments,
      );

  Map<String, dynamic> toJson() => {
        'unlockedDay': unlockedDay,
        'firstPracticeAt': firstPracticeAt,
        'responses': responses.map((key, value) => MapEntry('$key', value)),
        'commitments': commitments.map((key, value) => MapEntry('$key', value.toJson())),
      };

  factory SavedPractice.fromJson(Map<String, dynamic> json) {
    final rawResponses = Map<String, dynamic>.from(json['responses'] as Map? ?? const {});
    final rawCommitments = Map<String, dynamic>.from(json['commitments'] as Map? ?? const {});
    return SavedPractice(
      unlockedDay: ((json['unlockedDay'] as num?)?.toInt() ?? 1).clamp(1, 10),
      firstPracticeAt: json['firstPracticeAt'] as String?,
      responses: rawResponses.map((key, value) => MapEntry(int.parse(key), List<String>.from(value as List))),
      commitments: rawCommitments.map((key, value) => MapEntry(
            int.parse(key),
            PowerCommitment.fromJson(Map<String, dynamic>.from(value as Map)),
          )),
    );
  }
}

class PracticeStorage {
  PracticeStorage._(this._box);

  static const _boxName = 'powerlines_practice';
  static const _recordKey = 'saved_practice';
  final Box<String> _box;

  static Future<PracticeStorage> open() async => PracticeStorage._(await Hive.openBox<String>(_boxName));

  SavedPractice load() {
    final raw = _box.get(_recordKey);
    if (raw == null) return const SavedPractice();
    try {
      return SavedPractice.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return const SavedPractice();
    }
  }

  Future<void> save(SavedPractice state) => _box.put(_recordKey, jsonEncode(state.toJson()));
  Future<void> clear() => _box.delete(_recordKey);
}

class PracticeController extends ChangeNotifier {
  PracticeController(this._storage, this._preferences);

  final PracticeStorage _storage;
  final SharedPreferences _preferences;
  SavedPractice _state = const SavedPractice();

  int get unlockedDay => _state.unlockedDay;
  String? get firstPracticeAt => _state.firstPracticeAt;
  Map<int, List<String>> get responses => _state.responses;
  Map<int, PowerCommitment> get commitments => _state.commitments;
  int get completedCount => _state.commitments.length;
  int get streakCount => calculateStreak(_state.commitments);
  bool get hasStarted => _preferences.getBool('powerlines_has_started') ?? false;

  Future<void> initialize() async {
    _state = _storage.load();
    notifyListeners();
  }

  Future<void> saveAnswers(int day, List<String> answers) async {
    final next = Map<int, List<String>>.from(_state.responses)..[day] = List<String>.from(answers);
    _state = _state.copyWith(responses: next);
    await _persist();
  }

  Future<void> commitPowerMove(int day, String note) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final next = Map<int, PowerCommitment>.from(_state.commitments)
      ..[day] = PowerCommitment(note: note.trim(), timestamp: now);
    final nextUnlocked = day == _state.unlockedDay && day < days.length ? day + 1 : _state.unlockedDay;
    _state = _state.copyWith(
      commitments: next,
      unlockedDay: nextUnlocked,
      firstPracticeAt: _state.firstPracticeAt ?? now,
    );
    await _preferences.setBool('powerlines_has_started', true);
    await _persist();
  }

  Future<void> reset() async {
    _state = const SavedPractice();
    await _preferences.remove('powerlines_has_started');
    await _storage.clear();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.save(_state);
    notifyListeners();
  }
}

class PowerlinesApp extends StatefulWidget {
  const PowerlinesApp({super.key, required this.controller});

  final PracticeController controller;

  @override
  State<PowerlinesApp> createState() => _PowerlinesAppState();
}

class _PowerlinesAppState extends State<PowerlinesApp> {
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => WelcomeScreen(controller: widget.controller)),
      GoRoute(path: '/day/:day/secret', builder: (context, state) => SecretScreen(controller: widget.controller, day: _dayParam(state))),
      GoRoute(path: '/day/:day/story', builder: (context, state) => StoryScreen(controller: widget.controller, day: _dayParam(state))),
      GoRoute(path: '/day/:day/lessons', builder: (context, state) => LessonsScreen(controller: widget.controller, day: _dayParam(state))),
      GoRoute(path: '/day/:day/quiz', builder: (context, state) => QuizScreen(controller: widget.controller, day: _dayParam(state))),
      GoRoute(path: '/day/:day/move', builder: (context, state) => MoveScreen(controller: widget.controller, day: _dayParam(state))),
      GoRoute(path: '/day/:day/complete', builder: (context, state) => CompletionScreen(controller: widget.controller, day: _dayParam(state))),
      GoRoute(path: '/record', builder: (context, state) => RecordScreen(controller: widget.controller)),
    ],
  );

  int _dayParam(GoRouterState state) => int.tryParse(state.pathParameters['day'] ?? '')?.clamp(1, 10) ?? 1;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Powerlines — 10-Day Practice',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData(
          useMaterial3: false,
          scaffoldBackgroundColor: declarationWhite,
          colorScheme: const ColorScheme.light(
            primary: reclaimRed,
            surface: declarationWhite,
            onSurface: sovereignBlack,
          ),
        ),
      );
}

class PracticeShell extends StatelessWidget {
  const PracticeShell({
    super.key,
    required this.controller,
    required this.child,
    this.day,
    this.label = '10-DAY DEMO',
    this.dark = false,
    this.showHeader = true,
  });

  final PracticeController controller;
  final Widget child;
  final int? day;
  final String label;
  final bool dark;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? declarationWhite : sovereignBlack;
    return Scaffold(
      backgroundColor: dark ? sovereignBlack : declarationWhite,
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 54,
              color: sovereignBlack,
              child: Column(
                children: [
                  IconButton(
                    tooltip: 'Return to Powerlines home',
                    onPressed: () => context.go('/'),
                    icon: Image.asset('assets/images/powerlines-mark.png', width: 29, height: 29),
                  ),
                  if (showHeader)
                    IconButton(
                      tooltip: 'Go back',
                      color: declarationWhite,
                      onPressed: () => _goBack(context, day),
                      icon: const Icon(Icons.arrow_back, size: 20),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Open private reflection record',
                    color: declarationWhite,
                    onPressed: () => context.go('/record'),
                    icon: const Icon(Icons.fact_check_outlined, size: 21),
                  ),
                  IconButton(
                    tooltip: 'Open practice index',
                    color: declarationWhite,
                    onPressed: () => showPracticeIndex(context, controller),
                    icon: const Icon(Icons.menu_book_outlined, size: 21),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  if (showHeader)
                    DayHeader(
                      controller: controller,
                      day: day,
                      label: label,
                      foreground: foreground,
                      dark: dark,
                    ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goBack(BuildContext context, int? currentDay) {
    final path = GoRouterState.of(context).uri.path;
    if (path == '/record') {
      context.go('/');
      return;
    }
    if (currentDay == null || path.endsWith('/secret')) {
      context.go('/');
      return;
    }
    if (path.endsWith('/story')) context.go('/day/$currentDay/secret');
    if (path.endsWith('/lessons')) context.go('/day/$currentDay/story');
    if (path.endsWith('/quiz')) context.go('/day/$currentDay/lessons');
    if (path.endsWith('/move')) context.go('/day/$currentDay/quiz');
    if (path.endsWith('/complete')) context.go('/day/$currentDay/move');
  }
}

class DayHeader extends StatelessWidget {
  const DayHeader({
    super.key,
    required this.controller,
    required this.day,
    required this.label,
    required this.foreground,
    required this.dark,
  });

  final PracticeController controller;
  final int? day;
  final String label;
  final Color foreground;
  final bool dark;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: foreground.withValues(alpha: .22)))),
          child: Row(
            children: [
              Expanded(child: _indexLabel(day == null ? 'PRIVATE RECORD' : 'DAY ${formatDay(day!)} / 10', foreground)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(10, (index) {
                  final number = index + 1;
                  final color = controller.commitments.containsKey(number)
                      ? reclaimRed
                      : number == controller.unlockedDay
                          ? foreground
                          : paperLine;
                  return Container(width: 8, height: 4, margin: const EdgeInsets.only(right: 3), color: color);
                }),
              ),
              Expanded(child: Align(alignment: Alignment.centerRight, child: _indexLabel(label, foreground))),
            ],
          ),
        ),
      );

  Widget _indexLabel(String text, Color color) => Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(color: color.withValues(alpha: .72), fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.4),
      );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.controller});
  final PracticeController controller;

  @override
  Widget build(BuildContext context) => PracticeShell(
        controller: controller,
        showHeader: false,
        dark: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(opacity: .32, child: Image.asset('assets/images/powerlines-hero-redline.jpg', fit: BoxFit.cover, alignment: Alignment.centerRight)),
            Container(color: sovereignBlack.withValues(alpha: .63)),
            Container(width: 10, margin: const EdgeInsets.only(left: 0), alignment: Alignment.centerRight, child: Container(width: 8, color: reclaimRed)),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 60, 32, 42),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 610),
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IndexText('SURVIVAL TO SOVEREIGNTY / FIRST 10 DAYS', color: reclaimRed),
                        const SizedBox(height: 24),
                        DisplayText('POWERLINES', color: declarationWhite, size: 72),
                        DisplayText('ONE\nPRACTICE.', color: reclaimRed, size: 72),
                        const SizedBox(height: 26),
                        BodyText('A strictly paced digital practice for attention, agency, and self-expression. The order is the work: one Secret, one diagnostic, one Power Move.', color: const Color(0xFFC4C4BF), size: 16),
                        const SizedBox(height: 30),
                        Wrap(
                          spacing: 14,
                          runSpacing: 8,
                          children: const [
                            IndexText('LOCAL-FIRST', color: reclaimRed),
                            IndexText('ONE SECRET A DAY', color: reclaimRed),
                            IndexText('NO BINGE MODE', color: reclaimRed),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Divider(color: Color(0x5CF5F5F3), height: 1),
                        const SizedBox(height: 14),
                        const Wrap(
                          spacing: 13,
                          runSpacing: 8,
                          children: [
                            IndexText('01 / SECRET', color: Color(0xFF9F9F99)),
                            IndexText('02 / STORY', color: Color(0xFF9F9F99)),
                            IndexText('03 / LESSONS', color: Color(0xFF9F9F99)),
                            IndexText('04 / DIAGNOSTIC', color: Color(0xFF9F9F99)),
                            IndexText('05 / POWER MOVE', color: Color(0xFF9F9F99)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        PowerButton(
                          text: 'BEGIN DAY ${formatDay(controller.unlockedDay)}',
                          onPressed: () => context.go('/day/${controller.unlockedDay}/secret'),
                        ),
                        const SizedBox(height: 14),
                        BodyText('Demo pacing: recording a Power Move opens the next day. Your reflections stay on this device.', color: const Color(0xFF9A9A94), size: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class SecretScreen extends StatelessWidget {
  const SecretScreen({super.key, required this.controller, required this.day});
  final PracticeController controller;
  final int day;

  @override
  Widget build(BuildContext context) {
    final content = days[day - 1];
    return PracticeShell(
      controller: controller,
      day: day,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 44, 30, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IndexText('SECRET ${formatDay(day)} OF 10', color: reclaimRed),
              const SizedBox(height: 26),
              Container(width: 112, height: 6, color: reclaimRed),
              const SizedBox(height: 28),
              Expanded(child: SingleChildScrollView(child: DisplayText(content.secret, color: sovereignBlack, size: 66))),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: IndexText('THE PRINCIPLE COMES FIRST.', color: mutedInk)),
                  TextButton.icon(
                    onPressed: () => context.go('/day/$day/story'),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward, size: 17),
                    label: const Text('TAP TO CONTINUE'),
                    style: TextButton.styleFrom(foregroundColor: sovereignBlack, textStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key, required this.controller, required this.day});
  final PracticeController controller;
  final int day;

  @override
  Widget build(BuildContext context) {
    final content = days[day - 1];
    return PracticeShell(
      controller: controller,
      day: day,
      child: ReadingScaffold(
        label: 'THE STORY',
        title: content.storyTitle,
        footer: 'READ UNTIL THE PRINCIPLE HAS WEIGHT.',
        action: () => context.go('/day/$day/lessons'),
        child: Container(
          decoration: const BoxDecoration(border: Border(left: BorderSide(color: reclaimRed, width: 3))),
          padding: const EdgeInsets.only(left: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.story.split('\n\n').map((paragraph) => Padding(padding: const EdgeInsets.only(bottom: 18), child: BodyText(paragraph, color: const Color(0xFF343432), size: 16))).toList(),
          ),
        ),
      ),
    );
  }
}

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key, required this.controller, required this.day});
  final PracticeController controller;
  final int day;

  @override
  Widget build(BuildContext context) {
    final content = days[day - 1];
    return PracticeShell(
      controller: controller,
      day: day,
      child: ReadingScaffold(
        label: 'POWER LESSONS',
        title: 'LET IT LAND.',
        footer: 'THE POINT IS NOT AGREEMENT. IT IS ACCURATE EXAMINATION.',
        action: () => context.go('/day/$day/quiz'),
        child: Column(
          children: List.generate(content.lessons.length, (index) => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 19),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: sovereignBlack))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 42, child: IndexText('0${index + 1}', color: reclaimRed)),
                Expanded(child: BodyText(content.lessons[index], color: const Color(0xFF343432), size: 15)),
              ],
            ),
          )),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.controller, required this.day});
  final PracticeController controller;
  final int day;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<TextEditingController> _answers;

  @override
  void initState() {
    super.initState();
    final saved = widget.controller.responses[widget.day] ?? const ['', '', ''];
    _answers = List.generate(3, (index) => TextEditingController(text: index < saved.length ? saved[index] : ''));
  }

  @override
  void dispose() {
    for (final controller in _answers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    await widget.controller.saveAnswers(widget.day, _answers.map((field) => field.text).toList());
    if (mounted) context.go('/day/${widget.day}/move');
  }

  @override
  Widget build(BuildContext context) {
    final content = days[widget.day - 1];
    return PracticeShell(
      controller: widget.controller,
      day: widget.day,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 34, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IndexText('POWER QUIZ / DIAGNOSTIC', color: reclaimRed),
              const SizedBox(height: 17),
              DisplayText('DO NOT PERFORM.\nEXAMINE.', color: sovereignBlack, size: 55),
              const SizedBox(height: 13),
              BodyText('Write what is true enough to work with. These responses remain on this device for later reflection.', color: mutedInk, size: 13),
              const SizedBox(height: 25),
              ...List.generate(content.questions.length, (index) => QuestionField(number: index + 1, question: content.questions[index], controller: _answers[index])),
              const SizedBox(height: 24),
              const IndexText('THREE ANSWERS. NO SCORE.', color: mutedInk),
              const SizedBox(height: 14),
              PowerButton(text: 'SAVE RESPONSES', inverse: true, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class MoveScreen extends StatefulWidget {
  const MoveScreen({super.key, required this.controller, required this.day});
  final PracticeController controller;
  final int day;

  @override
  State<MoveScreen> createState() => _MoveScreenState();
}

class _MoveScreenState extends State<MoveScreen> {
  late final TextEditingController _moveNote;

  @override
  void initState() {
    super.initState();
    _moveNote = TextEditingController(text: widget.controller.commitments[widget.day]?.note ?? '');
    _moveNote.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _moveNote.dispose();
    super.dispose();
  }

  Future<void> _commit() async {
    if (_moveNote.text.trim().isEmpty) return;
    await widget.controller.commitPowerMove(widget.day, _moveNote.text);
    if (mounted) context.go('/day/${widget.day}/complete');
  }

  @override
  Widget build(BuildContext context) {
    final content = days[widget.day - 1];
    return PracticeShell(
      controller: widget.controller,
      day: widget.day,
      dark: true,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 34, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IndexText('POWER MOVE FOR TODAY', color: reclaimRed),
              const SizedBox(height: 18),
              DisplayText('MAKE THE\nNEXT MOVE\nVISIBLE.', color: declarationWhite, size: 62, redLastLine: true),
              const SizedBox(height: 26),
              Container(
                decoration: const BoxDecoration(border: Border(left: BorderSide(color: reclaimRed, width: 4))),
                padding: const EdgeInsets.only(left: 17),
                child: BodyText(content.move, color: const Color(0xFFD9D9D4), size: 17),
              ),
              const SizedBox(height: 28),
              const Divider(color: Color(0x73F5F5F3), height: 1),
              const SizedBox(height: 14),
              const IndexText('I WILL DO THIS TODAY:', color: reclaimRed),
              const SizedBox(height: 8),
              TextField(
                controller: _moveNote,
                minLines: 3,
                maxLines: 6,
                style: GoogleFonts.poppins(color: declarationWhite, fontSize: 14, height: 1.5),
                decoration: _fieldDecoration('Name the action clearly enough to recognize it when you have done it.', dark: true),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  SizedBox(width: 12, height: 12, child: DecoratedBox(decoration: BoxDecoration(border: Border.fromBorderSide(BorderSide(color: reclaimRed))))),
                  SizedBox(width: 9),
                  Expanded(child: IndexText('COMMITMENT RECORDS A TIMESTAMP.', color: Color(0xFFADADA6))),
                ],
              ),
              const SizedBox(height: 18),
              PowerButton(text: 'MARK AS COMMITTED', red: true, disabled: _moveNote.text.trim().isEmpty, onPressed: _commit),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key, required this.controller, required this.day});
  final PracticeController controller;
  final int day;

  @override
  Widget build(BuildContext context) {
    final isFinalDay = day == days.length;
    return PracticeShell(
      controller: controller,
      day: day,
      label: 'COMMITMENT RECORDED',
      dark: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(opacity: .36, child: Image.asset('assets/images/powerlines-completion-field.jpg', fit: BoxFit.cover)),
          Container(color: sovereignBlack.withValues(alpha: .62)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 52, 30, 32),
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IndexText('DAY ${formatDay(day)} / COMPLETE', color: reclaimRed),
                    const SizedBox(height: 22),
                    DisplayText('YOU MOVED\nTHROUGH\nTHE WORK.', color: declarationWhite, size: 67, redLastLine: true),
                    const SizedBox(height: 25),
                    BodyText('Your Power Move has been recorded at ${displayTimestamp(controller.commitments[day]?.timestamp)}.', color: const Color(0xFFC5C5C0), size: 14),
                    const Spacer(),
                    if (!isFinalDay)
                      PowerButton(
                        text: 'OPEN DAY ${formatDay(controller.unlockedDay)}',
                        onPressed: () => context.go('/day/${controller.unlockedDay}/secret'),
                      )
                    else
                      PowerButton(text: 'REVIEW THE 10 DAYS', onPressed: () => context.go('/record')),
                    TextButton(
                      onPressed: () => context.go('/record'),
                      child: Text('OPEN PRIVATE RECORD', style: GoogleFonts.poppins(color: declarationWhite, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key, required this.controller});
  final PracticeController controller;

  @override
  Widget build(BuildContext context) => PracticeShell(
        controller: controller,
        label: '${controller.completedCount} MOVES / LOCAL',
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final records = List<int>.generate(10, (index) => index + 1).where((day) => controller.responses.containsKey(day) || controller.commitments.containsKey(day)).toList();
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 34, 30, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IndexText('PRIVATE REFLECTION RECORD', color: reclaimRed),
                    const SizedBox(height: 16),
                    DisplayText('THE EVIDENCE\nYOU HAVE\nKEPT.', color: sovereignBlack, size: 55, redLastLine: true),
                    const SizedBox(height: 17),
                    BodyText('Review what you answered. Review what you committed to. This record exists to make patterns visible, not to turn your practice into a score.', color: const Color(0xFF454541), size: 14),
                    const SizedBox(height: 28),
                    EvidenceRegister(controller: controller),
                    const SizedBox(height: 27),
                    TenDayTracker(controller: controller),
                    const SizedBox(height: 34),
                    if (records.isEmpty)
                      EmptyRecord(controller: controller)
                    else
                      ...records.map((day) => ReflectionEntry(controller: controller, day: day)),
                    const SizedBox(height: 25),
                    const Divider(color: sovereignBlack, height: 1),
                    const SizedBox(height: 18),
                    PowerButton(text: 'OPEN DAY INDEX', inverse: true, onPressed: () => showPracticeIndex(context, controller)),
                  ],
                ),
              ),
            );
          },
        ),
      );
}

class EvidenceRegister extends StatelessWidget {
  const EvidenceRegister({super.key, required this.controller});
  final PracticeController controller;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(border: Border(left: BorderSide(color: reclaimRed, width: 4))),
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            _evidence('${controller.streakCount}', 'DAY STREAK'),
            _evidence('${controller.completedCount}/10', 'POWER MOVES'),
            _evidence(controller.firstPracticeAt == null ? '—' : displayTimestamp(controller.firstPracticeAt).split(',').first, 'FIRST PRACTICE'),
          ],
        ),
      );

  Widget _evidence(String value, String label) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.bebasNeue(color: sovereignBlack, fontSize: 35, height: .9)),
              const SizedBox(height: 7),
              IndexText(label, color: reclaimRed),
            ],
          ),
        ),
      );
}

class TenDayTracker extends StatelessWidget {
  const TenDayTracker({super.key, required this.controller});
  final PracticeController controller;

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(10, (index) {
          final number = index + 1;
          final complete = controller.commitments.containsKey(number);
          final current = number == controller.unlockedDay;
          return Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: complete ? sovereignBlack : declarationWhite,
                border: Border(
                  left: const BorderSide(color: paperLine),
                  right: const BorderSide(color: paperLine),
                  bottom: const BorderSide(color: paperLine),
                  top: current ? const BorderSide(color: reclaimRed, width: 4) : const BorderSide(color: paperLine),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IndexText('D${formatDay(number)}', color: complete ? declarationWhite : mutedInk),
                  const SizedBox(height: 6),
                  if (complete) const Icon(Icons.check, size: 14, color: reclaimRed) else Icon(current ? Icons.stop : Icons.lock_outline, size: 13, color: current ? reclaimRed : mutedInk),
                ],
              ),
            ),
          );
        }),
      );
}

class EmptyRecord extends StatelessWidget {
  const EmptyRecord({super.key, required this.controller});
  final PracticeController controller;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 19),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: sovereignBlack, width: 2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IndexText('NO PRIVATE RECORD YET', color: reclaimRed),
            const SizedBox(height: 15),
            DisplayText('THE FIRST ANSWER\nOPENS THE RECORD.', color: sovereignBlack, size: 43),
            const SizedBox(height: 14),
            BodyText('Day ${formatDay(controller.unlockedDay)} is ready. The record begins when you make your first response visible.', color: mutedInk, size: 14),
            const SizedBox(height: 18),
            PowerButton(text: 'BEGIN DAY ${formatDay(controller.unlockedDay)}', inverse: true, onPressed: () => context.go('/day/${controller.unlockedDay}/secret')),
          ],
        ),
      );
}

class ReflectionEntry extends StatelessWidget {
  const ReflectionEntry({super.key, required this.controller, required this.day});
  final PracticeController controller;
  final int day;

  @override
  Widget build(BuildContext context) {
    final content = days[day - 1];
    final answers = controller.responses[day] ?? const ['', '', ''];
    final commitment = controller.commitments[day];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.only(top: 18),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: sovereignBlack, width: 2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IndexText('DAY ${formatDay(day)} / ${commitment == null ? 'DIAGNOSTIC SAVED' : 'COMMITTED'}', color: reclaimRed),
              const Spacer(),
              TextButton.icon(
                iconAlignment: IconAlignment.end,
                onPressed: () => context.go('/day/$day/secret'),
                icon: const Icon(Icons.arrow_forward, size: 15),
                label: const Text('REOPEN DAY'),
                style: TextButton.styleFrom(foregroundColor: sovereignBlack, textStyle: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(content.secret, style: GoogleFonts.bebasNeue(color: sovereignBlack, fontSize: 33, height: .94)),
          const SizedBox(height: 17),
          ...List.generate(content.questions.length, (index) => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: paperLine))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IndexText('Q${index + 1}', color: reclaimRed),
              const SizedBox(height: 7),
              Text(content.questions[index], style: GoogleFonts.poppins(color: sovereignBlack, fontSize: 12, fontWeight: FontWeight.w600, height: 1.35)),
              const SizedBox(height: 6),
              BodyText(index < answers.length && answers[index].trim().isNotEmpty ? answers[index] : 'No answer was recorded.', color: mutedInk, size: 12),
            ]),
          )),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: commitment == null ? const Color(0xFFECECE7) : sovereignBlack,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IndexText('POWER MOVE', color: reclaimRed),
              const SizedBox(height: 9),
              BodyText(commitment?.note ?? 'Not yet committed.', color: commitment == null ? sovereignBlack : declarationWhite, size: 13),
              const SizedBox(height: 7),
              IndexText(commitment == null ? 'RETURN TO THE DAY TO COMMIT.' : 'COMMITTED ${displayTimestamp(commitment.timestamp)}', color: mutedInk),
            ]),
          ),
        ],
      ),
    );
  }
}

class ReadingScaffold extends StatelessWidget {
  const ReadingScaffold({super.key, required this.label, required this.title, required this.child, required this.footer, required this.action});
  final String label;
  final String title;
  final Widget child;
  final String footer;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 34, 30, 22),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IndexText(label, color: reclaimRed),
                  const SizedBox(height: 18),
                  DisplayText(title, color: sovereignBlack, size: 55),
                  const SizedBox(height: 26),
                  child,
                ]),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 19),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: paperLine))),
              child: Row(children: [
                Expanded(child: IndexText(footer, color: mutedInk)),
                const SizedBox(width: 10),
                PowerButton(text: 'CONTINUE', inverse: true, compact: true, onPressed: action),
              ]),
            ),
          ],
        ),
      );
}

class QuestionField extends StatelessWidget {
  const QuestionField({super.key, required this.number, required this.question, required this.controller});
  final int number;
  final String question;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(16, 17, 16, 12),
        decoration: const BoxDecoration(border: Border.fromBorderSide(BorderSide(color: sovereignBlack))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IndexText('0$number', color: reclaimRed),
          const SizedBox(height: 11),
          Text(question, style: GoogleFonts.poppins(color: sovereignBlack, fontSize: 14, fontWeight: FontWeight.w600, height: 1.42)),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 7,
            textInputAction: TextInputAction.newline,
            style: GoogleFonts.poppins(color: sovereignBlack, fontSize: 13, height: 1.5),
            decoration: _fieldDecoration('Write the answer you are willing to face.'),
          ),
        ]),
      );
}

InputDecoration _fieldDecoration(String placeholder, {bool dark = false}) => InputDecoration(
      hintText: placeholder,
      hintStyle: GoogleFonts.poppins(color: dark ? const Color(0xFF9A9A94) : const Color(0xFF989894), fontSize: 12, height: 1.5),
      isDense: true,
      contentPadding: const EdgeInsets.only(top: 12),
      border: UnderlineInputBorder(borderSide: BorderSide(color: dark ? const Color(0x3DF5F5F3) : paperLine)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dark ? const Color(0x3DF5F5F3) : paperLine)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: reclaimRed, width: 2)),
    );

class DisplayText extends StatelessWidget {
  const DisplayText(this.text, {super.key, required this.color, required this.size, this.redLastLine = false});
  final String text;
  final Color color;
  final double size;
  final bool redLastLine;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return RichText(
      text: TextSpan(
        children: List.generate(lines.length, (index) => TextSpan(
          text: '${lines[index]}${index == lines.length - 1 ? '' : '\n'}',
          style: GoogleFonts.bebasNeue(color: redLastLine && index == lines.length - 1 ? reclaimRed : color, fontSize: size, height: .82, letterSpacing: .5),
        )),
      ),
    );
  }
}

class BodyText extends StatelessWidget {
  const BodyText(this.text, {super.key, required this.color, required this.size});
  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.poppins(color: color, fontSize: size, height: 1.65));
}

class IndexText extends StatelessWidget {
  const IndexText(this.text, {super.key, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.poppins(color: color, fontSize: 9, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: 1.2));
}

class PowerButton extends StatelessWidget {
  const PowerButton({super.key, required this.text, required this.onPressed, this.inverse = false, this.red = false, this.disabled = false, this.compact = false});
  final String text;
  final VoidCallback onPressed;
  final bool inverse;
  final bool red;
  final bool disabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final background = red ? reclaimRed : inverse ? sovereignBlack : declarationWhite;
    final foreground = red || inverse ? declarationWhite : sovereignBlack;
    return SizedBox(
      height: compact ? 42 : 51,
      child: FilledButton.icon(
        onPressed: disabled ? null : onPressed,
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.arrow_forward, size: 17),
        label: Text(text),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: background.withValues(alpha: .35),
          foregroundColor: foreground,
          disabledForegroundColor: foreground.withValues(alpha: .7),
          padding: EdgeInsets.symmetric(horizontal: compact ? 15 : 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.poppins(fontSize: compact ? 9 : 11, fontWeight: FontWeight.w700, letterSpacing: 1.0),
        ),
      ),
    );
  }
}

Future<void> showPracticeIndex(BuildContext context, PracticeController controller) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: declarationWhite,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (sheetContext) => SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => DraggableScrollableSheet(
          initialChildSize: .86,
          minChildSize: .55,
          maxChildSize: .96,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.fromLTRB(25, 25, 25, 22),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const IndexText('10-DAY PRACTICE INDEX', color: reclaimRed),
                    const SizedBox(height: 12),
                    DisplayText('THE RECORD\nSO FAR.', color: sovereignBlack, size: 52),
                  ])),
                  IconButton(onPressed: () => Navigator.of(sheetContext).pop(), icon: const Icon(Icons.close)),
                ]),
                const SizedBox(height: 21),
                Row(children: [
                  _indexStat('${controller.completedCount}', 'COMMITTED'),
                  _indexStat('${controller.unlockedDay}', 'OPEN'),
                  _indexStat('${controller.streakCount}', 'DAY STREAK'),
                ]),
                const SizedBox(height: 25),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: days.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: sovereignBlack),
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final open = day <= controller.unlockedDay;
                      final complete = controller.commitments.containsKey(day);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        enabled: open,
                        onTap: open ? () { Navigator.of(sheetContext).pop(); context.go('/day/$day/secret'); } : null,
                        leading: SizedBox(width: 58, child: IndexText('DAY ${formatDay(day)}', color: reclaimRed)),
                        title: Text(days[index].secret, style: GoogleFonts.bebasNeue(color: open ? sovereignBlack : mutedInk, fontSize: 24, height: .95)),
                        subtitle: Padding(padding: const EdgeInsets.only(top: 7), child: IndexText(complete ? 'COMMITTED' : open ? 'OPEN' : 'LOCKED', color: mutedInk)),
                        trailing: complete ? const Icon(Icons.check, color: reclaimRed) : open ? const Icon(Icons.arrow_forward, color: sovereignBlack) : const Icon(Icons.lock_outline, color: mutedInk, size: 18),
                      );
                    },
                  ),
                ),
                const Divider(color: sovereignBlack, height: 1),
                const SizedBox(height: 11),
                Row(children: [
                  Expanded(child: BodyText('Your writing is saved only on this device.', color: mutedInk, size: 10)),
                  TextButton.icon(
                    onPressed: () async {
                      await controller.reset();
                      if (!sheetContext.mounted || !context.mounted) return;
                      Navigator.of(sheetContext).pop();
                      context.go('/');
                    },
                    icon: const Icon(Icons.restart_alt, size: 16),
                    label: const Text('RESET DEMO'),
                    style: TextButton.styleFrom(foregroundColor: sovereignBlack, textStyle: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _indexStat(String number, String label) => Expanded(
      child: Container(
        padding: const EdgeInsets.only(right: 8),
        decoration: const BoxDecoration(border: Border(right: BorderSide(color: paperLine))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(number, style: GoogleFonts.bebasNeue(color: reclaimRed, fontSize: 35, height: .9)),
          const SizedBox(height: 6),
          IndexText(label, color: sovereignBlack),
        ]),
      ),
    );

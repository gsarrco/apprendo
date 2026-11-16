import 'dart:math' as math;

/// Faithful Dart port of the ts-fsrs 5.4.1 scheduler (FSRS-6 with the
/// short-term scheduler and learning steps), using the exact defaults the
/// original Apprendo web app relied on: default weights, request retention
/// 0.9, maximum interval 36500, learning steps 1m/10m, relearning step 10m,
/// fuzz disabled.

enum Rating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  final int value;
  const Rating(this.value);
}

enum FsrsState {
  new_(0),
  learning(1),
  review(2),
  relearning(3);

  final int value;
  const FsrsState(this.value);
}

const List<double> kDefaultWeights = [
  0.212, 1.2931, 2.3065, 8.2956, 6.4133, 0.8334, 3.0194, 0.001, 1.8722, //
  0.1666, 0.796, 1.4835, 0.0614, 0.2629, 1.6483, 0.6014, 1.8729, 0.5425,
  0.0912, 0.0658, 0.1542,
];

const double kRequestRetention = 0.9;
const int kMaximumInterval = 36500;

/// Learning steps in minutes (ts-fsrs default: ['1m', '10m']).
const List<int> kLearningStepsMinutes = [1, 10];

/// Relearning steps in minutes (ts-fsrs default: ['10m']).
const List<int> kRelearningStepsMinutes = [10];

const double _sMin = 0.001;
const double _sMax = 36500.0;

class FsrsCard {
  DateTime due;
  double stability;
  double difficulty;
  int elapsedDays;
  int scheduledDays;
  int learningSteps;
  int reps;
  int lapses;
  FsrsState state;
  DateTime? lastReview;

  FsrsCard({
    required this.due,
    this.stability = 0,
    this.difficulty = 0,
    this.elapsedDays = 0,
    this.scheduledDays = 0,
    this.learningSteps = 0,
    this.reps = 0,
    this.lapses = 0,
    this.state = FsrsState.new_,
    this.lastReview,
  });

  FsrsCard copy() => FsrsCard(
        due: due,
        stability: stability,
        difficulty: difficulty,
        elapsedDays: elapsedDays,
        scheduledDays: scheduledDays,
        learningSteps: learningSteps,
        reps: reps,
        lapses: lapses,
        state: state,
        lastReview: lastReview,
      );
}

class FsrsReviewLog {
  final Rating rating;
  final FsrsState state;
  final DateTime due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int lastElapsedDays;
  final int scheduledDays;
  final int learningSteps;
  final DateTime review;

  const FsrsReviewLog({
    required this.rating,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.lastElapsedDays,
    required this.scheduledDays,
    required this.learningSteps,
    required this.review,
  });
}

class FsrsResult {
  final FsrsCard card;
  final FsrsReviewLog log;
  const FsrsResult(this.card, this.log);
}

double _clamp(double v, double min, double max) =>
    math.min(math.max(v, min), max);

double _roundTo(double v, int decimals) {
  final factor = math.pow(10, decimals).toDouble();
  return (v * factor).roundToDouble() / factor;
}

int _dateDiffInDays(DateTime last, DateTime cur) {
  final utc1 = DateTime.utc(last.year, last.month, last.day);
  final utc2 = DateTime.utc(cur.year, cur.month, cur.day);
  return utc2.difference(utc1).inDays;
}

DateTime _dateScheduler(DateTime now, int t, bool isDay) => DateTime.utc(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    ).add(isDay
        ? Duration(days: t)
        : Duration(milliseconds: t * 60 * 1000));

class _StepInfo {
  final int scheduledMinutes;
  final int nextStep;
  const _StepInfo(this.scheduledMinutes, this.nextStep);
}

/// The FSRS scheduler. All dates are handled in UTC.
class Fsrs {
  final List<double> w;
  final double requestRetention;
  final int maximumInterval;
  final List<int> learningStepsMinutes;
  final List<int> relearningStepsMinutes;
  final bool enableFuzz;
  final bool enableShortTerm;
  late final double _intervalModifier;
  late final double _decay;
  late final double _factor;

  Fsrs({
    List<double> weights = kDefaultWeights,
    this.requestRetention = kRequestRetention,
    this.maximumInterval = kMaximumInterval,
    this.learningStepsMinutes = kLearningStepsMinutes,
    this.relearningStepsMinutes = kRelearningStepsMinutes,
    this.enableFuzz = false,
    this.enableShortTerm = true,
  }) : w = weights {
    _decay = -w[20];
    _factor = _roundTo(math.exp(math.pow(_decay, -1) * math.log(0.9)) - 1, 8);
    _intervalModifier =
        _roundTo((math.pow(requestRetention, 1 / _decay) - 1) / _factor, 8);
  }

  /// A brand new card, due immediately (ts-fsrs `createEmptyCard`).
  FsrsCard createEmptyCard(DateTime now) => FsrsCard(due: now.toUtc());

  double _forgettingCurve(int elapsedDays, double stability) =>
      _roundTo(
        math.pow(1 + _factor * elapsedDays / stability, _decay).toDouble(),
        8,
      );

  double _initStability(Rating g) => math.max(w[g.value - 1], 0.1);

  double _initDifficulty(Rating g) =>
      _roundTo(w[4] - math.exp((g.value - 1) * w[5]) + 1, 8);

  int _nextInterval(double s, int elapsedDays) {
    final newInterval =
        math.min(math.max(1, (s * _intervalModifier).round()), maximumInterval);
    return _applyFuzz(newInterval, elapsedDays);
  }

  int _applyFuzz(int ivl, int elapsedDays) {
    if (!enableFuzz || ivl < 2.5) return ivl.round();
    throw UnsupportedError('fuzz is disabled in this port');
  }

  double _linearDamping(double deltaD, double oldD) =>
      _roundTo(deltaD * (10 - oldD) / 9, 8);

  double _meanReversion(double init, double current) =>
      _roundTo(w[7] * init + (1 - w[7]) * current, 8);

  double _nextDifficulty(double d, Rating g) {
    final deltaD = -w[6] * (g.value - 3);
    final nextD = d + _linearDamping(deltaD, d);
    return _clamp(_meanReversion(_initDifficulty(Rating.easy), nextD), 1, 10);
  }

  double _nextRecallStability(double d, double s, double r, Rating g) {
    final hardPenalty = g == Rating.hard ? w[15] : 1.0;
    final easyBonus = g == Rating.easy ? w[16] : 1.0;
    return _roundTo(
      _clamp(
        s *
            (1 +
                math.exp(w[8]) *
                    (11 - d) *
                    math.pow(s, -w[9]) *
                    (math.exp((1 - r) * w[10]) - 1) *
                    hardPenalty *
                    easyBonus),
        _sMin,
        _sMax,
      ),
      8,
    );
  }

  double _nextForgetStability(double d, double s, double r) => _roundTo(
        _clamp(
          w[11] *
              math.pow(d, -w[12]) *
              (math.pow(s + 1, w[13]) - 1) *
              math.exp((1 - r) * w[14]),
          _sMin,
          _sMax,
        ),
        8,
      );

  double _nextShortTermStability(double s, Rating g) {
    final sinc =
        math.pow(s, -w[19]) * math.exp(w[17] * (g.value - 3 + w[18]));
    final maskedSinc = g.value >= Rating.hard.value ? math.max(sinc, 1.0) : sinc;
    return _roundTo(_clamp(s * maskedSinc, _sMin, _sMax), 8);
  }

  ({double difficulty, double stability}) _nextState(
    ({double difficulty, double stability})? memoryState,
    int t,
    Rating g,
    double? r,
  ) {
    final d = memoryState?.difficulty ?? 0;
    final s = memoryState?.stability ?? 0;
    if (d == 0 && s == 0) {
      return (
        difficulty: _clamp(_initDifficulty(g), 1, 10),
        stability: _initStability(g),
      );
    }
    final r0 = r ?? _forgettingCurve(t, s);
    double newS;
    if (t == 0 && enableShortTerm) {
      newS = _nextShortTermStability(s, g);
    } else if (g == Rating.again) {
      final sAfterFail = _nextForgetStability(d, s, r0);
      final w17 = enableShortTerm ? w[17] : 0.0;
      final w18 = enableShortTerm ? w[18] : 0.0;
      final nextSMin = s / math.exp(w17 * w18);
      newS = _clamp(_roundTo(nextSMin, 8), _sMin, sAfterFail);
    } else {
      newS = _nextRecallStability(d, s, r0, g);
    }
    final newD = _nextDifficulty(d, g);
    return (difficulty: newD, stability: newS);
  }

  _StepInfo? _stepInfo(FsrsState state, int curStep, Rating grade) {
    final steps = (state == FsrsState.relearning || state == FsrsState.review)
        ? relearningStepsMinutes
        : learningStepsMinutes;
    final stepsLength = steps.length;
    if (stepsLength == 0 || curStep >= stepsLength) return null;

    if (state == FsrsState.review) {
      final step = steps[math.max(0, curStep).clamp(0, stepsLength - 1)];
      return _StepInfo(step, 0);
    }
    switch (grade) {
      case Rating.again:
        return _StepInfo(steps[0], 0);
      case Rating.hard:
        final minutes = stepsLength == 1
            ? (steps[0] * 1.5).round()
            : ((steps[0] + steps[1]) / 2).round();
        return _StepInfo(minutes, curStep);
      case Rating.good:
        final nextIdx = curStep + 1;
        if (nextIdx < 0 || nextIdx >= stepsLength) return null;
        final minutes = steps[nextIdx];
        if (minutes == 0) return null;
        return _StepInfo(minutes.round(), nextIdx);
      case Rating.easy:
        return null;
    }
  }

  FsrsResult next(FsrsCard card, DateTime now, Rating grade) {
    final scheduler = _BasicScheduler(card, now, this);
    return scheduler.review(grade);
  }

  /// Interval previews for all four grades from the same card state.
  Map<Rating, FsrsResult> preview(FsrsCard card, DateTime now) {
    final scheduler = _BasicScheduler(card, now, this);
    return {
      for (final g in Rating.values) g: scheduler.review(g),
    };
  }
}

class _BasicScheduler {
  final FsrsCard last;
  late final FsrsCard current;
  final DateTime reviewTime;
  final Fsrs algorithm;
  int elapsedDays = 0;

  _BasicScheduler(FsrsCard card, DateTime now, this.algorithm)
      : last = card.copy(),
        reviewTime = now.toUtc() {
    current = card.copy();
    var interval = 0;
    if (current.state != FsrsState.new_ && current.lastReview != null) {
      interval = _dateDiffInDays(current.lastReview!, reviewTime);
    }
    current.lastReview = reviewTime;
    current.elapsedDays = interval;
    elapsedDays = interval;
    current.reps += 1;
  }

  FsrsResult review(Rating grade) {
    final FsrsResult item;
    switch (last.state) {
      case FsrsState.new_:
        item = _newState(grade);
      case FsrsState.learning:
      case FsrsState.relearning:
        item = _learningState(grade);
      case FsrsState.review:
        item = _reviewState(grade);
    }
    return item;
  }

  FsrsCard _nextDs(int t, Rating g, [double? r]) {
    final state = algorithm._nextState(
      (difficulty: current.difficulty, stability: current.stability),
      t,
      g,
      r,
    );
    final card = current.copy();
    card.difficulty = state.difficulty;
    card.stability = state.stability;
    return card;
  }

  void _applyLearningSteps(FsrsCard nextCard, Rating grade, FsrsState toState) {
    final info = algorithm._stepInfo(current.state, current.learningSteps, grade);
    final scheduledMinutes = info?.scheduledMinutes ?? 0;
    final nextSteps = info?.nextStep ?? 0;
    if (scheduledMinutes > 0 && scheduledMinutes < 1440) {
      nextCard.learningSteps = nextSteps;
      nextCard.scheduledDays = 0;
      nextCard.state = toState;
      nextCard.due = _dateScheduler(reviewTime, scheduledMinutes, false);
    } else {
      nextCard.state = FsrsState.review;
      if (scheduledMinutes >= 1440) {
        nextCard.learningSteps = nextSteps;
        nextCard.due =
            _dateScheduler(reviewTime, scheduledMinutes.round(), false);
        nextCard.scheduledDays = scheduledMinutes ~/ 1440;
      } else {
        nextCard.learningSteps = 0;
        final interval =
            algorithm._nextInterval(nextCard.stability, elapsedDays);
        nextCard.scheduledDays = interval;
        nextCard.due = _dateScheduler(reviewTime, interval, true);
      }
    }
  }

  FsrsReviewLog _buildLog(Rating rating) => FsrsReviewLog(
        rating: rating,
        state: current.state,
        due: last.lastReview ?? last.due,
        stability: current.stability,
        difficulty: current.difficulty,
        elapsedDays: elapsedDays,
        lastElapsedDays: last.elapsedDays,
        scheduledDays: current.scheduledDays,
        learningSteps: current.learningSteps,
        review: reviewTime,
      );

  FsrsResult _newState(Rating grade) {
    final next = _nextDs(elapsedDays, grade);
    _applyLearningSteps(next, grade, FsrsState.learning);
    return FsrsResult(next, _buildLog(grade));
  }

  FsrsResult _learningState(Rating grade) {
    final next = _nextDs(elapsedDays, grade);
    _applyLearningSteps(next, grade, last.state);
    return FsrsResult(next, _buildLog(grade));
  }

  FsrsResult _reviewState(Rating grade) {
    final interval = elapsedDays;
    final retrievability =
        algorithm._forgettingCurve(interval, current.stability);
    final nextAgain = _nextDs(interval, Rating.again, retrievability);
    final nextHard = _nextDs(interval, Rating.hard, retrievability);
    final nextGood = _nextDs(interval, Rating.good, retrievability);
    final nextEasy = _nextDs(interval, Rating.easy, retrievability);

    var hardInterval = algorithm._nextInterval(nextHard.stability, interval);
    var goodInterval = algorithm._nextInterval(nextGood.stability, interval);
    hardInterval = math.min(hardInterval, goodInterval);
    goodInterval = math.max(goodInterval, hardInterval + 1);
    final easyInterval = math.max(
      algorithm._nextInterval(nextEasy.stability, interval),
      goodInterval + 1,
    );
    nextHard.scheduledDays = hardInterval;
    nextHard.due = _dateScheduler(reviewTime, hardInterval, true);
    nextGood.scheduledDays = goodInterval;
    nextGood.due = _dateScheduler(reviewTime, goodInterval, true);
    nextEasy.scheduledDays = easyInterval;
    nextEasy.due = _dateScheduler(reviewTime, easyInterval, true);

    for (final c in [nextHard, nextGood, nextEasy]) {
      c.state = FsrsState.review;
      c.learningSteps = 0;
    }

    _applyLearningSteps(nextAgain, Rating.again, FsrsState.relearning);
    nextAgain.lapses += 1;

    return switch (grade) {
      Rating.again => FsrsResult(nextAgain, _buildLog(Rating.again)),
      Rating.hard => FsrsResult(nextHard, _buildLog(Rating.hard)),
      Rating.good => FsrsResult(nextGood, _buildLog(Rating.good)),
      Rating.easy => FsrsResult(nextEasy, _buildLog(Rating.easy)),
    };
  }
}

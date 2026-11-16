import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:apprendo/fsrs/fsrs.dart';
import 'package:apprendo/fsrs/mappers.dart';
import 'package:apprendo/domain/models.dart';

/// Replays golden vectors generated from the actual ts-fsrs 5.4.1 (the
/// scheduler the original web app used) and asserts the Dart port
/// produces identical results, field by field.
void main() {
  final golden = jsonDecode(
      File('test/fixtures/golden.json').readAsStringSync()) as List<dynamic>;

  // Vectors with a single expected result (previews handled separately).
  final singles =
      golden.where((v) => v['label'] != 'previews').cast<Map<String, dynamic>>();

  FsrsCard cardFrom(Map<String, dynamic> m) => FsrsCard(
        due: parseIso(m['due']),
        stability: (m['stability'] as num).toDouble(),
        difficulty: (m['difficulty'] as num).toDouble(),
        elapsedDays: m['elapsed_days'] as int,
        scheduledDays: m['scheduled_days'] as int,
        learningSteps: m['learning_steps'] as int,
        reps: m['reps'] as int,
        lapses: m['lapses'] as int,
        state: FsrsState.values[m['state'] as int],
        lastReview: m['last_review'] == null ? null : parseIso(m['last_review']),
      );

  void expectClose(double actual, double expected, String what) {
    expect((actual - expected).abs() <= 1e-9, isTrue,
        reason: '$what: $actual vs $expected');
  }

  test('golden vectors match ts-fsrs exactly', () {
    final fsrs = Fsrs();
    for (final v in singles) {
      final inCard = cardFrom(v['in'] as Map<String, dynamic>);
      final rating = Rating.values[(v['rating'] as num).toInt() - 1];
      final now = parseIso(v['now']);
      final result = fsrs.next(inCard, now, rating);

      final out = v['outCard'] as Map<String, dynamic>;
      expect(toIsoUtc(result.card.due), out['due'],
          reason: '${v['label']}: due');
      expectClose(result.card.stability, (out['stability'] as num).toDouble(),
          '${v['label']}: stability');
      expectClose(result.card.difficulty, (out['difficulty'] as num).toDouble(),
          '${v['label']}: difficulty');
      expect(result.card.elapsedDays, out['elapsed_days'],
          reason: '${v['label']}: elapsed_days');
      expect(result.card.scheduledDays, out['scheduled_days'],
          reason: '${v['label']}: scheduled_days');
      expect(result.card.learningSteps, out['learning_steps'],
          reason: '${v['label']}: learning_steps');
      expect(result.card.reps, out['reps'], reason: '${v['label']}: reps');
      expect(result.card.lapses, out['lapses'],
          reason: '${v['label']}: lapses');
      expect(result.card.state.value, out['state'],
          reason: '${v['label']}: state');
      expect(
          result.card.lastReview == null
              ? null
              : toIsoUtc(result.card.lastReview!),
          out['last_review'],
          reason: '${v['label']}: last_review');

      final log = v['outLog'] as Map<String, dynamic>;
      expect(result.log.rating.value, log['rating'],
          reason: '${v['label']}: log.rating');
      expect(result.log.state.value, log['state'],
          reason: '${v['label']}: log.state');
      expect(toIsoUtc(result.log.due), log['due'],
          reason: '${v['label']}: log.due');
      expectClose(result.log.stability, (log['stability'] as num).toDouble(),
          '${v['label']}: log.stability');
      expectClose(result.log.difficulty, (log['difficulty'] as num).toDouble(),
          '${v['label']}: log.difficulty');
      expect(result.log.elapsedDays, log['elapsed_days'],
          reason: '${v['label']}: log.elapsed_days');
      expect(result.log.lastElapsedDays, log['last_elapsed_days'],
          reason: '${v['label']}: log.last_elapsed_days');
      expect(result.log.scheduledDays, log['scheduled_days'],
          reason: '${v['label']}: log.scheduled_days');
      expect(result.log.learningSteps, log['learning_steps'],
          reason: '${v['label']}: log.learning_steps');
      expect(toIsoUtc(result.log.review), log['review'],
          reason: '${v['label']}: log.review');
    }
  });

  test('interval previews match ts-fsrs', () {
    final v = golden.firstWhere((v) => v['label'] == 'previews')
        as Map<String, dynamic>;
    final fsrs = Fsrs();
    // Rebuild the review-state card from the last short-* vector.
    final last = singles.lastWhere((s) =>
        (s['label'] as String).startsWith('short-'));
    final inCard = cardFrom(last['outCard'] as Map<String, dynamic>);
    final now = parseIso(v['now']);
    final previews = fsrs.preview(inCard, now);
    final expected = v['previews'] as Map<String, dynamic>;
    for (final rating in Rating.values) {
      final exp = expected[rating.value.toString()] as Map<String, dynamic>;
      final res = previews[rating]!;
      expect(toIsoUtc(res.card.due), exp['due'],
          reason: 'preview ${rating.name}: due');
      expect(res.card.scheduledDays, exp['scheduled_days'],
          reason: 'preview ${rating.name}: scheduled_days');
      expect(res.card.state.value, exp['state'],
          reason: 'preview ${rating.name}: state');
    }
  });

  test('createEmptyCard matches ts-fsrs', () {
    final fsrs = Fsrs();
    final card = fsrs.createEmptyCard(parseIso('2026-01-15T09:00:00.000Z'));
    expect(card.due, parseIso('2026-01-15T09:00:00.000Z'));
    expect(card.stability, 0);
    expect(card.difficulty, 0);
    expect(card.state, FsrsState.new_);
    expect(card.reps, 0);
    expect(card.lapses, 0);
    expect(card.learningSteps, 0);
  });

  test('mappers round-trip a card', () {
    final doc = CardDoc(
      id: 'x',
      deckId: 'd',
      front: 'front',
      back: 'back',
      due: '2026-01-15T09:00:00.000Z',
      stability: 3.4,
      difficulty: 5.6,
      elapsedDays: 2,
      scheduledDays: 4,
      learningSteps: 0,
      reps: 3,
      lapses: 1,
      state: 2,
      lastReview: '2026-01-11T09:00:00.000Z',
      createdAt: 1,
      updatedAt: 2,
    );
    final fsrsCard = FsrsMappers.toFsrsCard(doc);
    final back = FsrsMappers.fromFsrsCard(fsrsCard, doc, 42);
    expect(back.due, doc.due);
    expect(back.stability, doc.stability);
    expect(back.difficulty, doc.difficulty);
    expect(back.state, doc.state);
    expect(back.lastReview, doc.lastReview);
    expect(back.updatedAt, 42);
  });
}

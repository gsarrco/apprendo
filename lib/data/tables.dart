import 'package:drift/drift.dart';

/// A deck of flashcards.
@DataClassName('DeckRow')
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A single flashcard. The FSRS scheduling fields mirror the columns the
/// original app persisted per card.
@DataClassName('CardRow')
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId =>
      text().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get front => text()();
  TextColumn get back => text()();

  /// ISO-8601 timestamp of the next due date.
  TextColumn get due => text()();
  RealColumn get stability => real().withDefault(const Constant(0))();
  RealColumn get difficulty => real().withDefault(const Constant(0))();
  IntColumn get elapsedDays => integer().withDefault(const Constant(0))();
  IntColumn get scheduledDays => integer().withDefault(const Constant(0))();
  IntColumn get learningSteps => integer().withDefault(const Constant(0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();

  /// 0 = new, 1 = learning, 2 = review, 3 = relearning.
  IntColumn get state => integer().withDefault(const Constant(0))();
  TextColumn get lastReview => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Attachments are normalized out of the card document into their own
/// table, ordered by [position] within a card side.
@DataClassName('CardAttachmentRow')
class CardAttachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();

  /// Either 'front' or 'back'.
  TextColumn get side => text()();
  IntColumn get position => integer()();

  /// Either 'image' or 'audio'.
  TextColumn get type => text()();
  TextColumn get caption => text().withDefault(const Constant(''))();
  TextColumn get attribution => text().nullable()();
  TextColumn get languageQid => text().nullable()();

  /// The raw file bytes. Attachments are always stored in the database.
  BlobColumn get content => blob()();

  /// Mime type of [content], e.g. 'image/jpeg' or 'audio/ogg'.
  TextColumn get mimeType => text()();
  IntColumn get createdAt => integer()();
}

/// Append-only FSRS review history. Deliberately not a foreign key: the
/// original app kept review logs alive after card deletion.
@DataClassName('ReviewLogRow')
class ReviewLogs extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text()();
  IntColumn get rating => integer()();
  IntColumn get state => integer()();
  TextColumn get due => text()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
  IntColumn get elapsedDays => integer()();
  IntColumn get lastElapsedDays => integer()();
  IntColumn get scheduledDays => integer()();
  IntColumn get learningSteps => integer()();
  TextColumn get review => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A named group of decks studied together.
@DataClassName('StudyTagRow')
class StudyTags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Join table resolving which decks belong to which study tag.
@DataClassName('StudyTagDeckRow')
class StudyTagDecks extends Table {
  TextColumn get studyTagId =>
      text().references(StudyTags, #id, onDelete: KeyAction.cascade)();
  TextColumn get deckId =>
      text().references(Decks, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {studyTagId, deckId};
}

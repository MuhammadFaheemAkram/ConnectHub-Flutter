import 'dart:math';

import 'package:clock/clock.dart';
import 'package:connect_hub/core/common/id_generator.dart';
import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/network/asset_json_loader.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/reply_scheduler.dart';
import 'package:connect_hub/core/network/fake_server/seed_loader.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';

/// The moment every test's fake server launches at.
final testNow = DateTime.utc(2026, 10, 11, 12);

/// The real in-memory fake server, seeded from the bundled JSON, with
/// repeatable ids and a fixed clock. Needs
/// `TestWidgetsFlutterBinding.ensureInitialized()` for the asset bundle.
///
/// Its chat replies run on real timers ([replies], 1.9 s by default): call
/// `dispose()` in `tearDown`. A test that waits for replies passes a quick
/// scheduler instead ([quickReplies]).
FakeServer newFakeServer({Clock? clock, ReplyScheduler? replies}) => FakeServer(
  SeedLoader(AssetJsonLoader(rootBundle)),
  IdGenerator(random: Random(1)),
  clock ?? Clock.fixed(testNow),
  replies ?? ReplyScheduler(),
);

/// A [ReplyScheduler] that answers within a millisecond, for tests that wait
/// for replies in real time. (Its timing is tested in fake time.)
ReplyScheduler quickReplies() => ReplyScheduler(
  typingDelay: Duration.zero,
  replyDelay: const Duration(milliseconds: 1),
);

/// A fresh in-memory database: no disk, no state shared between tests. Close
/// it in `tearDown`.
///
/// Streams close synchronously, so a widget test doesn't end with drift's
/// stream-cleanup timer still pending.
AppDatabase newTestDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

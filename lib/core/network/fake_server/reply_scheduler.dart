import 'dart:async';

import 'package:injectable/injectable.dart';

/// Plays the other person in every chat: after each message the user sends,
/// they "type" for a moment, then answer.
///
/// - [typingDelay] after a message is acknowledged, typing starts, unless a
///   reply is already pending in that conversation (they're still typing);
/// - [replyDelay] later, the reply arrives;
/// - typing stops when the last pending reply has arrived.
///
/// So messages sent in quick succession keep one typing indicator on until
/// the last reply (Correctness Rule 8). Both native editions turned it off
/// too early, or showed it too soon.
///
/// It runs on plain [Timer]s: real time in the app, fake time in tests
/// (`fake_async`, or `tester.pump` in widget tests).
@lazySingleton
class ReplyScheduler {
  ReplyScheduler({
    @ignoreParam this.typingDelay = const Duration(milliseconds: 400),
    @ignoreParam this.replyDelay = const Duration(milliseconds: 1500),
  });

  final Duration typingDelay;
  final Duration replyDelay;

  /// Replies still to come, per conversation.
  final _pending = <String, int>{};
  final _timers = <Timer>{};

  int pendingReplies(String conversationId) => _pending[conversationId] ?? 0;

  /// Schedules one reply in [conversationId], calling back as it happens.
  void schedule(
    String conversationId, {
    required void Function() onTypingStarted,
    required void Function() onReply,
    required void Function() onTypingStopped,
  }) {
    final alreadyTyping = pendingReplies(conversationId) > 0;
    _pending[conversationId] = pendingReplies(conversationId) + 1;
    if (!alreadyTyping) _after(typingDelay, onTypingStarted);
    _after(typingDelay + replyDelay, () {
      onReply();
      final left = pendingReplies(conversationId) - 1;
      if (left > 0) {
        _pending[conversationId] = left;
      } else {
        _pending.remove(conversationId);
        onTypingStopped();
      }
    });
  }

  /// Cancels every reply still to come (a test's tear-down).
  void cancelAll() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    _pending.clear();
  }

  void _after(Duration delay, void Function() action) {
    late final Timer timer;
    timer = Timer(delay, () {
      _timers.remove(timer);
      action();
    });
    _timers.add(timer);
  }
}

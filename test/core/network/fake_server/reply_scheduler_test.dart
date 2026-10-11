import 'package:connect_hub/core/network/fake_server/reply_scheduler.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// What the scheduler reported, in order, e.g. `typing c1`.
  late List<String> log;
  late ReplyScheduler replies;

  setUp(() {
    log = [];
    replies = ReplyScheduler();
  });

  void schedule(String conversationId) => replies.schedule(
    conversationId,
    onTypingStarted: () => log.add('typing $conversationId'),
    onReply: () => log.add('reply $conversationId'),
    onTypingStopped: () => log.add('stopped $conversationId'),
  );

  test('typing starts after 400 ms, and the reply arrives 1.5 s later, '
      'when typing stops', () {
    fakeAsync((time) {
      schedule('c1');

      time.elapse(const Duration(milliseconds: 399));
      expect(log, isEmpty);
      time.elapse(const Duration(milliseconds: 1));
      expect(log, ['typing c1']);
      expect(replies.pendingReplies('c1'), 1);

      time.elapse(const Duration(milliseconds: 1500));
      expect(log, ['typing c1', 'reply c1', 'stopped c1']);
      expect(replies.pendingReplies('c1'), 0);
    });
  });

  test('messages in quick succession keep one typing indicator on until the '
      'last reply (Correctness Rule 8)', () {
    fakeAsync((time) {
      schedule('c1');
      time.elapse(const Duration(milliseconds: 500));
      schedule('c1');
      expect(replies.pendingReplies('c1'), 2);

      // The first reply arrives; the second is still on its way.
      time.elapse(const Duration(milliseconds: 1400));
      expect(log, ['typing c1', 'reply c1']);

      time.elapse(const Duration(milliseconds: 500));
      expect(log, ['typing c1', 'reply c1', 'reply c1', 'stopped c1']);
    });
  });

  test('conversations are independent', () {
    fakeAsync((time) {
      schedule('c1');
      schedule('c2');
      time.elapse(const Duration(seconds: 2));

      expect(log, [
        'typing c1',
        'typing c2',
        'reply c1',
        'stopped c1',
        'reply c2',
        'stopped c2',
      ]);
    });
  });

  test('cancelAll stops every reply still to come', () {
    fakeAsync((time) {
      schedule('c1');
      time.elapse(const Duration(milliseconds: 500));

      replies.cancelAll();
      time.elapse(const Duration(seconds: 5));

      expect(log, ['typing c1']);
      expect(replies.pendingReplies('c1'), 0);
      expect(time.pendingTimers, isEmpty);
    });
  });
}

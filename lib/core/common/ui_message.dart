import 'package:freezed_annotation/freezed_annotation.dart';

part 'ui_message.freezed.dart';

/// A one-time message for the UI, such as a SnackBar's text.
///
/// One-time effects live in state, like everything else the screen shows
/// (conventions §2). The View shows a message when it *changes*:
/// `BlocListener(listenWhen: (previous, current) => …message changed…)`.
///
/// The [id] makes two messages with the same text distinct, so a failure
/// that repeats is reported again instead of being swallowed as "no change".
@freezed
abstract class UiMessage with _$UiMessage {
  const factory UiMessage({
    required int id,
    required String text,

    /// A button on the message, such as Undo.
    UiMessageAction? action,
  }) = _UiMessage;
}

/// A button a message can offer. State stays plain data: the View maps the
/// action to the Cubit method that performs it.
enum UiMessageAction {
  undo('Undo');

  const UiMessageAction(this.label);

  final String label;
}

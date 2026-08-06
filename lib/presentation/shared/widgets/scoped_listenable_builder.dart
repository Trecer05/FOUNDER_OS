import 'package:flutter/widgets.dart';

/// Marks a retained tab subtree as active or inactive.
///
/// IndexedStack keeps state and scroll positions alive. Descendant
/// [ScopedListenableBuilder] widgets detach from their listenables while the
/// subtree is hidden, so background tabs do not rebuild on every simulation
/// tick.
class ActiveTabScope extends InheritedWidget {
  const ActiveTabScope({required this.active, required super.child, super.key});

  final bool active;

  static ActiveTabScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ActiveTabScope>();

  @override
  bool updateShouldNotify(ActiveTabScope oldWidget) =>
      oldWidget.active != active;
}

/// Drop-in replacement for [ListenableBuilder] that pauses notifications in a
/// retained but inactive [ActiveTabScope]. Outside a scope it behaves exactly
/// like a regular ListenableBuilder.
class ScopedListenableBuilder extends StatefulWidget {
  const ScopedListenableBuilder({
    required this.listenable,
    required this.builder,
    this.child,
    super.key,
  });

  final Listenable listenable;
  final TransitionBuilder builder;
  final Widget? child;

  @override
  State<ScopedListenableBuilder> createState() =>
      _ScopedListenableBuilderState();
}

/// AnimatedBuilder-compatible wrapper with the same inactive-tab behavior.
class ScopedAnimatedBuilder extends StatelessWidget {
  const ScopedAnimatedBuilder({
    required this.animation,
    required this.builder,
    this.child,
    super.key,
  });

  final Listenable animation;
  final TransitionBuilder builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) => ScopedListenableBuilder(
    listenable: animation,
    builder: builder,
    child: child,
  );
}

class _ScopedListenableBuilderState extends State<ScopedListenableBuilder> {
  bool _subscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSubscription();
  }

  @override
  void didUpdateWidget(ScopedListenableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      if (_subscribed) {
        oldWidget.listenable.removeListener(_handleChange);
        _subscribed = false;
      }
      _syncSubscription();
    }
  }

  void _syncSubscription() {
    final shouldSubscribe = ActiveTabScope.maybeOf(context)?.active ?? true;
    if (shouldSubscribe == _subscribed) {
      return;
    }
    if (shouldSubscribe) {
      widget.listenable.addListener(_handleChange);
    } else {
      widget.listenable.removeListener(_handleChange);
    }
    _subscribed = shouldSubscribe;
  }

  void _handleChange() {
    if (mounted && _subscribed) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_subscribed) {
      widget.listenable.removeListener(_handleChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.child);
}

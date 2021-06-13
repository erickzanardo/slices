import 'package:flutter/widgets.dart';

@immutable
abstract class SlicesState {}

class SlicesStore<T extends SlicesState> {
  T state;

  SlicesStore(this.state);

  List<void Function(SlicesStore<T>)> _listeners = [];

  void listen(void Function(SlicesStore<T>) listener) {
    _listeners.add(listener);
  }

  void dispose(void Function(SlicesStore<T>) listener) {
    _listeners.remove(listener);
  }

  void dispatch(SlicesAction<T> action) {
    state = action.perform(this, state);
    _notifyListeners();
  }

  Future<void> dispatchAsync(AsyncSlicesAction<T> action) async {
    state = await action.perform(this, state);
    _notifyListeners();
  }

  void _notifyListeners() {
    _listeners.forEach((l) => l.call(this));
  }
}

@immutable
abstract class SlicesAction<T extends SlicesState> {
  T perform(SlicesStore<T> store, T state);
}

@immutable
abstract class AsyncSlicesAction<T extends SlicesState> {
  Future<T> perform(SlicesStore<T> store, T state);
}

class SlicesProvider<T extends SlicesState> extends InheritedWidget {
  final SlicesStore<T> store;

  SlicesProvider({
    Key? key,
    required this.store,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(SlicesProvider old) => store != old.store;

  static SlicesStore<S> of<S extends SlicesState>(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<SlicesProvider<S>>();

    if (widget == null) {
      throw 'No SlicesProvider available on the tree';
    }

    return widget.store;
  }
}

typedef SlicerFn<T extends SlicesState, S> = S Function(T);
typedef SlicerRebuildFn<S> = bool Function(S oldState, S newState);

typedef SliceWatcherBuilder<T extends SlicesState, S> = Widget Function(
    BuildContext, SlicesStore<T>, S);

class SliceWatcher<T extends SlicesState, S> extends StatefulWidget {
  final SliceWatcherBuilder<T, S> builder;
  final SlicerFn<T, S> slicer;
  final SlicerRebuildFn<S>? shouldRebuild;

  SliceWatcher({
    Key? key,
    required this.builder,
    required this.slicer,
    this.shouldRebuild,
  }) : super(key: key);

  @override
  State createState() => _SliceWatcherState<T, S>();
}

class _SliceWatcherState<T extends SlicesState, S>
    extends State<SliceWatcher<T, S>> {
  late SlicesStore<T> _store;
  late S _memoValue;

  bool _shouldRebuild(S oldValue, S newValue) {
    if (widget.shouldRebuild != null) {
      return widget.shouldRebuild!(oldValue, newValue);
    } else {
      return oldValue != newValue;
    }
  }

  void _update(SlicesStore<T> store) {
    S newMemo = widget.slicer(store.state);

    if (!_shouldRebuild(_memoValue, newMemo)) {
      return;
    }

    setState(() {
      _store = store;
      _memoValue = newMemo;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _store = SlicesProvider.of<T>(context);
    _store.listen(_update);

    _memoValue = widget.slicer.call(_store.state);
  }

  @override
  void dispose() {
    super.dispose();
    _store.dispose(_update);
  }

  @override
  Widget build(context) => widget.builder(context, _store, _memoValue);
}

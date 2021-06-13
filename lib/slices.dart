import 'package:flutter/widgets.dart';

@immutable
abstract class SlicesState {}

typedef SlicesStoreListenerFn<T extends SlicesState> = void Function(
    SlicesStore<T>, SlicesEvent<T>);

class SlicesStore<T extends SlicesState> {
  T state;

  SlicesStore(this.state);

  List<SlicesStoreListenerFn<T>> _listeners = [];

  void listen(SlicesStoreListenerFn<T> listener) {
    _listeners.add(listener);
  }

  void dispose(SlicesStoreListenerFn<T> listener) {
    _listeners.remove(listener);
  }

  void event(SlicesEvent<T> event) {
    _notifyListeners(event);
  }

  void dispatch(SlicesAction<T> action) {
    state = action.perform(this, state);
    _notifyListeners(action);
  }

  Future<void> dispatchAsync(AsyncSlicesAction<T> action) async {
    state = await action.perform(this, state);
    _notifyListeners(action);
  }

  void _notifyListeners(SlicesEvent<T> event) {
    _listeners.forEach((l) => l.call(this, event));
  }
}

@immutable
abstract class SlicesEvent<T extends SlicesState> {}

@immutable
abstract class SlicesAction<T extends SlicesState> extends SlicesEvent<T> {
  T perform(SlicesStore<T> store, T state);
}

@immutable
abstract class AsyncSlicesAction<T extends SlicesState> extends SlicesEvent<T> {
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

typedef SlicerListenerFn<T extends SlicesState> = void Function(
    T, SlicesEvent<T>);

typedef SlicerRebuildFn<S> = bool Function(S oldState, S newState);

typedef SliceWatcherBuilder<T extends SlicesState, S> = Widget Function(
    BuildContext, SlicesStore<T>, S);

class SliceWatcher<T extends SlicesState, S> extends StatefulWidget {
  final SliceWatcherBuilder<T, S> builder;
  final SlicerFn<T, S> slicer;
  final SlicerRebuildFn<S>? shouldRebuild;
  final SlicerListenerFn<T>? listener;

  SliceWatcher({
    Key? key,
    required this.builder,
    required this.slicer,
    this.shouldRebuild,
    this.listener,
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

  void _update(SlicesStore<T> store, SlicesEvent<T> event) {
    widget.listener?.call(store.state, event);

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

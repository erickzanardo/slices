import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:slices/slices.dart';

class CounterState extends SlicesState {
  final int count;

  CounterState(this.count);
}

class CounterStore extends SlicesStore<CounterState> {
  CounterStore(CounterState state) : super(state);
}

class IncrementAction extends SlicesAction<CounterState> {
  final int ammount;

  IncrementAction(this.ammount);

  @override
  CounterState perform(SlicesStore<SlicesState> store, CounterState state) {
    return CounterState(state.count + ammount);
  }
}

class MyEvent extends SlicesEvent<CounterState> {}

abstract class StateListener {
  void listen(SlicesStore<CounterState> store, SlicesEvent<CounterState> event);
}

class DummyStateListener extends Mock implements StateListener {}

class AsyncIncrementAction extends AsyncSlicesAction<CounterState> {
  final int ammount;

  AsyncIncrementAction(this.ammount);

  @override
  Future<CounterState> perform(
      SlicesStore<SlicesState> store, CounterState state) {
    return Future.value(CounterState(state.count + ammount));
  }
}

void main() {
  group("Store", () {
    test("Actions can update the store's state", () {
      final store = CounterStore(CounterState(1));
      store.dispatch(IncrementAction(1));

      expect(store.state.count, 2);
    });

    test("Async actions can update the store's state", () async {
      final store = CounterStore(CounterState(1));
      await store.dispatchAsync(AsyncIncrementAction(1));

      expect(store.state.count, 2);
    });

    test("Calls the listener when an action happens", () {
      final dummyListener = DummyStateListener();
      final store = CounterStore(CounterState(1));
      store.listen(dummyListener.listen);

      final event = IncrementAction(1);
      store.dispatch(event);

      verify(dummyListener.listen(store, event));
    });

    test("Calls the listener when an async action happens", () async {
      final dummyListener = DummyStateListener();
      final store = CounterStore(CounterState(1));
      store.listen(dummyListener.listen);

      final event = AsyncIncrementAction(1);
      await store.dispatchAsync(event);

      verify(dummyListener.listen(store, event));
    });

    test("Calls the listener when an event happens", () {
      final dummyListener = DummyStateListener();
      final store = CounterStore(CounterState(1));
      store.listen(dummyListener.listen);

      final event = MyEvent();
      store.event(event);

      verify(dummyListener.listen(store, event));
    });

    test("Correctly removes a listener", () {
      final dummyListener = DummyStateListener();
      final store = CounterStore(CounterState(1));
      store.listen(dummyListener.listen);
      final event = IncrementAction(1);
      store.dispatch(event);
      store.dispose(dummyListener.listen);
      store.dispatch(IncrementAction(1));

      verify(dummyListener.listen(store, event)).called(1);
    });
  });
}

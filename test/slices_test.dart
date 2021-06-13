import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slices/slices.dart';

class MyState extends SlicesState {
  final String firstName;
  final String lastName;

  MyState({
    required this.firstName,
    required this.lastName,
  });

  MyState copyWith({
    String? firstName,
    String? lastName,
  }) {
    return MyState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}

class ChangeFirstNameAction extends SlicesAction<MyState> {
  final String newName;

  ChangeFirstNameAction(this.newName);

  @override
  MyState perform(SlicesStore<MyState> store, MyState state) {
    return state.copyWith(firstName: newName);
  }
}

class ChangeLastNameAction extends SlicesAction<MyState> {
  final String newName;

  ChangeLastNameAction(this.newName);

  @override
  MyState perform(SlicesStore<MyState> store, MyState state) {
    return state.copyWith(lastName: newName);
  }
}

class NameSlice {
  final String name;

  NameSlice(this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NameSlice &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class FirstNameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliceWatcher<MyState, NameSlice>(
      slicer: (state) => NameSlice(state.firstName),
      builder: (ctx, store, slice) {
        return Text(slice.name);
      },
    );
  }
}

/// A widget that only rebuilds if the name is longer that 3 characters
class FirstBigNameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliceWatcher<MyState, NameSlice>(
      slicer: (state) => NameSlice(state.firstName),
      shouldRebuild: (oldSlice, newSlice) {
        return oldSlice != newSlice && newSlice.name.length > 3;
      },
      builder: (ctx, store, slice) {
        return Text(slice.name);
      },
    );
  }
}

class LastNameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliceWatcher<MyState, NameSlice>(
      slicer: (state) => NameSlice(state.lastName),
      builder: (ctx, store, slice) {
        return Text(slice.name);
      },
    );
  }
}

void main() {
  group('SliceWatcher', () {
    testWidgets('gets updated when the slice has changed', (tester) async {
      final myState = MyState(
        firstName: 'James',
        lastName: 'Bond',
      );

      final store = SlicesStore(myState);

      await tester.pumpWidget(
        MaterialApp(
          home: SlicesProvider(
            store: store,
            child: Column(
              children: [
                FirstNameWidget(),
                LastNameWidget(),
              ],
            ),
          ),
        ),
      );

      expect(find.text('James'), findsOneWidget);
      expect(find.text('Bond'), findsOneWidget);

      store.dispatch(ChangeFirstNameAction('Vito'));

      await tester.pumpAndSettle();

      expect(find.text('Vito'), findsOneWidget);
      expect(find.text('Bond'), findsOneWidget);

      store.dispatch(ChangeLastNameAction('Corleone'));

      await tester.pumpAndSettle();

      expect(find.text('Vito'), findsOneWidget);
      expect(find.text('Corleone'), findsOneWidget);
    });

    testWidgets(
        'When shouldRebuild is provided, updates only when the condition is met',
        (tester) async {
      final myState = MyState(firstName: 'J', lastName: 'Bond');

      final store = SlicesStore(myState);

      await tester.pumpWidget(
        MaterialApp(
          home: SlicesProvider(
            store: store,
            child: Column(
              children: [
                FirstBigNameWidget(),
              ],
            ),
          ),
        ),
      );

      expect(find.text('J'), findsOneWidget);

      store.dispatch(ChangeFirstNameAction('Ja'));

      await tester.pumpAndSettle();

      // Nothing should be changed
      expect(find.text('J'), findsOneWidget);

      store.dispatch(ChangeFirstNameAction('James'));

      await tester.pumpAndSettle();
      // Name is longer than 3 characters now,
      // and should have been rendered
      expect(find.text('James'), findsOneWidget);
    });
  });

  group('SlicesProvider', () {
    test('updateShouldNotify returns true when the stores are different', () {
      final myState = MyState(
        firstName: 'James',
        lastName: 'Bond',
      );

      final store = SlicesStore(myState);
      final differentStore = SlicesStore(myState);

      final provider = SlicesProvider(store: store, child: Container());

      expect(
          provider.updateShouldNotify(
              SlicesProvider(store: store, child: Container())),
          isFalse);
      expect(
          provider.updateShouldNotify(
              SlicesProvider(store: differentStore, child: Container())),
          isTrue);
    });
  });
}

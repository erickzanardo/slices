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
  });
}

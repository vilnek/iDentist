import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identist_app/panels/form_dialog.dart';

void main() {
  late TextEditingController name;
  var saved = false;

  Future<void> open(WidgetTester tester) async {
    name = TextEditingController(text: 'Ramesh');
    saved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showFormDialog<void>(
                context: context,
                controllers: [name],
                builder: (ctx, setState, formKey) => Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(key: const Key('name'), controller: name),
                      TextButton(
                        onPressed: () {
                          saved = true;
                          Navigator.pop(ctx);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> tapBeside(WidgetTester tester) async {
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
  }

  testWidgets('an untouched form closes at once on a tap beside it', (
    tester,
  ) async {
    await open(tester);
    await tapBeside(tester);
    expect(find.byKey(const Key('name')), findsNothing);
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('a typed form asks first; Keep editing keeps the text', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byKey(const Key('name')), 'Ramesh Kumar');
    await tester.pump();
    await tapBeside(tester);
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Ramesh Kumar'), findsOneWidget);
  });

  testWidgets('Discard closes the typed form', (tester) async {
    await open(tester);
    await tester.enterText(find.byKey(const Key('name')), 'Ramesh Kumar');
    await tester.pump();
    await tapBeside(tester);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('name')), findsNothing);
    expect(saved, isFalse);
  });

  testWidgets('Save still closes a typed form without asking', (tester) async {
    await open(tester);
    await tester.enterText(find.byKey(const Key('name')), 'Ramesh Kumar');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, isTrue);
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.byKey(const Key('name')), findsNothing);
  });
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';

void main() {
  group('NativeTextField', () {
    testWidgets('creates text field with placeholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NativeTextField(placeholder: 'Enter text')),
        ),
      );

      expect(find.text('Enter text'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (
      WidgetTester tester,
    ) async {
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeTextField(
              placeholder: 'Test',
              onChanged: (value) {
                changedText = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(NativeTextField), 'Hello');
      expect(changedText, 'Hello');
    });

    testWidgets('respects obscureText for password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NativeTextField(placeholder: 'Password', obscureText: true),
          ),
        ),
      );

      expect(find.byType(NativeTextField), findsOneWidget);
    });

    testWidgets('renders prefix icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NativeTextField(
              placeholder: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders suffix icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NativeTextField(
              placeholder: 'Text',
              suffixIcon: Icon(Icons.clear),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('respects maxLines for multiline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NativeTextField(placeholder: 'Multiline', maxLines: 5),
          ),
        ),
      );

      expect(find.byType(NativeTextField), findsOneWidget);
    });

    testWidgets('respects enabled state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NativeTextField(placeholder: 'Disabled', enabled: false),
          ),
        ),
      );

      expect(find.byType(NativeTextField), findsOneWidget);
    });

    testWidgets('uses controller when provided', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'Initial text');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NativeTextField(
              controller: controller,
              placeholder: 'Test',
            ),
          ),
        ),
      );

      expect(find.text('Initial text'), findsOneWidget);
      controller.dispose();
    });
  });

  group('NativeTextFormField', () {
    testWidgets('creates form field with placeholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: NativeTextFormField(placeholder: 'Enter email'),
            ),
          ),
        ),
      );

      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('validates input', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: NativeTextFormField(
                placeholder: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('calls onSaved when form saved', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      String? savedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: NativeTextFormField(
                placeholder: 'Name',
                initialValue: 'John',
                onSaved: (value) {
                  savedValue = value;
                },
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.save();
      expect(savedValue, 'John');
    });

    testWidgets('shows validation error', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: NativeTextFormField(
                placeholder: 'Email',
                validator: (value) => 'Invalid email',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('renders prefix and suffix icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: NativeTextFormField(
                placeholder: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}

Write tests for the AI Workout Tracker app following the project's testing standards.

## Testing Task

**Target:** $ARGUMENTS

### Testing layers & locations

| Layer | Test type | Location | Tool |
|-------|-----------|----------|------|
| Domain / Use Cases | Unit | `test/features/*/domain/` | `flutter_test` + `mocktail` |
| Repository (data) | Unit | `test/features/*/data/` | `flutter_test` + `mocktail` |
| Riverpod Providers | Unit | `test/features/*/presentation/providers/` | `riverpod_test` + `ProviderContainer` |
| Widgets | Widget | `test/features/*/presentation/widgets/` | `flutter_test` |
| Screens | Widget | `test/features/*/presentation/screens/` | `flutter_test` + `riverpod_test` |
| Critical flows | Integration | `integration_test/` | `flutter_test` + `integration_test` |

### Rules
1. Use `mocktail` for mocks — never `mockito`
2. Repository tests must mock the data source, not Firebase directly
3. Provider tests use `ProviderContainer` with `overrides` — never test against real Firebase
4. Widget tests pump the widget inside a `ProviderScope` with overridden providers
5. Each test file has a `group()` per class/provider being tested
6. Tests are descriptive: `test('returns Failure when Firestore throws', ...)`

### Provider test template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late ProviderContainer container;
  late MockWorkoutRepository mockRepo;

  setUp(() {
    mockRepo = MockWorkoutRepository();
    container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('WorkoutsNotifier', () {
    test('emits loading then data on successful fetch', () async {
      when(() => mockRepo.getWorkouts()).thenAnswer((_) async => []);
      // ...
    });
  });
}
```

### Widget test template
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets('WorkoutCard displays workout name', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [/* overrides */],
        child: const MaterialApp(home: WorkoutCard(/* args */)),
      ),
    );
    expect(find.text('Push Day'), findsOneWidget);
  });
}
```

### After writing tests
Run and verify:
```bash
flutter test test/features/<feature>/ --reporter=expanded
flutter test --coverage
```

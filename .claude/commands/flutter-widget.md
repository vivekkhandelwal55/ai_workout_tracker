Create a Flutter widget for the AI Workout Tracker app following these strict rules:

## Widget Creation Checklist

**Arguments provided:** $ARGUMENTS

### Rules
1. Determine if this is a **screen** (full page, added to go_router) or a **reusable widget** (added to `shared/widgets/` or `features/*/presentation/widgets/`)
2. Use `ConsumerWidget` (or `ConsumerStatefulWidget` if local animation state is needed) — never plain `StatelessWidget` for anything that reads providers
3. Add `const` constructor if widget has no dynamic fields
4. Never put business logic, repository calls, or Firebase calls inside the widget — use Riverpod providers
5. Follow Material 3 design patterns (use `Theme.of(context).colorScheme`, not hardcoded colors)
6. All user-visible strings go through `AppStrings` constants or `l10n` — no hardcoded strings
7. Add a widget test in the corresponding `test/` directory

### Template (ConsumerWidget)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // watch providers here
    return const Placeholder();
  }
}
```

### After creating the widget:
- Run `flutter analyze` to check for issues
- Add an export to the barrel file if one exists
- If it's a screen, wire it up in `app/router/app_router.dart`

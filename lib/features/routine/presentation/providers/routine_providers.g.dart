// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routineRepositoryHash() => r'dbbf17b70f33f0f59f9cc9b041f78096762862ec';

/// See also [routineRepository].
@ProviderFor(routineRepository)
final routineRepositoryProvider =
    AutoDisposeProvider<RoutineRepository>.internal(
      routineRepository,
      name: r'routineRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$routineRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RoutineRepositoryRef = AutoDisposeProviderRef<RoutineRepository>;
String _$currentRoutineHash() => r'2b898d3647d20ea7aecaa62353c7e587430aae20';

/// See also [currentRoutine].
@ProviderFor(currentRoutine)
final currentRoutineProvider =
    AutoDisposeStreamProvider<WorkoutRoutine?>.internal(
      currentRoutine,
      name: r'currentRoutineProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$currentRoutineHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentRoutineRef = AutoDisposeStreamProviderRef<WorkoutRoutine?>;
String _$todayRoutineDayHash() => r'17aecac5ebc624a95f2b825984595cf8eee0cf15';

/// See also [todayRoutineDay].
@ProviderFor(todayRoutineDay)
final todayRoutineDayProvider = AutoDisposeProvider<TodayRoutineDay?>.internal(
  todayRoutineDay,
  name: r'todayRoutineDayProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayRoutineDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayRoutineDayRef = AutoDisposeProviderRef<TodayRoutineDay?>;
String _$routineNotifierHash() => r'd39ddf8d29030cdafbb81db57e0c0192e44231af';

/// See also [RoutineNotifier].
@ProviderFor(RoutineNotifier)
final routineNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RoutineNotifier, void>.internal(
      RoutineNotifier.new,
      name: r'routineNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$routineNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RoutineNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

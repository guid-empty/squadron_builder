## 2.4.1

- Added example/README.md to comply with pub.dev checks.

## 2.4.0

- Reorganized example folder and updated README.
- Revised code generation strategy for operations map: previously, the operations map was generated in a mixin class and the (user-developed) service class had to derive from `WorkerService` *and* mix in with the generated mixin class. This is no longer required and the generated code now implements a private service class (deriving from the user's service class) which implements `WorkerService` with the generated operations map. This removes several constraints on service implementation and enables support of "plain old Dart objects" as Squadron services. User-developped service classes must be public and concrete (non-abstract, non-final, non-sealed...) and must provide an unnamed constructor which will be called by the associated generated `WorkerService` class.
- Service method/constructor parameters whose type implement `marshal()`/`unmarshal()` or `marshall()`/`unmarshall()` methods will be automatically serialized using these methods if no explicit marshaler is provided. `marshal()`/`unmarshal()` have priority over `marshall()`/`unmarshall()`. These methods also have priority over automatic JSON serialization available since version 0.9.0. The marshaling method must be an instance method taking no arguments; the unmarshaling method must be static and accept one argument. `squadron_builder` will not verify parameter or return types of these methods, but obviously if the marshaling method of class `T` returns type `U`, the unmarshaling method must accept a `U` argument and return an instance of `T`. Failure to comply with this contract may lead to Dart compilation errors.

## 2.3.1

- Eliminate async code generation for additional assets.
- Properly resolve Squadron's main library.

## 2.3.0

- Properly handle platform worker thread parameter + getter in generated worker/worker pool when `with_finalizers` is enabled (fix for https://github.com/d-markey/squadron_builder/issues/5).
- Refactored service/method parameter management.
- Enable code generation for libraries that define several services. This will run as expected on native platforms where worker entrypoints are top-level static methods. It will not work on Web platforms where worker entrypoints are URLs: each worker needs its own URL, hence its own library.

## 2.2.0

- Automatically discover Squadron capabilities (`WorkerRequest`/`WorkerResponse` serialization type + availability of `EntryPoint` and `PlatformWorkerHook`).
- Retire option `serialization_type` as it is now discovered automatically.

## 2.1.2

- Downgrade version for `analyzer` (fix for https://github.com/d-markey/squadron_builder/issues/4).

## 2.1.1

- Downgrade version for `analyzer` (fix for https://github.com/d-markey/squadron_builder/issues/4).

## 2.1.0

- Enable support of Dart 3.
- Fix issues reported by `pub.dev` score.
- Add option `serialization_type` to configure the serialization type used for worker request/response (`Map` for Squadron < 5.0.0, `List` for Squadron >= 5.0.0).

## 2.0.0

- Breaking changes: several renamings, in particular the builder name which is now `squadron_builder:worker_builder`.
- Generate appropriate code for fields used as parameters in the constructor of the service class. In previous versions, the generated code for constructors did not map parameters with fields, and fields were overriden with getters/setters throwing an `UnimplementedError`. Please note that if the field is not final or if its value is mutable, updates will not be propagated to/from the platform worker. This is by design, because the service fields and the worker/pool fields are different instances living in different threads, and threads do not share memory in Dart and browsers.
- Support `UseLogger` annotation to generate associated code during worther thread initialization.
- Take builder options into account. In previous versions, builder options were ignored. Also upgraded `source_gen` to 1.3.0 (see pull request https://github.com/dart-lang/source_gen/pull/647 related to builders that produce multiple files).
- Added explicit option `with_finalizers` to force or disable code generation for finalization, and make finalization actually work.
- Split `build.yaml` in two to avoid interfering with the build process of client packages.
- Reorganized the source code to make it more readable and maintainable.

## 1.0.2

- Upgrade packages.
- Switch from deprecated `element2`/`enclosingElement3` to `element`/`enclosingElement`.

## 1.0.1

- Specify platform support in `pubspec.yaml`.

## 1.0.0

- Marshal data to/from workers according to `SerializeWith` annotations.

## 0.9.1

- Upgrade dependencies.

## 0.9.0

- Serialize arguments/return values when `toJson()`/`fromJson()` is available.

## 0.7.1

- Annotations `SquadronService` + `SquadronMethod`.
- Support of cancellation tokens.
- Package upgrade.
- Sample code.

## 0.0.1

- Initial version. Still experimental yet functional on simple use cases.

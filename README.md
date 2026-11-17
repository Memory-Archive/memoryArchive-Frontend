# Smart Memories & Connections Platform — Flutter client

Feature-first clean architecture, Cubit state management, and a REST client for the Express backend. The `auth` feature is implemented end to end and is the pattern every other feature copies.

## First-time setup

This repository contains the Dart code, tests and configuration. The platform folders (`android/`, `ios/`, `web/`) are generated on your machine:

```bash
# 1. Generate the platform folders (once). Keeps lib/, test/ and pubspec.yaml as they are.
flutter create . --project-name smart_memories --platforms=android,ios,web

# 2. Install packages
flutter pub get

# 3. Generate the freezed / json_serializable code (required before the first run)
dart run build_runner build --delete-conflicting-outputs

# 4. Run with mock data: no backend needed
flutter run --dart-define=USE_MOCK=true
```

Requires Flutter with Dart 3.8 or newer. After `flutter pub get`, run `flutter pub outdated` to see whether newer package versions are available.

## Code generation (build_runner)

Generated files (`*.freezed.dart`, `*.g.dart`) are not committed. Re-run the generator after pulling, and whenever you add or change a class annotated with `@freezed`.

| Command | When to use it |
|---|---|
| `dart run build_runner build --delete-conflicting-outputs` | One-off build |
| `dart run build_runner watch --delete-conflicting-outputs` | Rebuilds on every save while you work |
| `dart run build_runner clean` | If the generator gets stuck on stale output |

## Running

| Mode | Command |
|---|---|
| Mock data (no backend) | `flutter run --dart-define=USE_MOCK=true` |
| Real backend, Chrome | `flutter run -d chrome --web-port=5000` (uses `http://localhost:3000`) |
| Real backend, Android emulator | `flutter run` (uses `http://10.0.2.2:3000`) |
| Real backend, other address | `flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000` |

The backend routes live at the root (`/auth/login`, `/memories`), so the base URL has no `/api`. When running in Chrome, the backend's `CORS_ORIGIN` must be `http://localhost:5000` (the port you pass to `--web-port`).

In mock mode any email and password log in. Two addresses demonstrate error handling:

- log in with `wrong@example.com` to see a general error message;
- sign up with `taken@example.com` to see a server error under the email field.

Plain `http://` to a local backend is blocked by default on Android and iOS. For local development add `android:usesCleartextTraffic="true"` to the debug manifest (and an App Transport Security exception on iOS), or serve the API over HTTPS.

Checks:

```bash
flutter analyze
flutter test
```

## Folder conventions

```
lib/
  main.dart, app.dart
  core/
    constants/   env (dart-define), API endpoints, storage keys, default error text
    di/          get_it registrations: the composition root
    helpers/     extensions, date formatting, SessionHelper
    networking/  Dio factory, auth interceptor, ApiResult<T>, safeApiCall, ApiError
    storage/     LocalStorage interface + secure and prefs implementations
    validation/  Validators, ValidatedTextField, safe DTO parsing
    routing/     go_router config and route paths
    themes/      colours, text styles, spacing, radii, sizes, ThemeData
    widgets/     buttons, text field, card, chip, bottom nav, image, state views
  features/
    <feature>/
      presentation/  screens/, widgets/, cubit/ (Cubit + freezed state)
      domain/        entities/, repositories/ (abstract)
      data/          models/ (DTOs), data_sources/ (remote + mock), repositories/ (impl)
```

Naming: `snake_case` files; `XxxScreen`, `XxxCubit`, `XxxState`, `XxxDto`, `XxxRepository` (abstract, in domain), `XxxRepositoryImpl` (in data), `XxxRemoteDataSource` with `XxxRemoteDataSourceImpl` and `MockXxxRemoteDataSource`.

Feature status: `auth` is complete. `memories`, `places` (Home) and `profile` have working screens on mock data. `collections`, `journal`, `planning`, `social` and `ai` are empty folders.

## Dependency rules

1. **presentation → domain.** Screens and Cubits use entities and repository interfaces. They never import a DTO, a data source or Dio.
2. **data → domain.** The data layer implements the domain's repository interfaces and converts DTOs to entities.
3. **domain → nothing.** No Flutter, no Dio, no JSON. The one allowed import from `core` is the pure-Dart `ApiResult` / `ApiError` pair, because every repository method returns it.
4. **Features use the shared Dio** from `core`, obtained through get_it. No feature creates its own client.
5. **Feature to feature:** a feature may use another feature's **domain** layer (Home reads `MemoriesRepository`), never its data or presentation layer.
6. **`core/di` and `core/routing` are the composition root.** They are the only `core` files that import from `features/`.

How a request flows:

```
Screen → Cubit → Repository (interface) → RepositoryImpl → safeApiCall → RemoteDataSource → Dio
                                                    ↓
                               ApiResult<Entity>  (success | failure, never an exception)
```

- Data sources **throw** (`DioException`, `DtoParsingException`).
- Repositories **never throw**: every call is wrapped in `safeApiCall`, which returns `ApiResult<T>`.
- Cubits turn an `ApiResult` into a state: `initial`, `loading`, `success`, `failure`.

## Rules for screens

- **No hardcoded styles.** Colours come from `AppColors`, text from `AppTextStyles`, spacing from `AppSpacing` / `AppGap`, radii and sizes from `AppRadii` / `AppSizes`.
- **Use the shared widgets** in `core/widgets` before writing a new one. If something is used on two screens, move it there.
- **Screens do not decide who is logged in and do not navigate after login or logout.** The repository updates `SessionHelper`; the router's redirect reacts.
- **Navigate with `AppRoutes`** constants, never string literals.
- **Every list has loading, empty and error states** (`AppLoader`, `EmptyState`, `ErrorState`).

## How to add a new feature

Copy the shape of `features/auth`. Using `collections` as the example:

1. **Domain.** Add `domain/entities/collection.dart` (a `@freezed` class) and `domain/repositories/collections_repository.dart` (an `abstract interface class` whose methods return `Future<ApiResult<...>>`).
2. **Data.**
   - `data/models/collection_dto.dart`: a `@freezed` DTO with `fromJson` and a `toEntity()` method.
   - `data/data_sources/collections_remote_data_source.dart`: the interface and the Dio implementation. Parse every response with `parseDto` / `parseDtoList`.
   - `data/data_sources/mock_collections_remote_data_source.dart`: in-memory fake data.
   - `data/repositories/collections_repository_impl.dart`: wrap each call in `safeApiCall`.
3. **Presentation.** Add `presentation/cubit/collections_state.dart` (freezed union: initial, loading, success, failure), `collections_cubit.dart`, and the screens.
4. **Endpoints.** Add the paths to `core/constants/api_endpoints.dart`.
5. **DI.** In `core/di/injection.dart` add a `_registerCollections()` function that picks the mock or real data source with `Env.useMock`, registers the repository as a lazy singleton and the Cubit as a factory. Call it from `configureDependencies()`.
6. **Routing.** Add the path to `AppRoutes` and a `GoRoute` in `app_router.dart` that provides the Cubit. Replace the `ComingSoonScreen` placeholder if there is one.
7. **Generate and check.** Run build_runner, then `flutter analyze` and `flutter test`.

## Core building blocks

| Need | Use |
|---|---|
| Call the API safely | `safeApiCall(() => remote.something())` returns `ApiResult<T>` |
| Read a response body | `parseDto(json, XDto.fromJson, name: 'XDto')` |
| Show an error | `error.message` (always short and user-friendly) |
| Show a server error under a field | `ValidatedTextField(serverError: error?.messageFor('email'))` |
| Validate a field | `Validators.compose([Validators.required('Email'), Validators.email()])` |
| Store a token | `TokenStorage` (secure storage) |
| Store a setting | `getIt<LocalStorage>(instanceName: DiNames.prefsStorage)` |
| Change the backend error format | `core/networking/backend_error_format.dart` only |

Security notes: tokens are kept in secure storage only; request headers are never logged; `/auth/` requests are not logged at all; logging is disabled outside debug builds; a 401 triggers exactly one token refresh, and a failed refresh logs the user out.

## Backend contract (from memoryArchive-backend)

Checked against the backend source. "Not implemented yet" means the route exists but the server still answers 501, so the app cannot use it until the backend developer builds it.

1. **Base URL** has no prefix: `http://<host>:3000`.
2. **Success body** is `{ "message": string, "data": ... }`. The app unwraps `data` with `unwrapData` (`core/validation/safe_json.dart`).
3. **Error body** is `{ "message": string, "details"?: ... }`. For validation errors (400) `details` is `[{ "location": "body", "path": "email", "message": string }]`. A taken email or username is a 409 with only a message; the app attaches it to the matching field. All parsing is in `core/networking/backend_error_format.dart`.
4. `POST /auth/signup` takes `{ username, email, password, displayName? }` and returns 201 `data: { user }` with **no tokens**. The app therefore signs up and then logs in. Username: 3 to 30 characters, letters, numbers, `_` and `.`. Password: 8 to 128 characters on the server (the app requires 10).
5. `POST /auth/login` takes `{ email, password, deviceName? }` and is meant to return `data: { accessToken, refreshToken }`. **Not implemented yet.**
6. `POST /auth/refresh` and `POST /auth/logout` take `{ refreshToken }`. **Not implemented yet.** Refresh tokens are opaque and rotate on every refresh.
7. `GET /users/me`, `GET /users/me/sessions` and `DELETE /users/me/sessions/:sessionId`. **Not implemented yet.** `/users/me` is assumed to return the user (directly or as `{ user }`).
8. Protected routes need `Authorization: Bearer <accessToken>`. The authentication middleware is **not implemented yet**, so every protected route answers 501 after the header check.
9. `GET /memories` takes `page`, `limit`, `from`, `to`, `placeId`, `tagId`, `q` and `sort=newest|oldest`. **Not implemented yet**, and the list shape (plain array or paginated object) is unknown. `GET /memories/on-this-day` does not exist. The app's memory models (`placeName`, `coverUrl`, `photoUrls` ...) have not been matched to the backend yet.
10. Ids are UUID strings; dates are `YYYY-MM-DD`; timestamps are ISO-8601.
11. **Not in the backend yet:** the app's profile "device sessions" screen expects `deviceName`, `location`, `lastActiveAt` and `isCurrent`; confirm these names when sessions are built.

## Missing from the design

Listed here instead of guessed. Each one is either a placeholder in the app or shows a "not available yet" message.

1. **Fonts.** The design uses Fraunces and DM Sans. The font files are not in the repository, so the app uses the platform font until they are added (instructions in `pubspec.yaml`).
2. **Splash screen.** Not designed; the app shows the app name and a spinner.
3. **App name.** The design says "Memories Archive"; the project is now called "Smart Memories & Connections Platform". The app shows the design's name (`AppStrings.appName`).
4. **Editing a memory.** The Edit button links to the editor, but the design shows only "New memory". Edit currently opens an empty editor.
5. **Place picker.** The editor has the Place row, but no picker screen is designed and no map provider is chosen.
6. **Photo picking and upload.** No picker package is in the agreed stack. In mock mode the editor shows the design's three sample tiles (including the 60% upload) so the layout can be reviewed.
7. **Collection picker** for "Add to a collection".
8. **Tags, tagged people and music link** have no input in the editor design.
9. **Forgot password**, **Edit profile**, **Change password** and **Delete account** have no screens.
10. **Delete memory confirmation.** Not designed; the app asks with a standard dialog before deleting.
11. **Photo gallery.** The "1 of 6" badge and "+2 more" tile imply a gallery that is not designed.
12. **Map, Collections, Timeline and Search** are designed but outside this task. Their routes show a placeholder screen so every link works.
13. **Loading, empty and error states** are not drawn for any screen; the app uses the shared state widgets.
14. **Home lives in the `places` feature** as requested, although it shows memories. Consider moving it to `journal` later.
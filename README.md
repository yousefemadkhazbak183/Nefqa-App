# Nafqa (نفقة) 💸

A lightweight expense-tracking app built with Flutter, showcasing a full MVVM architecture (as defined by the official [Flutter Docs](https://docs.flutter.dev/app-architecture)), a real caching strategy, and a complete CI/CD pipeline — built as a portfolio project to demonstrate production-level engineering practices in a small, focused codebase.

---

## 📱 Features

- **Authentication** — Sign up, log in, log out, and password reset (Supabase Auth)
- **Expenses CRUD** — Add, view, edit, and delete expenses with category, amount, date, and optional notes
- **Offline-aware caching** — Expenses are cached locally and remain available without a network connection
- **Statistics** — Total spending and a category breakdown (pie chart) that updates automatically whenever expenses change
- **Bottom navigation** — Persistent state across the Expenses and Statistics tabs
- **Light / Dark theme** — Manual toggle, fully dynamic across the whole app

---

## 🏗️ Architecture

The app follows **MVVM** exactly as described in the official Flutter Architecture guide:

- Every screen (**View**) has exactly one dedicated **ViewModel** — a strict one-to-one relationship.
- ViewModels extend `ChangeNotifier` and expose state through **Commands**, not raw async methods.
- Views never talk to repositories or data sources directly — only to their ViewModel.

### Command Pattern

Every async operation (login, save expense, delete, etc.) is wrapped in a `Command` object instead of scattering `isLoading` / `error` booleans across each ViewModel. Each `Command` tracks its own `running`, `completed`, `error`, and `result` state, and prevents duplicate execution while already running.

- `SimpleCommand<T>` — for operations with no arguments (e.g. `logout()`)
- `ParameterizedCommand<T, A>` — for operations with one argument, using Dart **records** to bundle multiple values (e.g. `({String email, String password})`)

### Result Pattern

Instead of relying on scattered `try/catch` blocks, every repository method returns a `Result<T>` — either `Success<T>` or `Failure` — making error handling explicit and enforced by the compiler at the ViewModel layer.

### Repository Pattern (Expenses)

The Expenses feature implements a full two-layer data strategy:

```
ExpenseRepository
    ├── ExpenseRemoteDataSource   → talks to a REST API (json-server)
    └── ExpenseLocalDataSource    → local cache (sqflite)
```

**Strategy: Network-first with Local Fallback**
1. Try fetching from the remote API first.
2. On success, refresh the local cache and return the fresh data.
3. On failure (e.g. no internet), fall back to the local cache instead of failing outright.

### Cross-feature reactivity

Expenses and Statistics are decoupled features that still need to stay in sync. A lightweight singleton `ExpensesDataNotifier` (a plain `ChangeNotifier`) bridges them: any successful add/edit/delete in Expenses notifies listeners, and `StatisticsViewModel` automatically reloads — no manual refresh needed.

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| Language / Framework | Flutter (Dart) |
| Architecture | MVVM (official Flutter Docs pattern) |
| State management | `ChangeNotifier` + `Provider` |
| Dependency Injection | `get_it` |
| Navigation | `go_router` (incl. `StatefulShellRoute` for bottom nav) |
| Authentication | Supabase Auth |
| Expenses API (fake backend) | `json-server` |
| Local persistence / cache | `sqflite` |
| Charts | `fl_chart` |
| Environment secrets | `flutter_dotenv` (`.env`, git-ignored) |
| Testing | `flutter_test` + `mocktail` |
| CI/CD | GitHub Actions |

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── di/                # get_it service locator + router
│   ├── enums/              # ExpenseCategory
│   ├── network/            # Result, Command, ApiConstants, ExpensesDataNotifier
│   ├── theme/               # AppColors, AppTheme, ThemeNotifier
│   └── widgets/              # Shared widgets (e.g. bottom nav scaffold)
│
├── data/
│   ├── models/               # AppUser, Expense, ExpenseStatistics
│   └── repositories/          # AuthRepository, ExpenseRepository (+ data sources)
│
└── features/
    ├── auth/
    │   ├── views/             # LoginScreen, SignupScreen, ForgotPasswordScreen
    │   ├── widgets/            # *_screen_body.dart per screen
    │   └── view_models/        # One ViewModel per screen
    ├── expenses/
    │   ├── views/
    │   ├── widgets/
    │   └── view_models/
    ├── statistics/
    │   ├── views/
    │   ├── widgets/
    │   └── view_models/
    └── splash/
        └── views/              # Session check on app start
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `3.38.10` (stable channel)
- A [Supabase](https://supabase.com) project (for Auth)
- [json-server](https://github.com/typicode/json-server) (fake REST API for Expenses)

### 1. Clone and install dependencies
```bash
git clone https://github.com/yousefemadkhazbak183/Nefqa-App.git
cd Nefqa-App
flutter pub get
```

### 2. Set up environment variables
Create a `.env` file in the project root (this file is git-ignored):
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-publishable-key
```

### 3. Run the fake Expenses API
```bash
npx json-server@0.17.4 --watch db.json --port 3000
```
> On Android emulators, replace `localhost` with `10.0.2.2` in `lib/core/network/api_constants.dart`.

### 4. Run the app
```bash
flutter run
```

---

## ✅ Testing

The project has full unit test coverage across every ViewModel in Auth, Expenses, and Statistics — covering both success and failure paths, plus feature-specific behaviors (e.g. auto-refresh on data change, correct add/update dispatch).

```bash
flutter test
```

Mocking is done with `mocktail` (no code generation required), keeping every mock explicit and readable.

---

## 🔄 CI/CD

Every push and pull request against `main` triggers a GitHub Actions pipeline (`.github/workflows/ci.yml`):

1. **Checkout** the repository
2. **Set up Flutter** (pinned version)
3. **Install dependencies**
4. **Check formatting** (`dart format --set-exit-if-changed`)
5. **Analyze code** (`flutter analyze`)
6. **Run tests** (`flutter test`)

On top of that, pushes to `main` specifically trigger a second job that **builds a release APK** and uploads it as a downloadable GitHub Actions artifact — so a working, up-to-date build is always one click away.

---

## 📸 Screenshots
<img width="1179" height="2556" alt="Simulator Screenshot - joe - 2026-08-15 at 16 33 34" src="https://github.com/user-attachments/assets/1fa7b453-3fb1-4536-8699-b98b548de719" />

<img width="1179" height="2556" alt="Simulator Screenshot - joe - 2026-08-15 at 16 33 37" src="https://github.com/user-attachments/assets/8cb2aead-55d6-4f4a-9378-94b82c0469df" />

<img width="1179" height="2556" alt="Simulator Screenshot - joe - 2026-08-15 at 16 33 42" src="https://github.com/user-attachments/assets/0e19e3a6-a614-4f92-a1e1-7cae91b21806" />

<img width="1179" height="2556" alt="Simulator Screenshot - joe - 2026-08-15 at 16 33 48" src="https://github.com/user-attachments/assets/fc6def89-12b4-4c65-a3da-a3ac96848709" />

<img width="1179" height="2556" alt="Simulator Screenshot - joe - 2026-08-15 at 16 33 51" src="https://github.com/user-attachments/assets/b04c97a8-f924-434e-8d35-65e32063f215" />

<img width="1179" height="2556" alt="Simulator Screenshot - joe - 2026-08-15 at 16 33 59" src="https://github.com/user-attachments/assets/09893c32-46c5-49d9-b1da-9e87e819dccf" />







---

## 🌱 Git Workflow

- Each feature is developed on its own branch (`feature/*`) and merged via Pull Request.
- Commits follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `test:`, `chore:`, `style:`, `ci:`).
- No branch is merged without a passing CI run.

---

## 👤 Author

**Yousef Emad**
[LinkedIn](https://linkedin.com/in/yussufemad) · [GitHub](https://github.com/yousefemadkhazbak183)

# 04 · State management (Riverpod)

We use **flutter_riverpod**. It gives us two things at once: dependency injection (swap a
repository in one line) and reactive state (screens rebuild when data changes).

## The provider types we use

| Provider | Used for | Example |
|----------|----------|---------|
| `Provider` | a dependency / service | `valuationServiceProvider`, `*RepositoryProvider` |
| `FutureProvider` | async read (loading/error/data) | `tendersProvider`, `lotsProvider` |
| `FutureProvider.family` | async read with an argument | `lotProvider(lotId)` |
| `StateProvider` | a simple mutable value | `marginPctProvider`, `willBidFilterProvider` |
| `StateNotifierProvider` | richer mutable state | `authControllerProvider`, `themeControllerProvider` |

## The pattern in a screen

```dart
class LotListPage extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final lotsAsync = ref.watch(lotsProvider(tenderId));   // subscribe
    return lotsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error:   (e, _) => EmptyState(...),
      data:    (lots) => ListView(...),                     // rebuilds on change
    );
  }
}
```

- `ref.watch(...)` **subscribes** — the widget rebuilds when the value changes.
- `ref.read(...)` is a **one-shot** — use it in callbacks (button taps), never in `build`.
- `AsyncValue.when(...)` forces you to handle loading + error, not just the happy path.

## The DI seam (why this matters for going live)

Each feature exposes its repository through a `Provider`:

```dart
final tenderRepositoryProvider = Provider<TenderRepository>((ref) {
  return const MockTenderRepository();     // ← the ONLY line that changes for live
});
```

Every screen depends on the **interface** via this provider, so replacing the mock with an
HTTP repository is a one-line change. See [05-DATA-LAYER.md](05-DATA-LAYER.md).

## Local vs shared state

- **Ephemeral UI state** (a text controller, an expanded/collapsed flag) stays in a
  `StatefulWidget`/`ConsumerStatefulWidget` — don't put it in a provider.
- **Anything shared across screens** (theme, margin, auth, fetched data) goes in a provider.

## The root

`main.dart` wraps the app in a single `ProviderScope` — the container that holds all
providers for the app's lifetime.

# Cache

A lightweight Swift package providing an asynchronous cache abstraction and an in-memory cache implementation.

## Features

- `Cache` protocol with async operations
- `MemoryCache` actor implementation for thread-safe in-memory caching
- Optional expiration support for cached entries
- Atomic first-writer-wins and get-or-insert operations

## Requirements

- Swift 6.3
- iOS 15 or later
- macOS 13 or later

## Installation

Add the package to your project via Swift Package Manager using the repository URL.

```swift
.package(url: "https://github.com/your-org/Cache.git", from: "1.0.0"),
```

Then add the `Cache` product to your target dependencies.

## Usage

### Using `MemoryCache`

```swift
import Cache

let cache = MemoryCache<String, String>()

Task {
    await cache.insert("hello", for: "greeting", expiration: .seconds(60))
    let value = await cache.value(for: "greeting")
    print(value) // Optional("hello")
}
```

  ### Concurrent writes

  `insert` replaces an existing value. When multiple tasks write the same key concurrently, the value processed last by the actor wins. Use `insertIfAbsent` when the first accepted value should win:

  ```swift
  let inserted = await cache.insertIfAbsent("hello", for: "greeting")
  ```

  Use `getOrInsert` for an atomic read-or-write operation:

  ```swift
  let value = await cache.getOrInsert("hello", for: "greeting")
  ```

### Removing entries

```swift
Task {
    await cache.removeValue(for: "greeting")
    await cache.removeAll()
}
```

### Purging expired entries

```swift
Task {
    let removedCount = await cache.purgeExpiredEntries()
    print("Purged \(removedCount) expired entries")
}
```

## API

- `Cache`
  - `func value(for key: Key) async -> Value?`
  - `func insert(_ value: Value, for key: Key) async`
  - `func insertIfAbsent(_ value: Value, for key: Key) async -> Bool`
  - `func getOrInsert(_ value: Value, for key: Key) async -> Value`
  - `func removeValue(for key: Key) async`
  - `func removeAll() async`

- `MemoryCache`
  - `init()`
  - `func value(for key: Key) async -> Value?`
  - `func insert(_ value: Value, for key: Key, expiration: Duration? = nil) async`
  - `func removeValue(for key: Key) async`
  - `func removeAll() async`
  - `func purgeExpiredEntries(currentDate: ContinuousClock.Instant = .now) async -> Int`

## Testing

Run tests with Swift Package Manager:

```bash
swift test
```

## License

This project is provided under the MIT License. Update this section to match your preferred license.

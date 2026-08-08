# Cache

A lightweight Swift package providing an asynchronous cache abstraction and an in-memory cache implementation.

## Features

- `Cache` protocol with async operations
- `MemoryCache` actor implementation for thread-safe in-memory caching
- Optional expiration support for cached entries

## Requirements

- Swift 6.3
- iOS 16 or later
- macOS 13 or later

## Installation

Add the package to your project via Swift Package Manager using the repository URL.

```swift
.package(url: "https://github.com/kocoai/Cache.git", from: "1.0.0"),
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

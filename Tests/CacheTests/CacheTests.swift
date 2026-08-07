@testable import Cache
import Foundation
import Testing

@Suite("Insertion")
struct InsertionTests {
    @Test
    func insertShouldStoreValue() async {
        let cache = MemoryCache<String, Int>()

        await cache.insert(42, for: "answer")

        let value = await cache.value(for: "answer")

        #expect(value == 42)
    }

    @Test
    func insertingExistingKeyReplacesValue() async {
        let cache = MemoryCache<String, Int>()

        await cache.insert(1, for: "A")
        await cache.insert(2, for: "A")

        let value = await cache.value(for: "A")

        #expect(value == 2)
    }
}

@Suite("Reading")
struct ReadingTests {
    @Test
    func readingUnknownKeyReturnsNil() async {
        let cache = MemoryCache<String, Int>()

        let value = await cache.value(for: "unknown")

        #expect(value == nil)
    }
}

@Suite("Removing")
struct RemovingTests {
    @Test
    func removeAllDeletesEverything() async {
        let cache = MemoryCache<String, Int>()

        await cache.insert(1, for: "A")
        await cache.insert(2, for: "B")

        await cache.removeAll()

        #expect(await cache.value(for: "A") == nil)
        #expect(await cache.value(for: "B") == nil)
    }

    @Test
    func expiredEntryReturnsNil() async {
        let cache = MemoryCache<String, Int>()
        await cache.insert(
            42,
            for: "answer",
            expiration: .seconds(-60)
        )

        let value = await cache.value(for: "answer")

        #expect(value == nil)
    }

    @Test
    func removeDeletesValue() async {
        let cache = MemoryCache<String, Int>()

        await cache.insert(42, for: "A")

        await cache.removeValue(for: "A")

        #expect(await cache.value(for: "A") == nil)
    }

    @Test
    func cleanRemovesExpiredEntries() async {
        let cache = MemoryCache<String, Int>()

        await cache.insert(
            1,
            for: "expired",
            expiration: .seconds(-10)
        )

        await cache.insert(
            2,
            for: "valid",
            expiration: .seconds(60)
        )

        await cache.purgeExpiredEntries()

        #expect(await cache.value(for: "expired") == nil)
        #expect(await cache.value(for: "valid") == 2)
    }
}

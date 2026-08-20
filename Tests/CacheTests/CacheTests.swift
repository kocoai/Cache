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

    @Test
    func insertIfAbsentDoesNotReplaceExistingValue() async {
        let cache = MemoryCache<String, Int>()

        #expect(await cache.insertIfAbsent(1, for: "A"))
        #expect(await cache.insertIfAbsent(2, for: "A") == false)
        #expect(await cache.value(for: "A") == 1)
    }

    @Test
    func getOrInsertReturnsExistingValue() async {
        let cache = MemoryCache<String, Int>()

        await cache.insert(1, for: "A")

        let value = await cache.getOrInsert(2, for: "A")

        #expect(value == 1)
        #expect(await cache.value(for: "A") == 1)
    }

    @Test
    func getOrInsertStoresValueWhenKeyIsMissing() async {
        let cache = MemoryCache<String, Int>()

        let value = await cache.getOrInsert(2, for: "A")

        #expect(value == 2)
        #expect(await cache.value(for: "A") == 2)
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

@Suite("Concurrency")
struct ConcurrencyTests {
    @Test
    func concurrentInsertionsStoreAllValues() async {
        let cache = MemoryCache<Int, Int>()

        await withTaskGroup(of: Void.self) { group in
            for value in 0..<100 {
                group.addTask {
                    await cache.insert(value, for: value)
                }
            }
        }

        for value in 0..<100 {
            #expect(await cache.value(for: value) == value)
        }
    }

    @Test
    func concurrentInsertionsForSameKeyKeepOneSubmittedValue() async {
        let cache = MemoryCache<String, Int>()

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await cache.insert(1, for: "shared")
            }
            group.addTask {
                await cache.insert(2, for: "shared")
            }
        }

        let value = await cache.value(for: "shared")

        #expect(value == 1 || value == 2)
    }

    @Test
    func concurrentInsertIfAbsentAcceptsOnlyOneValue() async {
        let cache = MemoryCache<String, Int>()

        let acceptedValues = await withTaskGroup(of: Int?.self, returning: [Int].self) { group in
            for value in 1...100 {
                group.addTask {
                    guard await cache.insertIfAbsent(value, for: "shared") else {
                        return nil
                    }

                    return value
                }
            }

            var acceptedValues: [Int] = []
            for await value in group {
                if let value {
                    acceptedValues.append(value)
                }
            }
            return acceptedValues
        }

        #expect(acceptedValues.count == 1)
        #expect(await cache.value(for: "shared") == acceptedValues[0])
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

//
//  MemoryCache.swift
//  Cache
//
//  Created by Kien NGUYEN on 17/07/2026.
//
import Foundation

public actor MemoryCache<Key: Hashable & Sendable, Value: Sendable> {
    private var storage: [Key: CacheEntry<Value>] = [:]

    public func value(for key: Key) async -> Value? {
        if let expiration = storage[key]?.expiration,
           expiration < ContinuousClock.now
        {
            storage.removeValue(forKey: key)
            return nil
        }
        return storage[key]?.value
    }

    public func insert(_ value: Value, for key: Key, expiration: Duration? = nil) async {
        if let expiration {
            storage[key] = CacheEntry(
                value: value,
                expiration: ContinuousClock.now + expiration
            )
        } else {
            storage[key] = CacheEntry(value: value)
        }
    }

    public func removeValue(for key: Key) async {
        storage.removeValue(forKey: key)
    }

    public func removeAll() async {
        storage.removeAll()
    }

    private func timeInterval(for duration: Duration) -> TimeInterval {
        let components = duration.components
        return TimeInterval(components.seconds) + TimeInterval(components.attoseconds) / 1_000_000_000_000_000_000
    }

    /// Purge expired cache
    /// - Returns: number of purged entries
    @discardableResult
    public func purgeExpiredEntries(currentDate: ContinuousClock.Instant = .now) async -> Int {
        let expiredKeys: [Key] = storage.compactMap { key, entry in
            guard let expiration = entry.expiration,
                  expiration < currentDate
            else {
                return nil
            }

            return key
        }

        for expiredKey in expiredKeys {
            storage.removeValue(forKey: expiredKey)
        }

        return expiredKeys.count
    }
}

//
//  CacheEntry.swift
//  Cache
//
//  Created by Kien NGUYEN on 17/07/2026.
//
import Foundation

public struct CacheEntry<Value> {
    let value: Value
    let expiration: ContinuousClock.Instant?

    init(value: Value, expiration: ContinuousClock.Instant? = nil) {
        self.value = value
        self.expiration = expiration
    }
}

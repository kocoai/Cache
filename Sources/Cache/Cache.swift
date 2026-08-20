// The Swift Programming Language
// https://docs.swift.org/swift-book

public protocol Cache<Key, Value>: Sendable {
    associatedtype Key: Hashable & Sendable
    associatedtype Value: Sendable

    func value(for key: Key) async -> Value?

    func insert(_ value: Value, for key: Key) async

    func removeValue(for key: Key) async

    func removeAll() async
}

//
//  AtomicInt.swift
//  Platform
//
//  Created by Krunoslav Zaher on 10/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//
import Dispatch

final class AtomicInt {
    private var mutex: pthread_mutex_t
    private var value: Int32

    init(_ initialValue: Int32) {
        self.value = initialValue

        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr); defer { pthread_mutexattr_destroy(&attr) }

        self.mutex = pthread_mutex_t()
        guard pthread_mutex_init(&self.mutex, &attr) == 0 else { fatalError() }
    }

    @discardableResult
    func increment() -> Int32 {
        guard pthread_mutex_lock(&self.mutex) == 0 else { fatalError() }
        let oldValue = self.value
        self.value += 1
        guard pthread_mutex_unlock(&self.mutex) == 0 else { fatalError() }
        return oldValue
    }

    @discardableResult
    func decrement() -> Int32 {
        guard pthread_mutex_lock(&self.mutex) == 0 else { fatalError() }
        let oldValue = self.value
        self.value -= 1
        guard pthread_mutex_unlock(&self.mutex) == 0 else { fatalError() }
        return oldValue
    }

    func isFlagSet(_ mask: Int32) -> Bool {
        guard pthread_mutex_lock(&self.mutex) == 0 else { fatalError() }
        let oldValue = self.value
        guard pthread_mutex_unlock(&self.mutex) == 0 else { fatalError() }
        return oldValue & mask != 0
    }

    @discardableResult
    func fetchOr(_ mask: Int32) -> Int32 {
        guard pthread_mutex_lock(&self.mutex) == 0 else { fatalError() }
        let oldValue = self.value
        self.value |= mask
        guard pthread_mutex_unlock(&self.mutex) == 0 else { fatalError() }
        return oldValue
    }

    func load() -> Int32 {
        guard pthread_mutex_lock(&self.mutex) == 0 else { fatalError() }
        let oldValue = self.value
        guard pthread_mutex_unlock(&self.mutex) == 0 else { fatalError() }
        return oldValue
    }
}


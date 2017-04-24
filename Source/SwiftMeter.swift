//
//  SwiftMeter.swift
//  SwiftMeter
//
//  Created by Yurii on 29/03/2017.
//  Copyright © 2017 Yurii Kobets. All rights reserved.
//

import Foundation
import QuartzCore

fileprivate var timebase_info: mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
fileprivate var numer: UInt64?
fileprivate var denom: UInt64?

struct StopWatch {

    typealias TimeEvent = (String, TimeValue)
    typealias TimeEventDouble = (String, Double)

    fileprivate var startTimestamp: UInt64 = 0
    fileprivate var stopTimestamp: UInt64 = 0

    fileprivate var tag: String?
    fileprivate var splits = [TimeEvent]()

    init() {
        mach_timebase_info(&timebase_info)
        numer = UInt64(timebase_info.numer)
        denom = UInt64(timebase_info.denom)
    }

    init(tag: String?) {
        self.init()
        self.tag = tag
    }

    init(_ tag: String?) {
        self.init(tag: tag)
    }

    /// Start a stopwatch instance
    mutating func start() {
        startTimestamp = mach_absolute_time()
    }

    /// Stops countdown
    mutating func stop() {
        if (stopTimestamp == 0) {
            stopTimestamp = mach_absolute_time()
        }
    }

    mutating func split(_ eventTag: String? = nil) -> TimeValue {
        let splitTime = elapsedTime(start: startTimestamp, end: currentTimeNanoseconds())
        let tag = eventTag ?? "Split \(splits.count))"
        self.splits.append((tag, splitTime))
        return splitTime
    }

    func stepTime(_ eventTag: String) -> TimeValue {
        return self.splits.first { event -> Bool in
            return event.0 == eventTag
        }.map { event in
            return event.1
        } ?? TimeValue.timeValueZero
    }
    
    /// Time elapsed since start of the stopwatch
    var elapsedTime: TimeValue {
        return elapsedTime(start: startTimestamp, end: stopTimestamp)
    }

    private func elapsedTime(start: UInt64, end: UInt64) -> TimeValue {
        guard start > 0 && end > 0 && start < end else {
            return TimeValue.timeValueZero
        }

        let elapsed = ((end - start) * numer!) / denom!
        return TimeValue(value: elapsed, type: .nanosecond)
    }

    func activeSplits(unit: TimeUnit = .nanosecond) -> [TimeEventDouble] {
        return splits.map { ($0, $1.valueFor(unit: unit)) }
    }

    func formattedTime(unit: TimeUnit) -> String {
        let elapsedTime = self.elapsedTime
        let formattedTime = elapsedTime.valueFor(unit: unit)
        let tag = self.tag ?? "\(startTimestamp)"
        return "[Stopwatch - \(tag)] time elapsed - \(formattedTime) \(unit.unitName())"
    }

    private func currentTimeValue() -> TimeValue {
        return TimeValue(mach_absolute_time())
    }

    private func currentTimeNanoseconds() -> UInt64 {
        return mach_absolute_time()
    }
}

/// Time representation in seconds, milliseconds, nanoseconds
enum TimeUnit {
    case nanosecond, microsecond, millisecond, second

    func unitName() -> String {
        switch self {
            case .nanosecond: return "nanoseconds"
            case .microsecond: return "microseconds"
            case .millisecond: return "milliseconds"
            case .second: return "seconds"
        }
    }
}

/// Time value with type (representation). The milliseconds is default
struct TimeValue {

    static let timeValueZero = TimeValue(0)

    /// value in nanoseconds
    private var value: UInt64 = 0

    var type = TimeUnit.nanosecond

    /// respresents value in nanoseconds
    var nanoseconds: UInt64 {
        return value
    }

    init(value: UInt64, type: TimeUnit) {
        self.value = value
        self.type = type
    }

    init(_ value: UInt64) {
        self.value = value
        self.type = .nanosecond
    }
    
    func valueFor(unit: TimeUnit) -> Double {
        switch unit {
            case .nanosecond:
                return Double(value)
            case .microsecond:
                return Double(value) / 1_000
            case .millisecond:
                return Double(value) / 1_000_000
            case .second:
                return Double(value) / 1_000_000_000
        }
    }
    
}

extension TimeValue: Equatable {
    static func == (lhs: TimeValue, rhs: TimeValue) -> Bool {
        return lhs.nanoseconds == rhs.nanoseconds
    }
}

extension TimeValue: Comparable {
    public static func <(lhs: TimeValue, rhs: TimeValue) -> Bool {
        return lhs.nanoseconds < rhs.nanoseconds
    }

    public static func <=(lhs: TimeValue, rhs: TimeValue) -> Bool {
        return lhs.nanoseconds <= rhs.nanoseconds
    }

    public static func >=(lhs: TimeValue, rhs: TimeValue) -> Bool {
        return lhs.nanoseconds >= rhs.nanoseconds
    }

    public static func >(lhs: TimeValue, rhs: TimeValue) -> Bool{
        return lhs.nanoseconds > rhs.nanoseconds
    }
}

/// Log functions controlled by SwiftMeter
class SwiftMeter {
    func startTimer() -> StopWatch {
        return StopWatch()
    }
}

/// Benchmark protocol which is core for this class
protocol SwiftMeterable {
    func executionTimeInterval(_ block: () -> ()) -> CFTimeInterval
}

extension SwiftMeterable {
    func executionTimeInterval(_ block: () -> ()) -> CFTimeInterval {
        var stopwatch = StopWatch()
        stopwatch.start()
        block();
        stopwatch.stop()
        return stopwatch.elapsedTime.valueFor(unit: .second)
    }
}

struct MeterPrint {
    static var enabledLogging = true
    public static func print(_ value: String) {
        if enabledLogging {
            print(value)
        }
    }
}

extension NSObject {
    public static func printMeter(_ value: String) {
        MeterPrint.print(value)
    }
}

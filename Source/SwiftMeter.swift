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

    typealias TimeEventDouble = (String, Double)
    fileprivate typealias TimeEvent = (String, TimeValue)
    fileprivate typealias TimeEventPause = (TimeValue, Bool) //$1 - when event has paused, $2 - isPaused
    
    fileprivate typealias WarnEvent = (String, TimeValue)

    fileprivate var startTimestamp: UInt64 = 0
    fileprivate var stopTimestamp: UInt64 = 0

    fileprivate var tag: String?
    fileprivate var splits = [TimeEvent]()

    fileprivate var pauses = [TimeEventPause]()

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

    var isRunning: Bool {
        return startTimestamp > 0 && stopTimestamp == 0
    }

    /// Start a stopwatch instance
    mutating func start() {
        startTimestamp = mach_absolute_time()
    }

    /// Stops countdown
    mutating func stop() {
        if isRunning {
            stopTimestamp = mach_absolute_time()
        }
    }

    /// Pause countdown
    mutating func pause() {
        if isRunning {
            pauses.append((TimeValue.now(), true))
        }
    }

    /// Resume countdown
    mutating func resume() {
        if isRunning {
            pauses.append((TimeValue.now(), false))
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
        var pausedTime: UInt64 = 0
        var pauseStarted = TimeValue.timeValueZero

        for (_, value) in pauses.enumerated() {
            if (value.1 == true) {
                pauseStarted = value.0
            }

            if pauseStarted != TimeValue.timeValueZero && value.1 == false {
                let pauseEnded = value.0
                pausedTime += elapsedTime(start: pauseStarted.value, end: pauseEnded.value).value
            }
        }

        return TimeValue(elapsedTime(start: startTimestamp, end: stopTimestamp).value - pausedTime)
    }

    private func elapsedTime(start: UInt64, end: UInt64) -> TimeValue {
        guard start > 0 && end > 0 && start < end else {
            return TimeValue.timeValueZero
        }

        let elapsed = ((end - start) * numer!) / denom!
        return TimeValue(value: elapsed, type: .nanosecond)
    }

    func activeSplits(unit: TimeUnit = .nanosecond) -> [TimeEventDouble] {
        return splits.map { ($0, $1.timeinterval(unit: unit)) }
    }

    func formattedTime(unit: TimeUnit) -> String {
        let elapsedTime = self.elapsedTime
        let formattedTime = elapsedTime.timeinterval(unit: unit)
        let tag = self.tag ?? "\(startTimestamp)"
        return "[Stopwatch - \(tag)] time elapsed - \(formattedTime) \(unit.unitName())"
    }

    private func currentTimeNanoseconds() -> UInt64 {
        return mach_absolute_time()
    }
    
    func warnWithTimeLapsed(value: TimeValue) {
        
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

    private let microsecondsInSecond: UInt64 = 1_000
    private let millisecondsInSecond: UInt64 = 1_000_000
    private let nanosecondsInSecond: UInt64 = 1_000_000_000

    static let timeValueZero = TimeValue(0)

    /// value in nanoseconds
    fileprivate var value: UInt64 = 0

    var type = TimeUnit.nanosecond

    var nanoseconds: UInt64 {
        return value
    }

    var microseconds: UInt64 {
        return valueFor(unit: .microsecond)
    }

    var milliseconds: UInt64 {
        return valueFor(unit: .millisecond)
    }

    var seconds: UInt64 {
        return valueFor(unit: .second)
    }

    init(value: UInt64, type: TimeUnit) {

        switch type {
            case .nanosecond:
                self.value = value
            case .microsecond:
                self.value = value * microsecondsInSecond
            case .millisecond:
                self.value = value * millisecondsInSecond
            case .second:
                self.value = value * nanosecondsInSecond
        }

        self.type = type
    }

    init(_ value: UInt64) {
        self.value = value
        self.type = .nanosecond
    }
    
    func timeinterval(unit: TimeUnit) -> Double {
        switch unit {
            case .nanosecond:
                return Double(value)
            case .microsecond:
                return Double(value) / Double(microsecondsInSecond)
            case .millisecond:
                return Double(value) / Double(millisecondsInSecond)
            case .second:
                return Double(value) / Double(nanosecondsInSecond)
        }
    }

    func valueFor(unit: TimeUnit) -> UInt64 {
        switch unit {
        case .nanosecond:
            return value
        case .microsecond:
            return value / microsecondsInSecond
        case .millisecond:
            return value / millisecondsInSecond
        case .second:
            return value / nanosecondsInSecond
        }
    }

    static func now() -> TimeValue {
        return TimeValue(mach_absolute_time())
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
        return stopwatch.elapsedTime.timeinterval(unit: .second)
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

extension ViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

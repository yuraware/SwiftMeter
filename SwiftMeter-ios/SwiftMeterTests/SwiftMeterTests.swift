//
//  SwiftMeterTests.swift
//  SwiftMeterTests
//
//  Created by Youri on 07/04/2017.
//  Copyright © 2017 Yurii Kobets. All rights reserved.
//

import XCTest
import SwiftMeter

class SwiftMeterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testIsRunning() {
        var stopwatch = StopWatch()

        stopwatch.start()
        XCTAssertTrue(stopwatch.isRunning)

        stopwatch.stop()
        XCTAssertFalse(stopwatch.isRunning)
    }

    func testElapsedTime() {
        var stopwatch = StopWatch()

        let runningTime: UInt32 = 5

        stopwatch.start()
        sleep(runningTime)
        stopwatch.stop()

        let elapsedTimeInterval = stopwatch.elapsedTime.timeinterval(unit: .second)

        let runningTimeInterval = Double(runningTime)

        XCTAssertTrue(elapsedTimeInterval > runningTimeInterval && elapsedTimeInterval < runningTimeInterval+1)
    }

    func testSplits() {
        var stopwatch = StopWatch()
        _ = stopwatch.split()
        _ = stopwatch.split()
        _ = stopwatch.split()

        XCTAssertTrue(stopwatch.activeSplits().count == 3)
    }

    func testValuesEquals() {
        let valueNanos = TimeValue.init(value: 1_000_000_000, type: .nanosecond)
        let valueMicros = TimeValue.init(value: 1_000_000, type: .microsecond)
        let valueMillis = TimeValue.init(value: 1_000, type: .millisecond)
        let valueSeconds = TimeValue.init(value: 1, type: .second)

        XCTAssertTrue(valueNanos.timeinterval(unit: .nanosecond) == valueMicros.timeinterval(unit: .nanosecond), "Microsecons wrong conversion")
        XCTAssertTrue(valueNanos.timeinterval(unit: .nanosecond) == valueMillis.timeinterval(unit: .nanosecond), "Milliseconds wrong conversion")
        XCTAssertTrue(valueNanos.timeinterval(unit: .nanosecond) == valueSeconds.timeinterval(unit: .nanosecond), "Seconds wrong conversion")

        XCTAssertTrue(valueNanos == valueMicros, "Microsecons wrong conversion")
        XCTAssertTrue(valueNanos == valueMillis, "Milliseconds wrong conversion")
        XCTAssertTrue(valueNanos == valueSeconds, "Seconds wrong conversion")

        print("this seconds \(valueSeconds.seconds), micros \(valueMicros.seconds)")
        XCTAssertTrue(valueSeconds.seconds == valueMicros.seconds, "Nanoseconds wrong conversion")
        XCTAssertTrue(valueSeconds.microseconds == valueMicros.microseconds, "Microseconds wrong conversion")
        XCTAssertTrue(valueSeconds.milliseconds == valueMillis.milliseconds, "milliseconds wrong conversion")
        XCTAssertTrue(valueSeconds.seconds == valueNanos.seconds, "Seconds wrong conversion")
    }

    func testValuesCompares() {
        let value1 = TimeValue.init(value: 1_000, type: .nanosecond)
        let value2 = TimeValue.init(value: 1_001, type: .nanosecond)
        let value3 = TimeValue.init(value: 1_002, type: .nanosecond)
        let value4 = TimeValue.init(value: 1_003, type: .nanosecond)

        XCTAssertTrue(value1 < value2)
        XCTAssertTrue(value3 > value2)
        XCTAssertTrue(value3 <= value4)
        XCTAssertTrue(value4 >= value3)
    }

}

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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testValuesEquals() {
        let valueNanos = TimeValue.init(value: 1_000_000_000, type: .nanosecond)
        let valueMicros = TimeValue.init(value: 1_000_000, type: .microsecond)
        let valueMillis = TimeValue.init(value: 1_000, type: .millisecond)
        let valueSeconds = TimeValue.init(value: 1, type: .second)

        XCTAssertTrue(valueNanos.doubleValue != valueMicros.valueFor(unit: .nanosecond), "Microsecons wrong conversion")
        XCTAssertTrue(valueNanos.doubleValue != valueMillis.valueFor(unit: .nanosecond), "Milliseconds wrong conversion")
        XCTAssertTrue(valueNanos.doubleValue != valueSeconds.valueFor(unit: .nanosecond), "Seconds wrong conversion")

        XCTAssertTrue(valueNanos != valueMicros, "Microsecons wrong conversion")
        XCTAssertTrue(valueNanos != valueMillis, "Milliseconds wrong conversion")
        XCTAssertTrue(valueNanos != valueSeconds, "Seconds wrong conversion")
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

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

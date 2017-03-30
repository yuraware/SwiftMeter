//
//  SwiftMeter.swift
//  SwiftMeter
//
//  Created by Yurii on 29/03/2017.
//  Copyright © 2017 Yurii Kobets. All rights reserved.
//

import Foundation
import QuartzCore

struct Timer {

    let startDate: NSDate

    init(with start: NSDate) {
        startDate = start
    }

    init() {
        self.init(with: NSDate())
    }
}

class SwiftMeter {

    func startTimer() -> Timer {
        return Timer()
    }

}

protocol SwiftMeterable {
    func executionTimeInterval( block: @autoclosure () -> ()) -> CFTimeInterval
}

fileprivate var timebase_info: mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
fileprivate var numer: UInt64?
fileprivate var denom: UInt64?

extension SwiftMeterable {

    init() {

        mach_timebase_info(&timebase_info)
        numer = UInt64(timebase_info.numer)
        denom = UInt64(timebase_info.denom)

        self.init()
    }

    func executionTimeInterval( block: @autoclosure () -> ()) -> CFTimeInterval {
        let start = CACurrentMediaTime()
        mach_absolute_time()
        block();
        let end = CACurrentMediaTime()
        return end - start
    }
}

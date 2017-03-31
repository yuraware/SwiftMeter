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

    let startDate: NSDate

    init(with start: NSDate) {

        mach_timebase_info(&timebase_info)
        numer = UInt64(timebase_info.numer)
        denom = UInt64(timebase_info.denom)

        startDate = start
    }

    init() {
        self.init(with: NSDate())
    }
}

class SwiftMeter {

    func startTimer() -> StopWatch {
        return StopWatch()
    }

}

protocol SwiftMeterable {
    func executionTimeInterval( block: @autoclosure () -> ()) -> CFTimeInterval
}

extension SwiftMeterable {

    init() {

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

//
//  SwiftMeter.swift
//  SwiftMeter
//
//  Created by Yurii on 29/03/2017.
//  Copyright © 2017 Yurii Kobets. All rights reserved.
//

import Foundation

struct Timer {

    let startDate: NSDate

    init(with start: NSDate) {
        startDate = start
    }

    init() {
        startDate = NSDate()
    }
}

class SwiftMeter {

    func startTimer() -> Timer {
        return Timer()
    }

}

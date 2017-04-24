//
//  ViewController.swift
//  SwiftMeter
//
//  Created by Youri on 29/03/2017.
//  Copyright © 2017 Yuri Kobets. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SwiftMeterable {

    var stopwatch = StopWatch("sleep timer")

    override func viewDidLoad() {
        super.viewDidLoad()

        let seconds = executionTimeInterval {
            stopwatch.start()
            sleep(2)
            _ = stopwatch.split("first split")
            sleep(1)
            _ = stopwatch.split()
            sleep(3)
            _ = stopwatch.split("third split")
            sleep(1)
            stopwatch.stop()
            print(stopwatch.formattedTime(unit: .second))
            print("splits \(stopwatch.activeSplits(unit: .second))")
        }

        print("execution seconds = \(seconds)")
    }
}


//
//  ViewController.swift
//  SwiftMeter
//
//  Created by Youri on 29/03/2017.
//  Copyright © 2017 Yuri Kobets. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var stopwatch = StopWatch()

    override func viewDidLoad() {
        super.viewDidLoad()

        stopwatch.start()
        sleep(2)
        _ = stopwatch.stop()
        print("Stopwatch counted \(stopwatch.elapsedTime.valueFor(unit: .second))")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


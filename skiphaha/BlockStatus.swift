//
//  BlockStatus.swift
//  skiphaha
//
//  Created by JD Penuliar on 7/9/16.
//  Copyright © 2016 JD Penuliar. All rights reserved.
//

import Foundation

class BlockStatus {
    var isRunning = false
    var timeGapForNextRun = UInt32(0)
    var currentInterval = UInt32(0)
    init(isRunning:Bool, timeGapForNextRun:UInt32, currentInterval:UInt32){
        self.isRunning = isRunning
        self.timeGapForNextRun = timeGapForNextRun
        self.currentInterval = currentInterval
    }
    func shouldRUnBLock() -> Bool{
        return self.currentInterval > self.timeGapForNextRun
    }
}
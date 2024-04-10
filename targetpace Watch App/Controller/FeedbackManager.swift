//
//  FeedbackManager.swift
//  targetpace Watch App
//
//  Created by admin on 4/10/24.
//

import Foundation
import WatchKit

class FeedbackManager {
    static let shared = FeedbackManager()
    
    private let device = WKInterfaceDevice.current()
    
    func achieveTargetPace() {
        device.play(.success)
        print("achieved target pace")
    }
    
    func runningTooFast() {
        for _ in 0..<3 {
            device.play(.failure)
            Thread.sleep(forTimeInterval: 0.5)
        }
        print("running too fast")
    }
    
    func runningTooSlow() {
        for _ in 0..<3 {
            device.play(.failure)
            Thread.sleep(forTimeInterval: 1.0)
        }
        print("running too slow")
    }
}

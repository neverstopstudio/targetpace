//
//  targetpaceApp.swift
//  targetpace Watch App
//
//  Created by admin on 4/10/24.
//

import SwiftUI

@main
struct targetpace_Watch_AppApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    workoutManager.requestAuthorization()
                    workoutManager.selectedWorkout = .running
                }
                .environmentObject(workoutManager)
                .onReceive(timer) { _ in
                    // Call calculatePace() every second
                    workoutManager.calculatePace()
                }
        }
    }
}

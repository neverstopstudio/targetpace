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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .onAppear {
                    workoutManager.requestAuthorization()
                }
        }
    }
}

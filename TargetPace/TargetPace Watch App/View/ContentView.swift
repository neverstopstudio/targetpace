//
//  ContentView.swift
//  targetpace Watch App
//
//  Created by admin on 4/10/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selectedTab = 0
    @AppStorage("targetPace") var targetPace: Double = 0.0
    @AppStorage("previousPace") var previousPace: Double = 0.0
    
    // Function to set both target pace and previous pace
    func setPace(newPace: Double) {
        previousPace = targetPace
        targetPace = newPace
        print(previousPace, newPace)
    }
    
    var body: some View {
        if workoutManager.authorizationGranted {
            TabView(selection: $selectedTab) {
                TargetPaceView(targetPace: $targetPace)
                    .environmentObject(workoutManager)
                    .tag(0)
                ConfigPaceView(selectedTab: $selectedTab, targetPace: $targetPace, previousPace: $previousPace, setPace: setPace)
                    .background(.blue)
                    .tag(1)
                ConfigPaceView(selectedTab: $selectedTab, targetPace: $targetPace, isPreviousView: true, previousPace: $previousPace, setPace: setPace)
                    .background(.gray)
                    .tag(2)
            }
        } else {
            VStack(alignment: .leading){
                Text("⚠️ Oops! It seems some required permissions are not enabled for this app. Go to the 'Settings' app to grant access and unlock all features.")
                
                Spacer()
                Button {
                    workoutManager.checkAuthorizationStatus()
                } label: {
                    Text("Check Granted")
                }
                
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}

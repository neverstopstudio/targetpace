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
    @AppStorage("targetPace") var targetPace: Double = -1.0
    @State private var previousPaces: [Double] = []
    
    // Function to set both target pace and previous pace
    func setPace(newPace: Double) {
        if previousPaces.contains(targetPace) == false && targetPace > 0 {
            previousPaces.append(targetPace)
            if previousPaces.count == 6 {
                previousPaces.removeFirst();
            }
        }
        targetPace = newPace
        print(newPace)
    }
    
    var body: some View {
        VStack {
            if workoutManager.authorizationGranted {
                TabView(selection: $selectedTab) {
                    if targetPace > 0 {
                        TargetPaceView(targetPace: $targetPace)
                            .environmentObject(workoutManager)
                            .tag(0)
                    }
                    ConfigPaceView(selectedTab: $selectedTab, targetPace: $targetPace, setPace: setPace)
                        .background(.blue)
                        .tag(1)
                    ForEach(previousPaces.indices.reversed(), id: \.self) { index in
                        PreviousPaceView(selectedTab: $selectedTab, previousPace: $previousPaces[index], setPace: setPace)
                            .background(.gray)
                            .tag(index + 2)
                    }
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
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}

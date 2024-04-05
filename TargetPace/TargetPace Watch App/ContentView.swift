//
//  ContentView.swift
//  TargetPace Watch App
//
//  Created by Vladyslav on 03.04.2024.
//

import SwiftUI

// Model to hold target pace data
struct TargetPace: Identifiable, Equatable {
    let id = UUID()
    let pace: Double
    
    static func == (lhs: TargetPace, rhs: TargetPace) -> Bool {
        return lhs.id == rhs.id && lhs.pace == rhs.pace
    }
}

struct ContentView: View {
    @State private var selectedPace: Double = 6.0 // Default pace
    @State private var targets: [TargetPace] = []
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TargetPaceSettingsView(selectedPace: $selectedPace, targets: $targets, selectedTab: $selectedTab)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(0)
            
            ForEach(targets.indices.reversed(), id: \.self) { index in
                CurrentTargetPaceView(target: self.targets[index])
                    .tag(index + 1)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

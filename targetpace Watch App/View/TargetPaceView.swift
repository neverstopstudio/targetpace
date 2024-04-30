//
//  TargetPaceView.swift
//  targetpace Watch App
//
//  Created by admin on 4/10/24.
//

import SwiftUI

struct TargetPaceView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var backgroundColor: Color = .clear
    @Binding var targetPace: Double
    
    var body: some View {
        VStack(alignment: .center) {
            Text("TARGET PACE")
                .font(.system(size: 20, weight: .bold))
                .padding()
            
            let minutes = Int(targetPace)
            let seconds = Int((targetPace - Double(minutes)) * 60)
            let formattedPace = "\(minutes)'\(seconds)''"
            Text(formattedPace)
                .font(.system(size: 60, weight: .bold))
                .padding()
            let currentPace = self.workoutManager.pace
            Text("CURRENT PACE: \(String(format: "%.1f", currentPace))")
                .font(.system(size: 18, weight: .bold))
                .onAppear {
                    if self.targetPace == self.workoutManager.pace {
                        DispatchQueue.global().async {
                            FeedbackManager.shared.achieveTargetPace()
                        }
                    }
                }
            
            if targetPace > currentPace {
                Text("GO FASTER!")
                    .font(.system(size: 18, weight: .bold))
                    .onAppear {
                        DispatchQueue.global().async {
                            FeedbackManager.shared.runningTooSlow()
                        }
                    }
            }
            
            if targetPace < currentPace {
                Text("GO SLOWER!")
                    .font(.system(size: 18, weight: .bold))
                    .onAppear {
                        DispatchQueue.global().async {
                            FeedbackManager.shared.runningTooFast()
                        }
                    }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .onAppear() {
            updateUI()
        }
        .onChange(of: self.workoutManager.pace) {
            updateUI()
        }
    }
    
    private func updateUI() {
        let currentPace = self.workoutManager.pace
        let tolerance: Double = 0.5 // Adjust this value as needed
        
        if targetPace <= currentPace {
            backgroundColor = .green
        } else if targetPace <= currentPace + tolerance {
            backgroundColor = .yellow
        } else {
            backgroundColor = .red
        }
    }
}

#Preview {
    TargetPaceView(targetPace: .constant(5.0))
        .environmentObject(WorkoutManager())
}

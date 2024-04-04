//
//  CurrentTargetPaceView.swift
//  TargetPace Watch App
//
//  Created by Vladyslav on 04.04.2024.
//

import SwiftUI

struct CurrentTargetPaceView: View {
    @State var target: TargetPace
    let currentTarget: Double = 7.5 // Your current target pace
    @State private var backgroundColor: Color = .green
    
    var body: some View {
        VStack(alignment: .center) {
            Text("TARGET PACE")
                .font(.system(size: 20, weight: .bold))
                .padding()
            
            let minutes = Int(target.pace)
            let seconds = Int((target.pace - Double(minutes)) * 60)
            let formattedPace = "\(minutes)'\(seconds)''"
            Text(formattedPace)
                .font(.system(size: 60, weight: .bold))
                .padding()
            
            Text("CURRENT PACE: \(String(format: "%.1f", currentTarget))")
                .font(.system(size: 18, weight: .bold))
            
            if target.pace > currentTarget {
                Text("GO FASTER!")
                    .font(.system(size: 18, weight: .bold))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onChange(of: target) { _ in
            updateUI()
        }
        .onAppear {
            updateUI()
        }
        .background(backgroundColor)
    }
    
    private func updateUI() {
        let tolerance: Double = 0.2 // Adjust this value as needed
        if target.pace <= currentTarget {
            backgroundColor = .green
        } else if target.pace <= currentTarget + tolerance {
            backgroundColor = .yellow
        } else {
            backgroundColor = .red
        }
    }
}

struct CurrentTargetPaceView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentTargetPaceView(target: TargetPace(pace: 7.5))
    }
}

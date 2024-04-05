//
//  TargetPaceSettingsView.swift
//  TargetPace Watch App
//
//  Created by Vladyslav on 04.04.2024.
//

import SwiftUI

struct TargetPaceSettingsView: View {
    @Binding var selectedPace: Double
    @Binding var targets: [TargetPace]
    @Binding var selectedTab: Int
    
    let paceOptions: [Double] = Array(stride(from: 0.0, through: 10.0, by: 0.1))

    var body: some View {
        VStack {
            Picker("Select Target Pace", selection: $selectedPace) {
                ForEach(paceOptions, id: \.self) { pace in
                    Text(String(format: "%.1f", pace))
                        .font(.system(size: pace == self.selectedPace ? 36: 24))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 180)
        }
        .onTapGesture {
            // Handle tap gesture
            targets.append(TargetPace(pace: selectedPace))
            selectedTab = targets.count
        }
    }
}

struct TargetPaceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TargetPaceSettingsView(selectedPace: .constant(6.0), targets: .constant([]), selectedTab: .constant(0))
    }
}

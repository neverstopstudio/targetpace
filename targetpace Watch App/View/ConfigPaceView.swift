//
//  ConfigPaceView.swift
//  targetpace Watch App
//
//  Created by admin on 4/10/24.
//

import SwiftUI

struct ConfigPaceView: View {
    @Binding var selectedTab: Int
    @Binding var targetPace: Double
    @State var selectedPace: Double = 0.0
    let paceOptions: [Double] = Array(stride(from: 0.0, through: 50.0, by: 0.1))
    let setPace: (Double) -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Configure pace")
                .font(.system(size: 20, weight: .bold))
            
            Picker("", selection: $selectedPace) {
                ForEach(paceOptions, id: \.self) { pace in
                    Text(String(format: "%.1f", pace))
                        .font(.system(size: pace == self.selectedPace ? 60: 20, weight: .bold))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 80)
            .onTapGesture {
                // Handle tap gesture
                selectedTab = 0
                setPace(selectedPace)
            }
            Spacer()
        }
        .onAppear() {
            selectedPace = targetPace
        }
    }
}

#Preview {
    ConfigPaceView(selectedTab: .constant(0), targetPace: .constant(5.0)) { _ in
    }
}

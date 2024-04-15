//
//  PreviousPaceView.swift
//  targetpace Watch App
//
//  Created by admin on 4/10/24.
//

import SwiftUI

struct PreviousPaceView: View {
    @Binding var selectedTab: Int
    @State var selectedPace: Double = 0.0
    @Binding var previousPace: Double
    let setPace: (Double) -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Previous pace")
                .font(.system(size: 20, weight: .bold))
            
            Picker("", selection: $selectedPace) {
                Text(String(format: "%.1f", previousPace))
                    .font(.system(size: 60, weight: .bold))
                
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 80)
            .onTapGesture {
                // Handle tap gesture
                selectedTab = 0
                setPace(previousPace)
            }
            Spacer()
        }
    }
}

#Preview {
    PreviousPaceView(selectedTab: .constant(0), previousPace: .constant(2.0)) { _ in
    }
}

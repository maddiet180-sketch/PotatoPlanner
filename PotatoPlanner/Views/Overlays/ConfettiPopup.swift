//
//  ConfettiPopup.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/21/26.
//

import SwiftUI

struct ConfettiPopup: View {
    @State private var flowerOffset: CGFloat = -1600
    
    var body: some View {
        Group {
            Image("FlowerForeground")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .allowsHitTesting(false)
        .offset(x: 0, y:flowerOffset)
        .onAppear {
            withAnimation(.easeInOut.speed(0.08)) {
                flowerOffset = 2000
            }
        }
    }
}

#Preview {
    ConfettiPopup()
}

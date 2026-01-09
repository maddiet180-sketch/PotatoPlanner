//
//  TopBarView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/18/25.
//

import SwiftUI

struct TopBarView: View {
    @EnvironmentObject var potatoViewModel: PotatoPlannerModel
    var body: some View {
        HStack{
            Image(systemName: "line.3.horizontal")
                .font(.title2.bold())
                .foregroundStyle(.textboxBackground)
            Spacer()
            Button(action: {}) {
                ZStack(alignment: .trailing) {
                    Image("SpudCount")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                    Text("\(potatoViewModel.state.spuds)")
                        .padding(.trailing, 25)
                        .font(.body)
                }
            }
        }
        .foregroundStyle(.primaryText)
        .fontWeight(.heavy)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TopBarView()
        .environmentObject(PotatoPlannerModel())
}

//
//  MainPotatoView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/18/25.
//

import SwiftUI

struct MainPotatoView: View {
    let potato: Potato
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                PotatoInfo(potato: potato, style: .main)
                Spacer()
            }
            .padding()
            .frame(width: 150)
            // FIXME: add geo reader to cover about 33%
            Spacer()
            potatoImage
            Spacer()
        }
        .frame(height: 225)
        .background(potatoCardBackground)
    }
    
    private var potatoImage: some View {
        VStack {
            if let potatoType = PotatoCatalog.kind(for: potato.typeID) {
                Spacer()
                Image(potatoType.imageName(for: potato.level))
                    .resizable()
                    .scaledToFit()
            }
        }
    }
    
    private var potatoCardBackground: some View {
        RoundedRectangle(cornerRadius: 12.0)
            .fill(.textboxBackground)
            .stroke(Color(.primaryText), lineWidth: 3)
    }
}

#Preview {
    MainPotatoView(potato: .preview)
        .environmentObject(PotatoPlannerModel())
}

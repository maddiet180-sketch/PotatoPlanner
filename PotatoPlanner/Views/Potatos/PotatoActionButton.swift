//
//  PotatoActionButton.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 1/2/26.
//

import SwiftUI

struct PotatoActionButton: View {
    @EnvironmentObject var potatoViewModel: PotatoPlannerModel
    let potatoType: PotatoType
    let style: ButtonStyle
    
    enum ButtonStyle {
        case compact
        case large
    }
    
    private var actionType: ActionType {
        if let ownedPotato = potatoViewModel.ownedPotato(for: potatoType) {
            return potatoViewModel.isPotatoEquiped(potato: ownedPotato) ? .equipped : .equip(ownedPotato)
        } else {
            return .buy
        }
    }
    
    private enum ActionType {
        case buy
        case equip(Potato)
        case equipped
        
        var title: String {
            switch self {
            case .buy: return "Buy"
            case .equip: return "Equip"
            case .equipped: return "Equipped"
            }
        }
        
        var isDisabled: Bool {
            if case .equipped = self { return true }
            return false
        }
    }
    
    var body: some View {
        Button {
            performAction()
        } label: {
            buttonLabel
        }
        .buttonStyle(.bordered)
        .foregroundStyle(buttonTextColor)
        .font(style == .compact ? .caption.bold() : .body.bold())
        .background(buttonBackground)
        .disabled(isDisabled)
    }
    
    private var buttonLabel: some View {
        switch actionType {
        case .buy:
            Text(" \(potatoType.cost) spuds ")
        case .equip, .equipped:
            Text(actionType.title)
        }
    }
    
    private var buttonTextColor: Color {
        if style == .large {
            return .primaryText
        } else {
            switch actionType {
            case .equip, .equipped: return .textboxBackground
            case .buy: return .primaryText
            }
        }
    }
    
    private var buttonBackground: some View {
        let lineWidth = style == .large ? 3 : 0
        
        return RoundedRectangle(cornerRadius: 30)
            .fill(backgroundColor)
            .stroke(.primaryText, lineWidth: CGFloat(lineWidth))
            .opacity(backgroundOpacity)
    }
    
    private var backgroundColor: Color {
        if style == .large {
            return .textboxBackground
        } else {
            switch actionType {
            case .buy:
                return .textboxBackground
            case .equip:
                return .accentColor1C
            case .equipped:
                return .primaryText
            }
        }
    }
    
    private var backgroundOpacity: Double {
        if style == .large {
            return 1.0
        } else {
            switch actionType {
            case .buy:
                return 1.0
            case .equip:
                return 0.7
            case .equipped:
                return 0.3
            }
        }
    }
    
    private var isDisabled: Bool {
        switch actionType {
        case .buy:
            return potatoViewModel.state.spuds < potatoType.cost
        case .equip:
            return false
        case .equipped:
            return true
        }
    }
    
    private func performAction() {
        switch actionType {
        case .buy:
            potatoViewModel.buyPotato(of: potatoType)
            break
        case .equip(let potato):
            potatoViewModel.equipPotato(potato: potato)
        case .equipped:
            break
        }
    }
}

//#Preview {
//    PotatoActionButton()
//}

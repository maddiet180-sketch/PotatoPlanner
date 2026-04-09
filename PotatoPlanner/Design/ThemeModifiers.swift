//
//  ThemeModifiers.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/12/25.
//

import SwiftUI

// App-wide constants for background and text

enum AppTheme {
    static let primaryBackground = Color("PrimaryBackgroundColor")
    static let primaryText = Color("PrimaryTextColor")
}

struct AppThemeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(AppTheme.primaryText)
            .font(.system(.body, design: .rounded))
            .fontWeight(.heavy)
    }
}

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Image("MainBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
    }
}

struct SoundButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    SoundManager.shared.playSound(named: "KeyboardClick8")
                }
            }
    }
}

extension View {
    func appTheme() -> some View {
        self.modifier(AppThemeModifier())
    }

    func appBackground() -> some View {
        self.modifier(AppBackgroundModifier())
    }
}

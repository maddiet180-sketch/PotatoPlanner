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
            .background(
                Image("TempBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
    }
}

extension View {
    func appTheme() -> some View {
        self.modifier(AppThemeModifier())
    }
}

//
//  FrameView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/23/25.
//

import SwiftUI

struct DrawnFrameModifier: ViewModifier {
    var padding: CGFloat = 16
    var capInset: CGFloat = 24
    var frameNumber: Int = 1

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .overlay {
                Image("TextboxFrame\(frameNumber)")
                    .resizable(
                        capInsets: EdgeInsets(
                            top: capInset, leading: capInset,
                            bottom: capInset, trailing: capInset
                        ),
                        resizingMode: .stretch
                    )
                    .allowsHitTesting(false)
            }
    }
}

extension View {
    func drawnFrame(padding: CGFloat = 10, capInset: CGFloat = 1, frameNumber: Int = 1) -> some View {
        self.modifier(DrawnFrameModifier(padding: padding, capInset: capInset, frameNumber: frameNumber))
    }
}


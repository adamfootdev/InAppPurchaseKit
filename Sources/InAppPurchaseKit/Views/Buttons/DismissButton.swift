//
//  DismissButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 05/02/2024.
//

import SwiftUI

#if os(iOS)
struct DismissButton: View {
    private let action: () -> Void

    init(perform action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        CloseButton(perform: action)
    }
}

fileprivate struct CloseButton: UIViewRepresentable {
    private let action: () -> Void

    init(perform action: @escaping () -> Void) {
        self.action = action
    }

    func makeUIView(context: Context) -> UIButton {
        UIButton(
            type: .close,
            primaryAction: UIAction { _ in
                action()
            }
        )
    }

    func updateUIView(_ uiView: UIButton, context: Context) {}
}

#Preview {
    DismissButton {
        print("Done")
    }
    .frame(width: 0, height: 0)
}
#endif

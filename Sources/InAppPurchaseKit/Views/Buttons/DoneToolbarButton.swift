//
//  DoneToolbarButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 16/01/2026.
//

import SwiftUI

struct DoneToolbarButton: View {
    /// The action to perform when pressed.
    private let action: () -> Void
    
    /// Creates a new `DoneToolbarButton` view.
    /// - Parameter action: The action to perform when pressed.
    init(_ action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Group {
            if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
                Button(role: .close, action: action) {
                    Label {
                        Text("Done", bundle: .module)
                    } icon: {
                        Image(systemName: "xmark")
                    }
                }
                #if os(macOS)
                .labelStyle(.titleOnly)
                #elseif os(visionOS)
                .buttonBorderShape(.circle)
                #endif

            } else {
                #if os(iOS)
                DismissButton(perform: action)
                #else
                Button(action: action) {
                    Label {
                        Text("Done", bundle: .module)
                    } icon: {
                        Image(systemName: "xmark")
                    }
                }
                #if os(macOS)
                .labelStyle(.titleOnly)
                #elseif os(visionOS)
                .buttonBorderShape(.circle)
                #endif
                #endif
            }
        }
        #if os(iOS) || os(macOS) || os(visionOS)
        .background {
            Button(action: action) {
                Label {
                    Text("Close", bundle: .module)
                } icon: {
                    Image(systemName: "xmark")
                }
            }
            .hidden()
            .keyboardShortcut(.cancelAction)
        }
        #endif
    }
}

#Preview {
    DoneToolbarButton {
        print("Dismiss")
    }
}

//
//  View+OnChange.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

extension View {
    func compatibleOnChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void
    ) -> some View where V: Equatable {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *) {
            return self
                .onChange(of: value, initial: initial, action)
        } else {
            return self
                .onChange(of: value) { newValue in
                    action(value, newValue)
                }
        }
    }

    func compatibleOnChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View where V: Equatable {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *) {
            return self
                .onChange(of: value, initial: initial, action)
        } else {
            return self
                .onChange(of: value) { _ in
                    action()
                }
        }
    }
}


extension Scene {
    func compatibleOnChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void
    ) -> some Scene where V: Equatable {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *) {
            return self
                .onChange(of: value, initial: initial, action)
        } else {
            return self
                .onChange(of: value) { newValue in
                    action(value, newValue)
                }
        }
    }

    func compatibleOnChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    ) -> some Scene where V: Equatable {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *) {
            return self
                .onChange(of: value, initial: initial, action)
        } else {
            return self
                .onChange(of: value) { _ in
                    action()
                }
        }
    }
}

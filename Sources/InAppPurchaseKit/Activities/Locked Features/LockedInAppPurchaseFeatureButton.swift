//
//  LockedInAppPurchaseFeatureButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 02/06/2025.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureButton: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let title: String
    private let systemImage: String
    private let enableIfLegacyUser: Bool
    private let action: (() -> Void)
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

    public init(
        _ title: String,
        systemImage: String,
        enableIfLegacyUser: Bool = false,
        action: (@escaping () -> Void),
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.enableIfLegacyUser = enableIfLegacyUser
        self.action = action
        self.onPurchaseAction = onPurchaseAction
    }

    public var body: some View {
        Button {
            if inAppPurchase.purchaseState == .purchased || (enableIfLegacyUser && inAppPurchase.productsLoadState.isLegacyUser) {
                action()
            } else {
                showingPurchaseSheet = true
            }
        } label: {
            if inAppPurchase.purchaseState == .purchased || (enableIfLegacyUser && inAppPurchase.productsLoadState.isLegacyUser) {
                #if os(macOS)
                Text(title)
                #else
                Label(title, systemImage: systemImage)
                #endif
            } else {
                LabeledContent {
                    Image(systemName: "lock.fill")
                } label: {
                    #if os(macOS)
                    Text(title)
                    #else
                    Label {
                        Text(title)
                            .foregroundStyle(Color.primary)
                    } icon: {
                        Image(systemName: systemImage)
                    }
                    #endif
                }
            }
        }
        #if os(macOS)
        .buttonStyle(.plain)
        #endif
        .sheet(isPresented: $showingPurchaseSheet) {
            InAppPurchaseView()
        }
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    NavigationStack {
        Form {
            LockedInAppPurchaseFeatureButton(
                "Title",
                systemImage: "app"
            ) {
                print("Pressed")
            }
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
        .navigationTitle("Settings")
        .environment(inAppPurchase)
    }
}

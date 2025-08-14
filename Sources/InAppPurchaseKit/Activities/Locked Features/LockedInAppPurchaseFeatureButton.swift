//
//  LockedInAppPurchaseFeatureButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 02/06/2025.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureButton: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let titleKey: LocalizedStringKey?
    private let title: String?
    private let systemImage: String?
    private let titleColor: Color
    private let enableIfLegacyUser: Bool
    private let action: (() -> Void)
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        action: (@escaping () -> Void),
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = systemImage
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.action = action
        self.onPurchaseAction = onPurchaseAction
    }

    public init(
        _ titleKey: LocalizedStringKey,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        action: (@escaping () -> Void),
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = nil
        self.titleColor = titleColor
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
                label
            } else {
                LabeledContent {
                    Image(systemName: "lock.fill")
                } label: {
                    label
                }
            }
        }
        #if os(macOS)
        .buttonStyle(.plain)
        #endif
        #if os(tvOS)
        .fullScreenCover(isPresented: $showingPurchaseSheet) {
            InAppPurchaseView(onPurchase: onPurchaseAction)
                .background(Material.regular)
        }
        #else
        .sheet(isPresented: $showingPurchaseSheet) {
            InAppPurchaseView(onPurchase: onPurchaseAction)
        }
        #endif
    }

    @ViewBuilder
    private var label: some View {
        if let titleKey, let systemImage {
            Label {
                Text(titleKey)
                    .foregroundStyle(titleColor)
            } icon: {
                Image(systemName: systemImage)
            }
        } else if let titleKey {
            Text(titleKey)
                .foregroundStyle(titleColor)
        } else if let title, let systemImage {
            Label {
                Text(title)
                    .foregroundStyle(titleColor)
            } icon: {
                Image(systemName: systemImage)
            }
        } else if let title {
            Text(title)
                .foregroundStyle(titleColor)
        }
    }
}

extension LockedInAppPurchaseFeatureButton {
    public init(
        verbatim title: String,
        systemImage: String,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        action: (@escaping () -> Void),
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = systemImage
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.action = action
        self.onPurchaseAction = onPurchaseAction
    }

    public init(
        verbatim title: String,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        action: (@escaping () -> Void),
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = nil
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.action = action
        self.onPurchaseAction = onPurchaseAction
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

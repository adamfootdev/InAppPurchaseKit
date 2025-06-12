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
    private let enableIfLegacyUser: Bool
    private let action: (() -> Void)
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        enableIfLegacyUser: Bool = false,
        action: (@escaping () -> Void),
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = systemImage
        self.enableIfLegacyUser = enableIfLegacyUser
        self.action = action
        self.onPurchaseAction = onPurchaseAction
    }

    public init(
        _ titleKey: LocalizedStringKey,
        enableIfLegacyUser: Bool = false,
        action: (@escaping () -> Void),
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = nil
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
                if let titleKey, let systemImage {
                    Label(titleKey, systemImage: systemImage)
                } else if let titleKey {
                    Text(titleKey)
                } else if let title, let systemImage {
                    Label(title, systemImage: systemImage)
                } else if let title {
                    Text(title)
                }
            } else {
                LabeledContent {
                    Image(systemName: "lock.fill")
                } label: {
                    if let titleKey, let systemImage {
                        Label {
                            Text(titleKey)
                                .foregroundStyle(Color.primary)
                        } icon: {
                            Image(systemName: systemImage)
                        }
                    } else if let titleKey {
                        Text(titleKey)
                    } else if let title, let systemImage {
                        Label {
                            Text(title)
                                .foregroundStyle(Color.primary)
                        } icon: {
                            Image(systemName: systemImage)
                        }
                    } else if let title {
                        Text(title)
                    }
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

extension LockedInAppPurchaseFeatureButton {
    public init(
        _ title: String,
        systemImage: String,
        enableIfLegacyUser: Bool = false,
        action: (@escaping () -> Void),
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = systemImage
        self.enableIfLegacyUser = enableIfLegacyUser
        self.action = action
        self.onPurchaseAction = onPurchaseAction
    }

    public init(
        _ title: String,
        enableIfLegacyUser: Bool = false,
        action: (@escaping () -> Void),
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = nil
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

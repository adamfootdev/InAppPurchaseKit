//
//  SwiftUIView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 02/06/2025.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureRow<Content: View>: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let titleKey: LocalizedStringKey?
    private let title: String?
    private let systemImage: String?
    private let enableIfLegacyUser: Bool
    @ViewBuilder private let content: Content
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = systemImage
        self.enableIfLegacyUser = enableIfLegacyUser
        self.content = content()
        self.onPurchaseAction = onPurchaseAction
    }

    public init(
        _ titleKey: LocalizedStringKey,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = nil
        self.enableIfLegacyUser = enableIfLegacyUser
        self.content = content()
        self.onPurchaseAction = onPurchaseAction
    }

    public var body: some View {
        if inAppPurchase.purchaseState == .purchased || (enableIfLegacyUser && inAppPurchase.productsLoadState.isLegacyUser) {
            content
        } else {
            Button {
                showingPurchaseSheet = true
            } label: {
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
                            .foregroundStyle(Color.primary)
                    } else if let title, let systemImage {
                        Label {
                            Text(title)
                                .foregroundStyle(Color.primary)
                        } icon: {
                            Image(systemName: systemImage)
                        }
                    } else if let title {
                        Text(title)
                            .foregroundStyle(Color.primary)
                    }
                }
                .contentShape(Rectangle())
            }
            #if os(macOS)
            .buttonStyle(.plain)
            #endif
            .sheet(isPresented: $showingPurchaseSheet) {
                InAppPurchaseView()
            }
        }
    }
}

extension LockedInAppPurchaseFeatureRow {
    public init(
        verbatim title: String,
        systemImage: String,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = systemImage
        self.enableIfLegacyUser = enableIfLegacyUser
        self.content = content()
        self.onPurchaseAction = onPurchaseAction
    }

    public init(
        verbatim title: String,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = nil
        self.enableIfLegacyUser = enableIfLegacyUser
        self.content = content()
        self.onPurchaseAction = onPurchaseAction
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    NavigationStack {
        Form {
            LockedInAppPurchaseFeatureRow(
                "Title",
                systemImage: "app"
            ) {
                Toggle("Activated", isOn: .constant(true))
            }
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
        .navigationTitle("Settings")
        .environment(inAppPurchase)
    }
}

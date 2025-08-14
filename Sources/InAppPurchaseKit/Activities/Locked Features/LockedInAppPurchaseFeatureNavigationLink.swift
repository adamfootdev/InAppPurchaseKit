//
//  LockedInAppPurchaseFeatureNavigationLink.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/05/2025.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureNavigationLink<Content: View>: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let titleKey: LocalizedStringKey?
    private let title: String?
    private let systemImage: String?
    private let titleColor: Color
    private let enableIfLegacyUser: Bool
    @ViewBuilder private let destination: Content
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder destination: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = systemImage
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.destination = destination()
        self.onPurchaseAction = onPurchaseAction
    }

    public init(
        _ titleKey: LocalizedStringKey,
        titleColor: Color = Color.accentColor,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder destination: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = nil
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.destination = destination()
        self.onPurchaseAction = onPurchaseAction
    }

    public var body: some View {
        if inAppPurchase.purchaseState == .purchased || (enableIfLegacyUser && inAppPurchase.productsLoadState.isLegacyUser) {
            NavigationLink {
                destination
            } label: {
                label
            }
        } else {
            Button {
                showingPurchaseSheet = true
            } label: {
                LabeledContent {
                    Image(systemName: "lock.fill")
                } label: {
                    label
                }
                .contentShape(Rectangle())
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

extension LockedInAppPurchaseFeatureNavigationLink {
    public init(
        verbatim title: String,
        systemImage: String,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder destination: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = systemImage
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.destination = destination()
        self.onPurchaseAction = onPurchaseAction
    }

    public init(
        verbatim title: String,
        titleColor: Color = Color.primary,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder destination: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = nil
        self.titleColor = titleColor
        self.enableIfLegacyUser = enableIfLegacyUser
        self.destination = destination()
        self.onPurchaseAction = onPurchaseAction
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    NavigationStack {
        Form {
            LockedInAppPurchaseFeatureNavigationLink(
                "Title",
                systemImage: "app"
            ) {
                Text("Destination")
            }
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
        .navigationTitle("Settings")
        .environment(inAppPurchase)
    }
}

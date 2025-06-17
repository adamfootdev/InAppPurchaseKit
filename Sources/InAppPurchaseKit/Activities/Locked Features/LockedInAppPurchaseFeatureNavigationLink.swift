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
    private let enableIfLegacyUser: Bool
    @ViewBuilder private let destination: Content
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder destination: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = systemImage
        self.enableIfLegacyUser = enableIfLegacyUser
        self.destination = destination()
        self.onPurchaseAction = onPurchaseAction
    }

    public init(
        _ titleKey: LocalizedStringKey,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder destination: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.title = nil
        self.systemImage = nil
        self.enableIfLegacyUser = enableIfLegacyUser
        self.destination = destination()
        self.onPurchaseAction = onPurchaseAction
    }

    public var body: some View {
        if inAppPurchase.purchaseState == .purchased || (enableIfLegacyUser && inAppPurchase.productsLoadState.isLegacyUser) {
            NavigationLink {
                destination
            } label: {
                if let titleKey, let systemImage {
                    Label(titleKey, systemImage: systemImage)
                } else if let titleKey {
                    Text(titleKey)
                } else if let title, let systemImage {
                    Label(title, systemImage: systemImage)
                } else if let title {
                    Text(title)
                }
            }
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

extension LockedInAppPurchaseFeatureNavigationLink {
    public init(
        verbatim title: String,
        systemImage: String,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder destination: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = systemImage
        self.enableIfLegacyUser = enableIfLegacyUser
        self.destination = destination()
        self.onPurchaseAction = onPurchaseAction
    }

    public init(
        verbatim title: String,
        enableIfLegacyUser: Bool = false,
        @ViewBuilder destination: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.titleKey = nil
        self.title = title
        self.systemImage = nil
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

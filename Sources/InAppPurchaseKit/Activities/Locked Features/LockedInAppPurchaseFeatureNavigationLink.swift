//
//  LockedInAppPurchaseFeatureNavigationLink.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/05/2025.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureNavigationLink<Content: View>: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let title: String
    private let systemImage: String
    private let enableIfLegacyUser: Bool
    private let destination: Content
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

    public init(
        _ title: String,
        systemImage: String,
        enableIfLegacyUser: Bool = false,
        destination: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.enableIfLegacyUser = enableIfLegacyUser
        self.destination = destination()
        self.onPurchaseAction = onPurchaseAction
    }
    
    public var body: some View {
        if inAppPurchase.purchaseState == .purchased || (enableIfLegacyUser && inAppPurchase.productsLoadState.isLegacyUser) {
            NavigationLink {
                destination
            } label: {
                #if os(macOS)
                Text(title)
                #else
                Label(title, systemImage: systemImage)
                #endif
            }
        } else {
            Button {
                showingPurchaseSheet = true
            } label: {
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

//
//  SwiftUIView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 02/06/2025.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureRow<Content: View>: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let title: String
    private let systemImage: String
    private let enableIfLegacyUser: Bool
    private let content: Content
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

    public init(
        _ title: String,
        systemImage: String,
        enableIfLegacyUser: Bool = false,
        content: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
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

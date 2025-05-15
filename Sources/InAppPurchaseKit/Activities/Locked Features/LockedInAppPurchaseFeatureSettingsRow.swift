//
//  LockedInAppPurchaseFeatureSettingsRow.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/05/2025.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureSettingsRow<Content: View>: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let title: String
    private let systemImage: String
    private let destination: Content
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

    public init(
        _ title: String,
        systemImage: String,
        destination: @escaping () -> Content,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.destination = destination()
        self.onPurchaseAction = onPurchaseAction
    }
    
    public var body: some View {
        if inAppPurchase.purchaseState == .purchased {
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
            LockedInAppPurchaseFeatureSettingsRow(
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

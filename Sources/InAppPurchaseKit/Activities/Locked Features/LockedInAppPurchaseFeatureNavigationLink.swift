//
//  LockedInAppPurchaseFeatureNavigationLink.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 15/05/2025.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureNavigationLink<Content: View>: View {
    /// Creates a new `InAppPurchaseKit` object to monitor.
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    /// The `LockedFeatureConfiguration` to use for the view.
    private let configuration: LockedFeatureConfiguration
    
    /// The view to show if the user is subscribed.
    @ViewBuilder private let destination: Content

    /// A `Bool` indicating whether the in-app purchase sheet is shown.
    @State private var showingPurchaseSheet: Bool = false
    
    /// Creates a new `LockedInAppPurchaseFeatureNavigationLink` view.
    /// - Parameters:
    ///   - configuration: The `LockedFeatureConfiguration` to use for the view.
    ///   - destination: The view to show if the user is subscribed.
    public init(
        configuration: LockedFeatureConfiguration,
        @ViewBuilder destination: @escaping () -> Content
    ) {
        self.configuration = configuration
        self.destination = destination()
    }

    public var body: some View {
        if inAppPurchase.purchaseState == .purchased || (configuration.enableIfLegacyUser && inAppPurchase.productsLoadState.isLegacyUser) {
            NavigationLink {
                destination
            } label: {
                LockedFeatureLabel(configuration: configuration)
            }
        } else {
            Button {
                showingPurchaseSheet = true
            } label: {
                LabeledContent {
                    Image(systemName: "lock.fill")
                } label: {
                    LockedFeatureLabel(configuration: configuration)
                }
                .contentShape(Rectangle())
            }
            #if os(macOS)
            .buttonStyle(.plain)
            #endif
            #if os(tvOS)
            .fullScreenCover(isPresented: $showingPurchaseSheet) {
                InAppPurchaseView(onPurchase: configuration.onPurchaseAction)
                    .background(Material.regular)
            }
            #else
            .sheet(isPresented: $showingPurchaseSheet) {
                InAppPurchaseView(onPurchase: configuration.onPurchaseAction)
            }
            #endif
        }
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    NavigationStack {
        Form {
            LockedInAppPurchaseFeatureNavigationLink(configuration: .example) {
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

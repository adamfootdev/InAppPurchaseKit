//
//  LockedInAppPurchaseFeatureView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 26/02/2024.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureView: View {
    /// Creates a new `InAppPurchaseKit` object to monitor.
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    /// An optional action to perform when a transaction is completed. This is separate
    /// to the action set in `InAppPurchaseKitConfiguration` but both
    /// will be performed. If an action is set, you will need to also dismiss the view. This
    /// is handled automatically when no action is set.
    private let onPurchaseAction: (@Sendable () -> Void)?
    
    /// A `Bool` indicating whether the in-app purchase sheet is shown.
    @State private var showingPurchaseSheet: Bool = false
    
    /// Creates a new `LockedInAppPurchaseFeatureView`.
    /// - Parameter onPurchaseAction: An optional action to perform when a transaction is completed. This is separate
    ///   to the action set in `InAppPurchaseKitConfiguration` but both
    ///   will be performed. If an action is set, you will need to also dismiss the view. This
    ///   is handled automatically when no action is set. Defaults to `nil`.
    public init(
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.onPurchaseAction = onPurchaseAction
    }

    public var body: some View {
        VStack(spacing: 32) {
            InAppPurchaseHeaderView(
                subtitle: String(
                    localized: "This feature requires access to \(inAppPurchase.configuration.title)",
                    bundle: .module
                ),
                configuration: inAppPurchase.configuration
            )
            .frame(maxWidth: .infinity)

            VStack(spacing: 16) {
                SinglePurchaseButton()
                    #if os(tvOS) || os(visionOS)
                    .buttonStyle(.borderedProminent)
                    #elseif os(watchOS)
                    .buttonStyle(.bordered)
                    #endif

                Button {
                    showingPurchaseSheet = true
                } label: {
                    Text("Learn More")
                        #if os(visionOS)
                        .padding(.horizontal, 8)
                        #endif
                }
                #if os(macOS)
                .font(.subheadline)
                .foregroundStyle(inAppPurchase.configuration.tintColor)
                #elseif os(tvOS)
                .buttonStyle(.bordered)
                .font(.subheadline)
                .padding(.top, 12)
                #elseif os(visionOS)
                .buttonStyle(.bordered)
                .font(.subheadline.bold())
                .controlSize(.small)
                #elseif os(watchOS)
                .buttonStyle(.bordered)
                #else
                .buttonStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(inAppPurchase.configuration.tintColor)
                #endif
            }
        }
        .listRowInsets(.init(
            top: listVerticalPadding,
            leading: listHorizontalPadding,
            bottom: listVerticalPadding,
            trailing: listHorizontalPadding
        ))
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

    private var listVerticalPadding: CGFloat {
        #if os(tvOS)
        return 80
        #else
        return 16
        #endif
    }

    private var listHorizontalPadding: CGFloat {
        #if os(tvOS)
        return 40
        #elseif os(watchOS)
        return 8
        #else
        return 16
        #endif
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.configure(with: .example)

    NavigationStack {
        List {
            LockedInAppPurchaseFeatureView()
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
        .navigationTitle("Settings")
        .environment(inAppPurchase)
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    NavigationStack {
        LockedInAppPurchaseFeatureView()
            .navigationTitle("Settings")
            .environment(inAppPurchase)
    }
}

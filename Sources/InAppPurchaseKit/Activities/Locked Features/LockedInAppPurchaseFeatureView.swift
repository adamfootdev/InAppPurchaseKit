//
//  LockedInAppPurchaseFeatureView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 26/02/2024.
//

import SwiftUI

public struct LockedInAppPurchaseFeatureView: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

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
    let inAppPurchase = InAppPurchaseKit.configure(with: .preview)

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

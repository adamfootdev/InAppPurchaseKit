//
//  LegacyLockedInAppPurchaseFeatureView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 26/02/2024.
//

import SwiftUI

#if canImport(HapticsKit)
import HapticsKit
#endif

public struct LegacyLockedInAppPurchaseFeatureView: View {
    @StateObject private var inAppPurchase: LegacyInAppPurchaseKit = .shared

    private let containedInList: Bool
    private let useNavigationLink: Bool
    private let purchaseMetadata: [String: Any]?
    private let tint: Color?

    @State private var showingPurchaseSheet: Bool = false
    @State private var showingPurchaseNavigationView: Bool = false

    public init(
        containedInList: Bool,
        useNavigationLink: Bool = false,
        purchaseMetadata: [String: Any]? = nil,
        tint: Color? = nil
    ) {
        self.containedInList = containedInList
        self.useNavigationLink = useNavigationLink
        self.purchaseMetadata = purchaseMetadata
        self.tint = tint
    }

    public var body: some View {
        VStack(spacing: 32) {
            InAppPurchaseHeaderView(
                subtitle: String(localized: "This feature requires access to \(inAppPurchase.configuration.title)"),
                configuration: inAppPurchase.configuration
            )
            .frame(maxWidth: .infinity)

            VStack(spacing: 16) {
                LegacySinglePurchaseButton(
                    purchaseMetadata: purchaseMetadata,
                    configuration: inAppPurchase.configuration
                )
                #if os(tvOS) || os(visionOS)
                .buttonStyle(.borderedProminent)
                #elseif os(watchOS)
                .buttonStyle(.bordered)
                #endif

                Button {
                    if useNavigationLink {
                        showingPurchaseNavigationView.toggle()
                    } else {
                        showingPurchaseSheet.toggle()
                    }
                } label: {
                    Text("Learn More")
                    #if os(visionOS)
                        .padding(.horizontal, 8)
                    #endif
                }
                #if os(tvOS)
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
                .foregroundStyle(tint ?? Color.accentColor)
                #endif
            }
        }
        .padding(.vertical, containedInList ? verticalPadding : 0)
        .navigationDestination(isPresented: $showingPurchaseNavigationView) {
            if let tint {
                LegacyInAppPurchaseView(
                    embedInNavigationStack: false,
                    purchaseMetadata: purchaseMetadata
                )
                .accentColor(tint)
            } else {
                LegacyInAppPurchaseView(
                    embedInNavigationStack: false,
                    purchaseMetadata: purchaseMetadata
                )
            }
        }
        .sheet(isPresented: $showingPurchaseSheet) {
            if let tint {
                LegacyInAppPurchaseView(
                    purchaseMetadata: purchaseMetadata
                )
                .accentColor(tint)
            } else {
                LegacyInAppPurchaseView(
                    purchaseMetadata: purchaseMetadata
                )
            }
        }
    }

    private var verticalPadding: CGFloat {
        #if os(tvOS)
        return 40
        #elseif os(watchOS)
        return 16
        #else
        return 8
        #endif
    }
}

#Preview {
    _ = LegacyInAppPurchaseKit.configure(with: .preview)

    return NavigationStack {
        Form {
            LegacyLockedInAppPurchaseFeatureView(containedInList: true)
                .environmentObject(LegacyInAppPurchaseKit.shared)
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
        .navigationTitle("Settings")
    }
}


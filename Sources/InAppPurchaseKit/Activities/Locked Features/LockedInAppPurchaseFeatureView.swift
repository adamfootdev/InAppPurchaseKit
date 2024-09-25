//
//  LockedInAppPurchaseFeatureView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 26/02/2024.
//

import SwiftUI

#if canImport(HapticsKit)
import HapticsKit
#endif

@available(iOS 17.0, macOS 14.4, tvOS 17.0, watchOS 10.0, *)
public struct LockedInAppPurchaseFeatureView: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let containedInList: Bool
    private let useNavigationLink: Bool
    private let purchaseMetadata: [String: String]?
    private let onPurchaseAction: (@Sendable () -> Void)?

    @State private var showingPurchaseSheet: Bool = false

    public init(
        containedInList: Bool,
        useNavigationLink: Bool = false,
        purchaseMetadata: [String: String]? = nil,
        onPurchase onPurchaseAction: (@Sendable () -> Void)? = nil
    ) {
        self.containedInList = containedInList
        self.useNavigationLink = useNavigationLink
        self.purchaseMetadata = purchaseMetadata
        self.onPurchaseAction = onPurchaseAction
    }

    public var body: some View {
        VStack(spacing: 32) {
            InAppPurchaseHeaderView(
                subtitle: String(localized: "This feature requires access to \(inAppPurchase.configuration.title)", bundle: .module),
                configuration: inAppPurchase.configuration
            )
            .frame(maxWidth: .infinity)

            VStack(spacing: 16) {
                SinglePurchaseButton(
                    purchaseMetadata: purchaseMetadata
                )
                #if os(tvOS) || os(visionOS)
                .buttonStyle(.borderedProminent)
                #elseif os(watchOS)
                .buttonStyle(.bordered)
                #endif

                Group {
                    if useNavigationLink {
                        NavigationLink("Learn More") {
                            InAppPurchaseView(
                                embedInNavigationStack: false,
                                purchaseMetadata: purchaseMetadata,
                                onPurchase: onPurchaseAction
                            )
                            .accentColor(inAppPurchase.configuration.tintColor)
                        }
                    } else {
                        Button {
                            showingPurchaseSheet = true
                        } label: {
                            Text("Learn More")
                                #if os(visionOS)
                                .padding(.horizontal, 8)
                                #endif
                        }
                    }
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
                .foregroundStyle(Color.accentColor)
                #endif
            }
        }
        .padding(.vertical, containedInList ? verticalPadding : 0)
        .sheet(isPresented: $showingPurchaseSheet) {
            InAppPurchaseView(
                purchaseMetadata: purchaseMetadata,
                onPurchase: onPurchaseAction
            )
            .accentColor(inAppPurchase.configuration.tintColor)
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

//#Preview {
//    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
//        _ = InAppPurchaseKit.configure(with: .preview)
//    }
//
//    return NavigationStack {
//        Form {
//            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
//                LockedInAppPurchaseFeatureView(containedInList: true)
//                    .environment(InAppPurchaseKit.shared)
//            }
//        }
//        #if os(macOS)
//        .formStyle(.grouped)
//        #endif
//        .navigationTitle("Settings")
//    }
//}

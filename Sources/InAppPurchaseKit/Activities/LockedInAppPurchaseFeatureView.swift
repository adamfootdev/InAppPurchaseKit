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

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
public struct LockedInAppPurchaseFeatureView: View {
    @State private var inAppPurchase: InAppPurchaseKit = .shared

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
                subtitle: "This feature requires access to \(inAppPurchase.configuration.title)",
                configuration: inAppPurchase.configuration
            )
            .frame(maxWidth: .infinity)

            VStack(spacing: 16) {
                SinglePurchaseButton(
                    purchaseMetadata: purchaseMetadata,
                    configuration: inAppPurchase.configuration
                )

                Button("Learn More") {
                    if useNavigationLink {
                        showingPurchaseNavigationView.toggle()
                    } else {
                        showingPurchaseSheet.toggle()
                    }
                }
                .buttonStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(tint ?? Color.accentColor)
            }
        }
        .padding(.vertical, containedInList ? 8 : 20)
        .padding(.horizontal, containedInList ? 0 : 20)
        .background {
            if containedInList == false {
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .fill(.fill)
            }
        }
        .navigationDestination(isPresented: $showingPurchaseNavigationView) {
            if let tint {
                InAppPurchaseView(
                    embedInNavigationStack: false,
                    purchaseMetadata: purchaseMetadata
                )
                .accentColor(tint)
            } else {
                InAppPurchaseView(
                    embedInNavigationStack: false,
                    purchaseMetadata: purchaseMetadata
                )
            }
        }
        .sheet(isPresented: $showingPurchaseSheet) {
            if let tint {
                InAppPurchaseView(
                    purchaseMetadata: purchaseMetadata
                )
                .accentColor(tint)
            } else {
                InAppPurchaseView(
                    purchaseMetadata: purchaseMetadata
                )
            }
        }
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

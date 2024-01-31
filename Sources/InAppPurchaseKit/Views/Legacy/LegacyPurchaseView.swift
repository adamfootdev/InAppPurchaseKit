//
//  LegacyPurchaseView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

#if canImport(HapticsKit)
import HapticsKit
#endif

struct LegacyPurchaseView: View {
    @EnvironmentObject private var inAppPurchase: LegacyInAppPurchaseKit

    private let configuration: InAppPurchaseKitConfiguration

    @State private var selectedTier: InAppPurchaseTier?
    @State private var showingAllOptions: Bool = false

    init(configuration: InAppPurchaseKitConfiguration) {
        self.configuration = configuration

        if configuration.tiers.count == 1 {
            _selectedTier = State(wrappedValue: configuration.tiers.first)
        } else if let tier = configuration.tiers.first(where: {
            $0.alwaysVisible
        }) {
            _selectedTier = State(wrappedValue: tier)
        } else if let tier = configuration.tiers.first {
            _selectedTier = State(wrappedValue: tier)
        }

        #if os(tvOS) || os(watchOS)
        _showingAllOptions = State(wrappedValue: true)
        #else
        let showAllOptions = configuration.tiers.count == 1 || configuration.tiers.contains(where: {
            $0.alwaysVisible
        }) == false

        _showingAllOptions = State(wrappedValue: showAllOptions)
        #endif
    }

    var body: some View {
        if (configuration.tiers.count == 1 && configuration.enableSinglePurchaseMode) {
            singleTierView

        } else {
            VStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 48) {
                    VStack(alignment: .trailing, spacing: tierSpacing) {
                        ForEach(Array(configuration.tiers.enumerated()), id: \.0) { _, tier in
                            if showingAllOptions || tier.alwaysVisible {
                                tierButton(for: tier)
                            }
                        }
                    }

                    #if os(tvOS)
                    LegacyRestoreButton()
                    #endif
                }
                #if os(tvOS)
                .frame(maxWidth: 800)
                #endif

                #if os(iOS) || os(macOS) || os(visionOS)
                VStack(spacing: 16) {
                    LegacyPurchaseButton(
                        for: $selectedTier,
                        configuration: configuration
                    )

                    if configuration.tiers.count > 1 && configuration.tiers.contains(where: {
                        $0.alwaysVisible
                    }) {
                        showAllOptionsButton
                    }
                }
                #endif
            }
        }
    }

    private var tierSpacing: CGFloat {
        #if os(tvOS)
        return 32
        #elseif os(visionOS)
        return 12
        #elseif os(watchOS)
        return 16
        #else
        return 4
        #endif
    }

    private var singleTierView: some View {
        #if os(tvOS)
        HStack(spacing: 100) {
            LegacyPurchaseButton(
                for: $selectedTier,
                configuration: configuration
            )

            LegacyRestoreButton()
        }

        #else
        LegacyPurchaseButton(
            for: $selectedTier,
            configuration: configuration
        )
        #endif
    }

    private func tierButton(
        for tier: InAppPurchaseTier
    ) -> some View {
        LegacyTierSelectionButton(
            tier: tier,
            selectedTier: $selectedTier,
            accessoryType: accessoryType(for: tier),
            configuration: configuration
        )
    }

    private func accessoryType(
        for tier: InAppPurchaseTier
    ) -> InAppPurchaseTierAccessoryType? {
        switch tier.type {
        case .yearly:
            if let yearlySaving = inAppPurchase.yearlySaving {
                return .saving(value: yearlySaving)
            } else {
                return nil
            }
        case .lifetimeExisting:
            return .loyalty
        default:
            return nil
        }
    }

    private var showAllOptionsButton: some View {
        Button {
            withAnimation(.linear(duration: 0.2)) {
                if showingAllOptions {
                    selectedTier = configuration.tiers.first(where: {
                        $0.alwaysVisible
                    })
                }

                showingAllOptions.toggle()
            }
        } label: {
            if showingAllOptions {
                Text("Hide All Options")
            } else {
                Text("Show All Options")
            }
        }
        #if os(macOS)
        .buttonStyle(.plain)
        .foregroundStyle(Color.accentColor)
        #endif
        #if os(visionOS)
        .font(.footnote)
        #else
        .font(.subheadline)
        #endif
    }
}

#Preview {
    LegacyPurchaseView(configuration: .preview)
        .environmentObject(LegacyInAppPurchaseKit.preview)
}

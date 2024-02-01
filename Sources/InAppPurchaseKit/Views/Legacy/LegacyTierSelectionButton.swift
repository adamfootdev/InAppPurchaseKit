//
//  LegacyTierSelectionButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI

#if canImport(HapticsKit)
import HapticsKit
#endif

struct LegacyTierSelectionButton: View {
    @EnvironmentObject private var inAppPurchase: LegacyInAppPurchaseKit

    private let tier: InAppPurchaseTier
    @Binding private var selectedTier: InAppPurchaseTier?
    private let accessoryType: InAppPurchaseTierAccessoryType?
    private let configuration: InAppPurchaseKitConfiguration

    init(
        tier: InAppPurchaseTier,
        selectedTier: Binding<InAppPurchaseTier?>,
        accessoryType: InAppPurchaseTierAccessoryType? = nil,
        configuration: InAppPurchaseKitConfiguration
    ) {
        self.tier = tier
        _selectedTier = selectedTier
        self.accessoryType = accessoryType
        self.configuration = configuration
    }

    var body: some View {
        #if os(tvOS)
        HStack(spacing: 24) {
            tierDetailsView
            Spacer()

            if inAppPurchase.purchaseState == .purchasing {
                ProgressView()
            } else {
                LegacyPurchaseButton(
                    for: $selectedTier,
                    configuration: configuration
                )
            }
        }

        #elseif os(watchOS)
        VStack(spacing: 4) {
            tierDetailsView
                .frame(maxWidth: .infinity, alignment: .leading)

            if inAppPurchase.purchaseState == .purchasing {
                ProgressView()
            } else {
                LegacyPurchaseButton(
                    for: $selectedTier,
                    configuration: configuration
                )
            }
        }

        #else
        tierButton
        #endif
    }

    private var tierButton: some View {
        Button {
            #if canImport(HapticsKit)
            if configuration.enableHapticFeedback {
                #if os(iOS)
                HapticsKit.performImpact(.soft, at: 0.6)
                #elseif os(watchOS)
                HapticsKit.perform(.click)
                #endif
            }
            #endif

            selectedTier = tier

            if let product = inAppPurchase.fetchProduct(for: tier) {
                Task {
                    await inAppPurchase.purchase(product)
                }
            }

        } label: {
            HStack(spacing: 16) {
                checkmarkView
                tierDetailsView
                Spacer()

                if let accessoryType {
                    Text(accessoryType.title)
                        .font(.footnote.bold())
                        .lineLimit(1)
                        .foregroundStyle(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .foregroundStyle(accessoryType.tintColor)
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            #if os(iOS) || os(macOS)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background {
                if selected {
                    RoundedRectangle(
                        cornerRadius: backgroundCornerRadius,
                        style: .continuous
                    )
                    .foregroundStyle(backgroundColor)
                }
            }
            #endif
        }
        #if os(macOS)
        .buttonStyle(.plain)
        #endif
        .disabled(inAppPurchase.purchaseState != .pending)
        .overlay {
            if inAppPurchase.purchaseState == .purchasing {
                ProgressView()
                    #if os(macOS)
                    .controlSize(.small)
                    #endif
            }
        }
    }

    private var selected: Bool {
        selectedTier == tier
    }

    private var checkmarkView: some View {
        Group {
            if selected {
                Image(systemName: "checkmark.circle.fill")
            } else {
                Image(systemName: "circle")
            }
        }
        .imageScale(.large)
        .font(.headline)
        #if os(visionOS)
        .foregroundStyle(.white)
        #else
        .foregroundStyle(Color.accentColor)
        #endif
    }

    private var tierDetailsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                if let product = inAppPurchase.fetchProduct(for: tier) {
                    Text("\(product.displayPrice)/\(tier.type.paymentTimeTitle.lowercased())")
                } else {
                    HStack(spacing: 4) {
                        ProgressView()
                            #if os(macOS) || os(visionOS)
                            .controlSize(.small)
                            #elseif os(watchOS)
                            .frame(maxWidth: 40)
                            #endif

                        Text("/\(tier.type.paymentTimeTitle.lowercased())")
                    }
                }
            }
            #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
            .bold()
            #endif
            .foregroundStyle(Color.primary)

            if let priceDetails {
                Text(priceDetails)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
        }
        .multilineTextAlignment(.leading)
    }

    private var backgroundCornerRadius: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 12
        #endif
    }

    private var backgroundColor: Color {
        #if os(macOS)
        return Color(.controlBackgroundColor)
        #elseif os(iOS)
        return Color(.systemBackground)
        #else
        return Color.gray
        #endif
    }

    private var priceDetails: String? {
        switch tier.type {
        case .weekly, .monthly, .yearly:
            guard let product = inAppPurchase.fetchProduct(for: tier),
                  let introOffer = inAppPurchase.introOffer(for: product) else {
                return nil
            }

            switch introOffer.period.unit {
            case .day:
                return String(localized: "\(introOffer.period.value) Days Free")
            case .week:
                return String(localized: "\(introOffer.period.value) Weeks Free")
            case .month:
                return String(localized: "\(introOffer.period.value) Months Free")
            default:
                return nil
            }

        case .lifetime, .lifetimeExisting:
            return String(localized: "One-time payment.")
        }
    }
}

#Preview {
    LegacyTierSelectionButton(
        tier: .example,
        selectedTier: .constant(.example),
        accessoryType: .saving(value: 20),
        configuration: .preview
    )
    .environmentObject(LegacyInAppPurchaseKit.preview)
}

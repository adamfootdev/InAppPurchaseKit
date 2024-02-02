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
        #if os(watchOS)
        VStack(spacing: 8) {
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
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading) {
                    HStack(spacing: 12) {
                        Text(tier.type.title)
                            .font(titleFont)
                            .foregroundStyle(Color.primary)

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

                    tierDetailsView
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                #if !os(tvOS)
                checkmarkView
                #endif
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            #if os(iOS) || os(macOS)
            .padding(backgroundPadding)
            .background {
                backgroundView
            }
            #elseif os(tvOS)
            .padding(.vertical, 8)
            #endif
        }
        #if os(macOS)
        .buttonStyle(.plain)
        #elseif os(visionOS)
        .buttonBorderShape(.roundedRectangle)
        #endif
        .disabled(inAppPurchase.purchaseState != .pending)
    }


    // MARK: - Details

    private var selected: Bool {
        selectedTier == tier
    }

    private var titleFont: Font {
        #if os(visionOS)
        return Font.title3
        #elseif os(tvOS)
        return Font.headline.bold()
        #else
        return Font.title3.bold()
        #endif
    }

    @ViewBuilder private var tierDetailsView: some View {
        Group {
            if inAppPurchase.fetchProduct(for: tier) == nil {
                HStack {
                    ProgressView()
                        #if !os(tvOS)
                        .controlSize(.small)
                        #endif
                }
            } else {
                Text(inAppPurchase.fetchTierSubtitle(for: tier))
                    .font(subtitleFont)
                    #if os(watchOS)
                    .multilineTextAlignment(.center)
                    #else
                    .foregroundStyle(Color.secondary)
                    #endif
            }
        }
        #if os(watchOS)
        .frame(maxWidth: .infinity)
        #else
        .frame(maxWidth: .infinity, alignment: .leading)
        #endif
    }

    private var subtitleFont: Font {
        #if os(tvOS) || os(watchOS)
        return Font.subheadline
        #else
        return Font.footnote
        #endif
    }


    // MARK: - Checkmark

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
        .foregroundStyle(selected ? Color.accentColor : Color.secondary)
        #endif
    }


    // MARK: - Background

    private var backgroundPadding: CGFloat {
        #if os(macOS)
        return 10
        #else
        return 16
        #endif
    }

    private var backgroundView: some View {
        backgroundColor
            .clipShape(RoundedRectangle(
                cornerRadius: backgroundCornerRadius,
                style: .continuous
            ))
            .overlay {
                if selected {
                    RoundedRectangle(
                        cornerRadius: backgroundCornerRadius,
                        style: .continuous
                    )
                    .stroke(
                        Color.accentColor,
                        lineWidth: 2
                    )
                }
            }
    }

    private var backgroundCornerRadius: CGFloat {
        #if os(macOS)
        return 6
        #else
        return 12
        #endif
    }

    private var backgroundColor: Color {
        #if os(iOS)
        return Color(.secondarySystemBackground)
        #elseif os(macOS)
        return Color(.controlBackgroundColor)
        #else
        return Color.gray
        #endif
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

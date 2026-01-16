//
//  TierSelectionButton.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 31/01/2024.
//

import SwiftUI
import HapticsKit

struct TierSelectionButton: View {
    @Environment(InAppPurchaseKit.self) private var inAppPurchase
    
    /// The `PurchaseTier` to display.
    private let tier: PurchaseTier
    
    /// The current selected `PurchaseTier`.
    @Binding private var selectedTier: PurchaseTier?
    
    /// An optional accessory type to show for the tier.
    private let accessoryType: PurchaseTierAccessoryType?
    
    /// Creates a new `TierSelectionButton`.
    /// - Parameters:
    ///   - tier: The `PurchaseTier` to display.
    ///   - selectedTier: The current selected `PurchaseTier`.
    ///   - accessoryType: An optional accessory type to show for the tier.
    init(
        tier: PurchaseTier,
        selectedTier: Binding<PurchaseTier?>,
        accessoryType: PurchaseTierAccessoryType? = nil
    ) {
        self.tier = tier
        _selectedTier = selectedTier
        self.accessoryType = accessoryType
    }

    var body: some View {
        #if os(watchOS)
        VStack(spacing: 8) {
            tierDetailsView

            if inAppPurchase.transactionState == .purchasing {
                ProgressView()
            } else {
                PurchaseButton(for: .constant(tier))
            }
        }

        #else
        tierButton
        #endif
    }

    private var tierButton: some View {
        Button {
            #if os(iOS)
            HapticsKit.shared.perform(.impact(.soft, intensity: 0.6))
            #elseif os(watchOS)
            HapticsKit.shared.perform(.click)
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
                        Text(tier.title)
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
                .accessibilityElement(children: .combine)

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
            .padding(.vertical, 16)
            #endif
        }
        #if os(macOS)
        .buttonStyle(.plain)
        #elseif os(visionOS)
        .buttonBorderShape(.roundedRectangle)
        #endif
        .disabled(disableButton)
        #if os(iOS) || os(macOS) || os(visionOS)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
        #endif
    }


    // MARK: - Details

    private var selected: Bool {
        selectedTier == tier
    }

    private var titleFont: Font {
        #if os(tvOS)
        return Font.headline.bold()
        #elseif os(visionOS)
        return Font.title3
        #elseif os(watchOS)
        return Font.headline.bold()
        #else
        return Font.title3.bold()
        #endif
    }

    private var tierDetailsView: some View {
        Group {
            if inAppPurchase.fetchProduct(for: tier) == nil {
                ProgressView()
                    #if !os(tvOS)
                    .controlSize(.small)
                    #endif
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    #if os(watchOS)
                    Text(tier.title)
                        .font(titleFont)
                        .foregroundStyle(Color.primary)
                    #endif

                    Text(inAppPurchase.fetchTierSubtitle(for: tier))
                        .font(subtitleFont)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var subtitleFont: Font {
        #if os(tvOS)
        return Font.subheadline
        #else
        return Font.footnote
        #endif
    }

    private var disableButton: Bool {
        switch inAppPurchase.transactionState {
        case .pending:
            return false
        default:
            return true
        }
    }


    // MARK: - Checkmark

    private var checkmarkView: some View {
        Group {
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    #if os(visionOS)
                    .foregroundStyle(Color.white)
                    #else
                    .foregroundStyle(Color.white, inAppPurchase.configuration.tintColor)
                    #endif
            } else {
                Image(systemName: "circle")
                    #if os(visionOS)
                    .foregroundStyle(Color.white)
                    #else
                    .foregroundStyle(Color.secondary)
                    #endif
            }
        }
        .imageScale(.large)
        .font(.headline)
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
                        inAppPurchase.configuration.tintColor,
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
        return Color(.windowBackgroundColor)
        #else
        return Color.gray
        #endif
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    TierSelectionButton(
        tier: .yearly(configuration: .example),
        selectedTier: .constant(.yearly(configuration: .example)),
        accessoryType: .saving(value: 20)
    )
    .environment(inAppPurchase)
}

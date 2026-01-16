//
//  InAppPurchaseSettingsRow.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 05/02/2024.
//

import SwiftUI

public struct InAppPurchaseSettingsRow: View {
    /// Creates a new `InAppPurchaseKit` object to monitor.
    @State private var inAppPurchase: InAppPurchaseKit = .shared

    /// An optional action to perform when a transaction is completed. This is separate
    /// to the action set in `InAppPurchaseKitConfiguration` but both
    /// will be performed. If an action is set, you will need to also dismiss the view. This
    /// is handled automatically when no action is set.
    private let onPurchaseAction: (@Sendable () -> Void)?
    
    /// A `Bool` indicating whether the in-app purchase sheet is shown.
    @State private var showingPurchaseSheet: Bool = false
    
    /// Creates a new `InAppPurchaseSettingsRow` view.
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
        ZStack {
            if inAppPurchase.purchaseState == .purchased {
                subscribedButton
            } else {
                purchaseButton
            }
        }
        #if os(iOS) || os(visionOS)
        .listRowBackground(inAppPurchase.purchaseState == .purchased ? nil : purchaseBackground)
        #elseif os(watchOS)
        .listItemTint(inAppPurchase.purchaseState == .purchased ? nil : inAppPurchase.configuration.tintColor)
        #endif
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


    // MARK: - Subscribed Button

    private var subscribedButton: some View {
        Button {
            showingPurchaseSheet = true
        } label: {
            subscribedView
        }
        #if os(macOS)
        .buttonStyle(.plain)
        #endif
        .accessibilityLabel(inAppPurchase.configuration.title)
        .accessibilityValue(String(
            localized: "Subscribed",
            bundle: .module
        ))
    }

    private var subscribedView: some View {
        #if os(watchOS)
        VStack(alignment: .leading) {
            Text(inAppPurchase.configuration.title)

            Text("Subscribed")
                .font(.footnote)
                .foregroundStyle(Color.secondary)
        }

        #else
        LabeledContent {
            Text("Subscribed", bundle: .module)
        } label: {
            #if os(macOS) || os(tvOS)
            Text(inAppPurchase.configuration.title)
                .foregroundStyle(Color.primary)

            #else
            Label {
                Text(inAppPurchase.configuration.title)
                    .foregroundStyle(Color.primary)
            } icon: {
                Image(systemName: inAppPurchase.configuration.systemImage)
            }
            #endif
        }
        #endif
    }


    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            showingPurchaseSheet = true
        } label: {
            purchaseView
        }
        #if os(iOS) || os(macOS)
        .buttonStyle(.plain)
        #endif
        .accessibilityLabel(inAppPurchase.configuration.title)
    }

    private var purchaseView: some View {
        HStack(spacing: 8) {
            #if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
            Image(systemName: inAppPurchase.configuration.systemImage)
                .imageScale(.large)
                .font(titleFont)
                .foregroundStyle(titleColor)
                .padding(.trailing, 8)
                #if os(tvOS)
                .padding(.trailing, 20)
                #endif
            #endif

            VStack(alignment: .leading, spacing: purchaseSpacing) {
                Text(inAppPurchase.configuration.title)
                    .font(titleFont)
                    .foregroundStyle(titleColor)

                Text(inAppPurchase.configuration.subtitle)
                    .font(subtitleFont)
                    .foregroundStyle(subtitleColor)
            }
            .minimumScaleFactor(0.6)

            #if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
            Spacer()

            Image(systemName: "chevron.forward")
                .foregroundStyle(subtitleColor)
                .font(subtitleFont)
            #endif
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    private var purchaseSpacing: CGFloat {
        #if os(watchOS)
        return 0
        #else
        return 4
        #endif
    }

    private var titleFont: Font {
        #if os(tvOS) || os(watchOS)
        return Font.headline.bold()
        #elseif os(visionOS)
        return Font.title3
        #else
        return Font.title3.bold()
        #endif
    }

    private var titleColor: Color {
        #if os(macOS) || os(tvOS)
        return Color.primary
        #else
        return Color.white
        #endif
    }

    private var subtitleFont: Font {
        #if os(tvOS)
        return Font.subheadline
        #elseif os(watchOS)
        return Font.footnote
        #else
        return Font.subheadline.bold()
        #endif
    }

    private var subtitleColor: Color {
        #if os(macOS) || os(tvOS)
        return Color.secondary
        #else
        return Color.white.opacity(0.7)
        #endif
    }

    private var purchaseBackground: some View {
        #if os(visionOS)
        ZStack {
            Rectangle()
                .fill(.thickMaterial)

            Rectangle()
                .fill(inAppPurchase.configuration.tintColor.gradient.opacity(0.7))
        }
        #else
        Rectangle()
            .fill(inAppPurchase.configuration.tintColor.gradient)
        #endif
    }
}

#Preview {
    let inAppPurchase = InAppPurchaseKit.preview

    NavigationStack {
        Form {
            InAppPurchaseSettingsRow()
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
        .navigationTitle("Settings")
        .environment(inAppPurchase)
    }
}

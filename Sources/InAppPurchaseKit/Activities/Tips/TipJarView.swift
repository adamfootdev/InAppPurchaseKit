//
//  TipJarView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 24/09/2024.
//

import SwiftUI

#if canImport(HapticsKit)
import HapticsKit
#endif

@available(iOS 17.0, macOS 14.4, tvOS 17.0, watchOS 10.0, *)
public struct TipJarView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let embedInNavigationStack: Bool
    @ViewBuilder private let doneButton: (() -> Content)?
    private let doneButtonPlacement: ToolbarItemPlacement

    @State private var showingPurchasedMessage: Bool = false

    #if os(watchOS)
    public init(
        embedInNavigationStack: Bool = true,
        doneButtonPlacement: ToolbarItemPlacement = .cancellationAction,
        doneButton: (() -> Content)? = nil
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.doneButton = doneButton
        self.doneButtonPlacement = doneButtonPlacement
    }

    #else
    public init(
        embedInNavigationStack: Bool = true,
        doneButtonPlacement: ToolbarItemPlacement = .confirmationAction,
        doneButton: (() -> Content)? = nil
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.doneButton = doneButton
        self.doneButtonPlacement = doneButtonPlacement
    }
    #endif

    public var body: some View {
        Group {
            if embedInNavigationStack {
                NavigationStack {
                    embeddedTipJarView
                }
            } else {
                tipJarView
            }
        }
        .environment(inAppPurchase)
    }

    @ViewBuilder
    private var embeddedTipJarView: some View {
        #if os(macOS)
        tipJarView
            .frame(width: 650, height: 500)
        #else
        tipJarView
        #endif
    }

    private var tipJarView: some View {
        Form {
            Section {
                VStack(spacing: headerSpacing) {
                    AppIconView(configuration: inAppPurchase.configuration)

                    Text("Thank you for using \(inAppPurchase.configuration.appName)! If youʼre enjoying the app, please consider supporting it with a tip. Anything you can spare helps me to continue building this and other indie apps!", bundle: .module)
                        #if os(tvOS)
                        .font(.caption)
                        .padding(.horizontal, 200)
                        #elseif os(watchOS)
                        .font(.footnote)
                        #else
                        .font(.callout)
                        #endif
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                #if os(tvOS)
                .padding(.bottom, 32)
                #endif
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 8, bottom: 0, trailing: 8))
            }

            Section {
                ForEach(
                    Array(inAppPurchase.configuration.sortedTipJarTiers.enumerated()),
                    id: \.0
                ) { index, tier in
                    TipJarTierButton(
                        tier,
                        imageScale: 1 - (
                            CGFloat(inAppPurchase.configuration.sortedTipJarTiers.count - index) * 0.1
                        )
                    )
                }
            }

            Section {
                #if os(macOS)
                LabeledContent(String(localized: "Terms of Use", bundle: .module)) {
                    TermsPrivacyButton(
                        String(localized: "View Terms of Use…", bundle: .module),
                        url: inAppPurchase.configuration.termsOfUseURL
                    )
                }

                LabeledContent(String(localized: "Privacy Policy", bundle: .module)) {
                    TermsPrivacyButton(
                        String(localized: "View Privacy Policy…", bundle: .module),
                        url: inAppPurchase.configuration.termsOfUseURL
                    )
                }

                #elseif os(tvOS)
                VStack(spacing: 12) {
                    TermsPrivacyButton(
                        String(localized: "Terms of Use", bundle: .module),
                        url: inAppPurchase.configuration.termsOfUseURL
                    )

                    TermsPrivacyButton(
                        String(localized: "Privacy Policy", bundle: .module),
                        url: inAppPurchase.configuration.privacyPolicyURL
                    )

                    Text("Please note that these purchases do not unlock additional features.", bundle: .module)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 32)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 8, bottom: 0, trailing: 8))

                #else
                TermsPrivacyButton(
                    String(localized: "Terms of Use", bundle: .module),
                    url: inAppPurchase.configuration.termsOfUseURL
                )

                TermsPrivacyButton(
                    String(localized: "Privacy Policy", bundle: .module),
                    url: inAppPurchase.configuration.privacyPolicyURL
                )
                #endif
            } footer: {
                #if !os(tvOS)
                Text("Please note that these purchases do not unlock additional features.", bundle: .module)
                    #if os(macOS)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    #endif
                #endif
            }
        }
        .navigationTitle(String(localized: "Tip Jar", bundle: .module))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        #elseif os(macOS)
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 500)
        #endif
        .toolbar {
            #if os(iOS) || os(macOS) || os(visionOS) || os(watchOS)
            if embedInNavigationStack || doneButton != nil {
                doneToolbarItem
            }
            #endif
        }
        .alert(String(localized: "Thank You", bundle: .module), isPresented: $showingPurchasedMessage) {
            Button(String(localized: "Continue", bundle: .module), role: .cancel) {}
        } message: {
            Text("Thank you for the tip – it means a lot!", bundle: .module)
        }
        .onChange(of: inAppPurchase.transactionState) { _, transactionState in
            Task {
                await transactionStateUpdated(to: transactionState)
            }
        }
    }

    private var headerSpacing: CGFloat {
        #if os(tvOS)
        return 40
        #else
        return 20
        #endif
    }


    // MARK: - Update

    private func transactionStateUpdated(to transactionState: TransactionState) async {
        switch transactionState {
        case .purchased(let type):
            switch type {
            case .tipJar:
                break
            default:
                return
            }
        default:
            return
        }

        #if canImport(HapticsKit)
        if inAppPurchase.configuration.enableHapticFeedback {
            #if os(iOS)
            HapticsKit.performNotification(.success)
            #elseif os(watchOS)
            HapticsKit.perform(.success)
            #endif
        }
        #endif

        try? await Task.sleep(for: .seconds(0.5))

        showingPurchasedMessage = true
    }


    // MARK: - Toolbar

    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: doneButtonPlacement) {
            if let doneButton {
                doneButton()
            } else {
                Group {
                    #if os(iOS)
                    DismissButton {
                        dismiss()
                    }
                    #else
                    Button {
                        dismiss()
                    } label: {
                        #if os(visionOS) || os(watchOS)
                        Label {
                            Text("Done", bundle: .module)
                        } icon: {
                            Image(systemName: "xmark")
                        }
                        #else
                        Text("Done", bundle: .module)
                        #endif
                    }
                    #if os(visionOS)
                    .buttonBorderShape(.circle)
                    #endif
                    #endif
                }
                .background {
                    #if os(iOS) || os(macOS) || os(visionOS)
                    Button {
                        dismiss()
                    } label: {
                        Text("Close", bundle: .module)
                    }
                    .hidden()
                    .keyboardShortcut(.cancelAction)
                    #endif
                }
            }
        }
    }
}

#if os(watchOS)
@available(watchOS 10.0, *)
extension TipJarView where Content == EmptyView {
    public init(
        embedInNavigationStack: Bool = true,
        doneButtonPlacement: ToolbarItemPlacement = .cancellationAction
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.doneButton = nil
        self.doneButtonPlacement = doneButtonPlacement
    }
}

#else
@available(iOS 17.0, macOS 14.4, tvOS 17.0, *)
extension TipJarView where Content == EmptyView {
    public init(
        embedInNavigationStack: Bool = true,
        doneButtonPlacement: ToolbarItemPlacement = .confirmationAction
    ) {
        self.embedInNavigationStack = embedInNavigationStack
        self.doneButton = nil
        self.doneButtonPlacement = doneButtonPlacement
    }
}
#endif

#Preview {
    if #available(iOS 17.0, macOS 14.4, tvOS 17.0, watchOS 10.0, *) {
        let inAppPurchase = InAppPurchaseKit.configure(with: .preview)

        TipJarView()
            .environment(inAppPurchase)
    }
}

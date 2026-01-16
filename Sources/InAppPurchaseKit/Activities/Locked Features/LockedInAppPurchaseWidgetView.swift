//
//  LockedInAppPurchaseWidgetView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 26/02/2024.
//

#if canImport(WidgetKit)
import SwiftUI
import WidgetKit

@available(visionOS 26.0, *)
public struct LockedInAppPurchaseWidgetView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.widgetFamily) private var widgetFamily
    
    /// The `InAppPurchaseKitConfiguration` to use.
    private let configuration: InAppPurchaseKitConfiguration
    
    /// The `URL` to open when the widget is selected.
    private let url: URL
    
    /// An optional `Color` to use for tinting the view.
    private let tint: Color?

    /// Creates a new `LockedInAppPurchaseWidgetView`.
    /// - Parameters:
    ///   - configuration: The `InAppPurchaseKitConfiguration` to use.
    ///   - url: The `URL` to open when the widget is selected.
    ///   - tint: An optional `Color` to use for tinting the view. Defaults to `nil`.
    public init(
        configuration: InAppPurchaseKitConfiguration,
        learnMoreURL url: URL,
        tint: Color? = nil
    ) {
        self.configuration = configuration
        self.url = url
        self.tint = tint
    }

    public var body: some View {
        switch widgetFamily {
        #if !os(visionOS)
        case .accessoryCircular:
            Image(systemName: "lock.fill")
                .font(.title)

        case .accessoryInline:
            Label(
                "\(configuration.title) Required",
                systemImage: "lock.fill"
            )

        case .accessoryRectangular:
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .imageScale(.large)

                Text("\(configuration.title) Required")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote.bold())
            }
        #endif

        case .accessoryCorner:
            Image(systemName: "lock.fill")
                .font(.title)

        default:
            VStack(spacing: 16) {
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundStyle(Color.secondary)

                    Text("\(configuration.title) Required")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.footnote.bold())
                }

                Button {
                    openURL(url)
                } label: {
                    Text("Learn More")
                        #if os(iOS)
                        .font(.footnote.bold())
                        #endif
                        .padding(.horizontal, 4)
                }
                .buttonStyle(.bordered)
                #if os(iOS)
                .buttonBorderShape(.capsule)
                #endif
                .controlSize(.small)
                .tint(tint ?? configuration.tintColor)
                .widgetAccentable()
            }
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    if #available(visionOS 26.0, *) {
        LockedInAppPurchaseWidgetView(
            configuration: .example,
            learnMoreURL: URL(string: "myapp://?function=subscribe")!,
            tint: nil
        )
        .frame(width: 200, height: 200)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.2))
        }
    }
}
#endif

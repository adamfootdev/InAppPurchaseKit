//
//  LockedInAppPurchaseWidgetView.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 26/02/2024.
//

#if canImport(WidgetKit)
import SwiftUI
import WidgetKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
public struct LockedInAppPurchaseWidgetView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.widgetFamily) private var widgetFamily

    @State private var inAppPurchase: InAppPurchaseKit = .shared

    private let url: URL
    private let tint: Color?

    public init(learnMoreURL url: URL, tint: Color? = nil) {
        self.url = url
        self.tint = tint
    }

    public var body: some View {
        switch widgetFamily {
        case .accessoryCircular, .accessoryCorner:
            Image(systemName: "lock.fill")
                .font(.title)

        case .accessoryInline:
            Label(
                "\(inAppPurchase.configuration.title) Required",
                systemImage: "lock.fill"
            )

        case .accessoryRectangular:
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .imageScale(.large)

                Text("\(inAppPurchase.configuration.title) Required")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote.bold())
            }

        default:
            VStack(spacing: 16) {
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundStyle(Color.secondary)

                    Text("\(inAppPurchase.configuration.title) Required")
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
                .tint(tint ?? Color.accentColor)
            }
            .multilineTextAlignment(.center)
        }
    }
}

//#Preview {
//    if #available(iOS 17.0, *) {
//        return LockedInAppPurchaseWidgetView(
//            learnMoreURL: URL(string: "myapp://?function=subscribe")!,
//            tint: nil
//        )
//    }
//}
#endif

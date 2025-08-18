//
//  PlatformImage.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 18/08/2025.
//

import SwiftUI

#if os(macOS)
extension NSImage: @retroactive @unchecked Sendable {}
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

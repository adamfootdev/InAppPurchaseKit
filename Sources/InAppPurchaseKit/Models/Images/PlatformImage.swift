//
//  PlatformImage.swift
//  InAppPurchaseKit
//
//  Created by Adam Foot on 18/08/2025.
//

import SwiftUI

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

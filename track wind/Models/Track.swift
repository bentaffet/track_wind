//
//  Track.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/8/26.
//


import Foundation
import SwiftUI

struct Track: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let direction: Double
}

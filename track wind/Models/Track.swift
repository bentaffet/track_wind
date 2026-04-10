//
//  Track.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/8/26.
//


import Foundation
import SwiftUI

struct Track: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let direction: Double

    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

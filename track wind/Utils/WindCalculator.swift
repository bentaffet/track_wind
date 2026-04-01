//
//  WindCalculator.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

import Foundation

struct WindCalculator {
    
    static func angleDifference(_ a: Double, _ b: Double) -> Double {
        abs((a - b + 180).truncatingRemainder(dividingBy: 360) - 180)
    }
    
    static func effectiveWind(runDir: Double, windTo: Double, windSpeed: Double) -> (Double, Double) {
        let diff = angleDifference(runDir, windTo)
        let effect = windSpeed * cos(diff * .pi / 180)
        return (effect, diff)
    }
    
    static func windCategory(_ effectMps: Double) -> String {
        switch effectMps {
        case let x where x > 2: return "Strong tailwind"
        case let x where x > 0.5: return "Tailwind"
        case let x where x > 0.1: return "Slight tailwind"
        case let x where x > -0.1: return "Neutral / crosswind"
        case let x where x > -0.5: return "Slight headwind"
        case let x where x > -2: return "Headwind"
        default: return "Strong headwind"
        }
    }
}

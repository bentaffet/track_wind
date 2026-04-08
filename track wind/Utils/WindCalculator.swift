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
    
    static func windCategory(effectKmh: Double, windDir: Double, homeDir: Double) -> String {
        let angle = (windDir - homeDir).truncatingRemainder(dividingBy: 360)
        let normalized = angle > 180 ? angle - 360 : angle  // [-180, 180]

        let absEffect = abs(effectKmh)

        // Strength bucket
        let strength: String
        switch absEffect {
        case 0..<1: strength = "Very light"
        case 1..<5: strength = "Light"
        case 5..<15: strength = "Moderate"
        default: strength = "Strong"
        }

        // Direction type
        let direction: String
        switch normalized {
        case -30...30:
            direction = "headwind"
        case 150...180, -180 ... -150:
            direction = "tailwind"
        case 30..<150:
            direction = "crosswind from right"
        case -150..<(-30):
            direction = "crosswind from left"
        default:
            direction = "variable"
        }

        return "\(strength) \(direction)"
    }
}

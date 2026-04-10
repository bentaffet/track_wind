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
        
        let rawAngle = (windDir - homeDir)
            .truncatingRemainder(dividingBy: 360)
        
        let normalized = rawAngle < -180 ? rawAngle + 360 :
        rawAngle > 180  ? rawAngle - 360 :
        rawAngle
        
        let absEffect = abs(effectKmh)
        
        // Strength
        let strength: String
        switch absEffect {
        case 0..<1: strength = "Very light"
        case 1..<5: strength = "Light"
        case 5..<15: strength = "Moderate"
        default: strength = "Strong"
        }
        
        // Direction
        let direction: String
        switch normalized {
        case -30...30:
            direction = "headwind"
        case 150...180, -180...(-150):
            direction = "tailwind"
        case 30..<150:
            direction = "crosswind from right"
        case -150..<(-30):
            direction = "crosswind from left"
        default:
            direction = "variable" // should never hit
        }
        
        return "\(strength) \(direction)"
    }
}

//
//  WindSummaryCard.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

import SwiftUI

func stat(label: String, value: String) -> some View {
    VStack {
        Text(value)
            .font(.title3)
            .bold()
        Text(label)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

func windSummaryCard(speed: Double, direction: Double, gust: Double, unit: WindUnit) -> some View {
    
    return VStack(alignment: .leading, spacing: 12) {
        
        Text("Wind")
            .font(.headline)
        
        HStack {
            stat(label: "Speed", value: "\(String(format: "%.1f", speed)) \(unit.rawValue)")
            
            Spacer()

            stat(label: "Direction", value: "\(Int(direction))°")
            
            Spacer()
            
            stat(label: "Gust", value: "\(String(format: "%.1f", gust)) \(unit.rawValue)")
        }
    }
    .padding()
    .background(.ultraThinMaterial)
    .cornerRadius(16)
}

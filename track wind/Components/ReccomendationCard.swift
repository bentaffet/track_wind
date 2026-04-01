//
//  ReccomendationCard.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

import SwiftUI

extension RecommendationCard {
    
    func color(for category: String) -> Color {
        switch category {
        case let x where x.lowercased().contains("tailwind"):
            return .green
        case let x where x.lowercased().contains("headwind"):
            return .red
        default:
            return .black
        }
    }
}

extension RecommendationCard {
    
    func straightView(title: String, mps: Double, category: String) -> some View {
        let converted = unit.convert(fromKmh: mps)

        return VStack(spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(String(format: "%.1f", converted)) \(unit.rawValue)")
                .font(.title2)
                .bold()
                .foregroundColor(color(for: category))
            
            Text(category)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
    }
}



struct RecommendationCard: View {
    let homeMps: Double
    let backMps: Double
    let homeGustMps : Double
    let backGustMps : Double
    let homeCategory: String
    let backCategory: String
    let unit: WindUnit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Straights")
                .font(.headline)
            
            HStack(spacing: 20) {
                straightView(
                    title: "Home Straight",
                    mps: homeMps,
                    category: homeCategory
                )
                
                straightView(
                    title: "Back Straight",
                    mps: backMps,
                    category: backCategory
                )
            }
            
            HStack(spacing: 20) {
                straightView(
                    title: "Home Gust",
                    mps: homeGustMps,
                    category: homeCategory
                )
                
                straightView(
                    title: "Back Gust",
                    mps: homeGustMps,
                    category: backCategory
                )
            }
            
           
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

//
//  RecommendationCard.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/10/26.
//
// Second implementation

import SwiftUI

struct RecommendationCard2: View {

    let homeMps: Double
    let backMps: Double
    let homeGustMps: Double
    let backGustMps: Double

    let homeCategory: String
    let backCategory: String

    let unit: WindUnit

    // MARK: - Color

    func color(for category: String) -> Color {
        let lower = category.lowercased()

        if lower.contains("headwind") {
            return .red.opacity(0.75)
        } else if lower.contains("tailwind") {
            return .green.opacity(0.75)
        } else if lower.contains("crosswind") {
            return .blue.opacity(0.55)
        } else {
            return .gray.opacity(0.25)
        }
    }

    // MARK: - Cell View

    @ViewBuilder
    func straightCard(
        title: String,
        wind: Double,
        gust: Double,
        category: String
    ) -> some View {

        let windValue = unit.convert(fromKmh: wind)
        let gustValue = unit.convert(fromKmh: gust)

        VStack(spacing: 10) {

            // Title
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Main number (MOST IMPORTANT)
            Text("\(String(format: "%.1f", windValue)) \(unit.rawValue)")
                .font(.title)
                .bold()

            // Category (colored)
            Text(category.capitalized)
                .font(.caption)
                .foregroundStyle(color(for: category))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color(for: category).opacity(0.15))
                .clipShape(Capsule())

            // Gust (secondary info)
            Text("Gust \(String(format: "%.1f", gustValue))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 16) {
                

                straightCard(
                    title: "Home Straight",
                    wind: homeMps,
                    gust: homeGustMps,
                    category: homeCategory
                )
                
                straightCard(
                    title: "Back Straight",
                    wind: backMps,
                    gust: backGustMps,
                    category: backCategory
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

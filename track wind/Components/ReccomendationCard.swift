//
//  ReccomendationCard.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

import SwiftUI

struct RecommendationCard: View {

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
    func straightView(
        title: String,
        valueMps: Double,
        category: String
    ) -> some View {

        let converted = unit.convert(fromKmh: valueMps)

        VStack(spacing: 6) {

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(String(format: "%.1f", converted)) \(unit.rawValue)")
                .font(.title3)
                .bold()
                .foregroundStyle(color(for: category))

            Text(category)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(Color.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Straights")
                .font(.headline)

            HStack(spacing: 16) {
                straightView(
                    title: "Home Straight",
                    valueMps: homeMps,
                    category: homeCategory
                )

                straightView(
                    title: "Back Straight",
                    valueMps: backMps,
                    category: backCategory
                )
            }

            HStack(spacing: 16) {
                straightView(
                    title: "Home Gust",
                    valueMps: homeGustMps,
                    category: homeCategory
                )

                straightView(
                    title: "Back Gust",
                    valueMps: backGustMps,
                    category: backCategory
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

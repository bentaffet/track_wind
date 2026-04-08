//
//  HourlyForecastView.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/4/26.
//

import SwiftUI

// MARK: - Model

struct HourRowModel: Identifiable {
    let id: Int
    let date: Date
    let windSpeed: Double
    let windTo: Double

    let home: Double
    let back: Double

    let homeCategory: String
    let backCategory: String
}

// MARK: - Row View

struct HourRowView: View {
    let model: HourRowModel
    let unit: WindUnit

    var body: some View {
        HStack(spacing: 0) {

            cell(TimeUtils.shortFormatter.string(from: model.date))

            cell(String(format: "%.1f", unit.convert(fromKmh: model.windSpeed)))

            cell(String(format: "%.1f", unit.convert(fromKmh: model.home)))
                .background(color(for: model.homeCategory))

            cell(String(format: "%.1f", unit.convert(fromKmh: model.back)))
                .background(color(for: model.backCategory))
        }
    }

    private func color(for category: String) -> Color {
        let lower = category.lowercased()

        if lower.contains("tailwind") {
            return .green.opacity(0.3)
        } else if lower.contains("headwind") {
            return .red.opacity(0.3)
        } else if lower.contains("crosswind") {
            return .blue.opacity(0.2)
        } else {
            return .clear
        }
    }
}

// MARK: - UI Helpers

func headerCell(_ text: String) -> some View {
    Text(text)
        .font(.headline)
        .frame(width: 90, height: 40)
        .background(Color.gray.opacity(0.2))
}

func cell(_ text: String) -> some View {
    Text(text)
        .frame(width: 90, height: 40)
        .background(Color.white.opacity(0.8))
}

// MARK: - Main View

struct HourlyForecastView: View {

    let weatherData: WeatherResponse
    let dates: [Date]
    let homeDir: Double
    @Binding var unit: WindUnit

    // Group indices by day
    private var dayToHours: [Date: [Int]] {
        Dictionary(grouping: dates.indices, by: {
            Calendar.current.startOfDay(for: dates[$0])
        })
    }

    private var sortedDays: [Date] {
        dayToHours.keys.sorted()
    }

    // MARK: - Row builder

    private func makeRow(for i: Int) -> HourRowModel {

        let date = dates[i]
        let windSpeed = weatherData.hourly.wind_speed_10m[i]
        let windDirFrom = weatherData.hourly.wind_direction_10m[i]

        let windTo = (windDirFrom + 180)
            .truncatingRemainder(dividingBy: 360)

        let homeEffect = WindCalculator.effectiveWind(
            runDir: homeDir,
            windTo: windTo,
            windSpeed: windSpeed
        ).0

        let backEffect = WindCalculator.effectiveWind(
            runDir: homeDir + 180,
            windTo: windTo,
            windSpeed: windSpeed
        ).0

        let homeCategory = WindCalculator.windCategory(
            effectKmh: homeEffect,
            windDir: windTo,
            homeDir: homeDir
        )

        let backCategory = WindCalculator.windCategory(
            effectKmh: backEffect,
            windDir: windTo,
            homeDir: homeDir + 180
        )

        return HourRowModel(
            id: i,
            date: date,
            windSpeed: windSpeed,
            windTo: windTo,
            home: homeEffect,
            back: backEffect,
            homeCategory: homeCategory,
            backCategory: backCategory
        )
    }

    // MARK: - Body

    var body: some View {
        VStack {

            ScrollView([.horizontal, .vertical]) {

                VStack(spacing: 0) {

                    // Header
                    HStack {
                        headerCell("Time")
                        headerCell("Wind")
                        headerCell("Home")
                        headerCell("Back")
                    }

                    ForEach(sortedDays, id: \.self) { day in

                        VStack(spacing: 0) {

                            HStack {
                                Text(TimeUtils.dayFormatter.string(from: day))
                                    .font(.headline)
                                    .padding(.vertical, 4)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))

                            let rows = (dayToHours[day] ?? []).map(makeRow)

                            ForEach(rows) { row in
                                HourRowView(
                                    model: row,
                                    unit: unit
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Hourly Forecast")
            .navigationBarTitleDisplayMode(.inline)
            .padding()

            Picker("Units", selection: $unit) {
                ForEach(WindUnit.allCases, id: \.self) { u in
                    Text(u.rawValue).tag(u)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

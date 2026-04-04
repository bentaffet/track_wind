//
//  HourlyForecastView.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/4/26.
//

import SwiftUI

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

func color(for value: Double) -> Color {
    let category = WindCalculator.windCategory(value)
    
    if category.contains("tailwind") {
        return Color.green.opacity(0.3)
    } else if category.contains("headwind") {
        return Color.red.opacity(0.3)
    } else {
        return Color.clear
    }
}

struct HourlyForecastView: View {
    
    let weatherData: WeatherResponse       // full weather response
    let dates: [Date]                      // precomputed Date objects (future times)
    let homeDir: Double
    @Binding var unit: WindUnit
    
    // Group dates by day for display
    private var dayToHours: [Date: [Int]] {
        Dictionary(grouping: dates.indices, by: { Calendar.current.startOfDay(for: dates[$0]) })
    }
    
    private var sortedDays: [Date] {
        dayToHours.keys.sorted()
    }
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 0) {
                
                // Header row
                HStack {
                    headerCell("Time")
                    headerCell("Wind")
                    headerCell("Home")
                    headerCell("Back")
                }
                
                ForEach(sortedDays, id: \.self) { day in
                    // Day header
                    HStack {
                        Text(TimeUtils.dayFormatter.string(from: day))
                            .font(.headline)
                            .padding(.vertical, 4)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    
                    // Hours for this day
                    ForEach(dayToHours[day] ?? [], id: \.self) { i in
                        let date = dates[i]
                        let windSpeed = weatherData.hourly.wind_speed_10m[i]
                        let windDirFrom = weatherData.hourly.wind_direction_10m[i]
                        
                        let windTo = (windDirFrom + 180).truncatingRemainder(dividingBy: 360)
                        
                        let home = WindCalculator.effectiveWind(runDir: homeDir, windTo: windTo, windSpeed: windSpeed).0
                        let back = WindCalculator.effectiveWind(runDir: homeDir + 180, windTo: windTo, windSpeed: windSpeed).0
                        
                        HStack(spacing: 0) {
                            cell(TimeUtils.shortFormatter.string(from: date))
                            cell(String(format: "%.1f", unit.convert(fromKmh: windSpeed)))
                            cell(String(format: "%.1f", unit.convert(fromKmh: home)))
                                .background(color(for: home))
                            cell(String(format: "%.1f", unit.convert(fromKmh: back)))
                                .background(color(for: back))
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

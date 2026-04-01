//
//  WeatherResponse.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

nonisolated struct WeatherResponse: Codable {
    let hourly: HourlyData
}

struct HourlyData: Codable {
    let time: [String]
    let wind_direction_10m: [Double]
    let wind_speed_10m: [Double]
    let wind_gusts_10m: [Double]
}

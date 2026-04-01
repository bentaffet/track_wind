//
//  WeatherService.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

import Foundation

class WeatherService {
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (WeatherResponse?) -> Void) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&hourly=wind_direction_10m,wind_speed_10m,wind_gusts_10m&forecast_days=7"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            // Log raw JSON response as a string
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw API response:\n\(jsonString)")
            }
            
            do {
                let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
                print("Decoded WeatherResponse: \(decoded)")
                completion(decoded)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

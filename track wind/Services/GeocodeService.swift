//
//  GeocodeService.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/5/26.
//

import Foundation
import CoreLocation

struct GeocodeResponse: Codable {
    struct Result: Codable {
        struct Geometry: Codable {
            struct Location: Codable {
                let lat: Double
                let lng: Double
            }
            let location: Location
        }
        let geometry: Geometry
        let formatted_address: String
    }
    let results: [Result]
    let status: String
}

class GeocodingService {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func geocode(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        guard let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(encodedAddress)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(GeocodeResponse.self, from: data)
                if let firstResult = decoded.results.first {
                    let coord = firstResult.geometry.location
                    completion(CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lng))
                } else {
                    completion(nil)
                }
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

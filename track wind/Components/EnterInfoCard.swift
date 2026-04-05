//
//  EnterInfoCard.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/5/26.
//

import SwiftUI
import CoreLocation

struct EnterInfoCard: View {
    @Binding var latitude: String
    @Binding var longitude: String
    @Binding var homeDir: String
    @Binding var showMap: Bool

    // MARK: - New state
    @State private var inputMode: InputMode = .map
    @State private var locationName: String = ""
    @State private var isLoading: Bool = false
    
    private let geocodeService = GeocodingService(apiKey: Secrets.geocodingAPIKey)
    
    enum InputMode: String, CaseIterable, Identifiable {
        case map = "Map"
        case location = "Search"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            TrackMatcher(
                latitude: $latitude,
                longitude: $longitude,
                homeDir: $homeDir
            )
            
            
            // Mode switcher
            Picker("Input Mode", selection: $inputMode) {
                ForEach(InputMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 5)
            
            VStack(alignment: .leading, spacing: 12) {
                
                switch inputMode {
                case .map:
                    Button(action: { showMap = true }) {
                        HStack {
                            Image(systemName: "map")
                            Text("Pick Location on Map")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(10)
                    }
                    
                case .location:
                    TextField("Enter location name", text: $locationName)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: geocodeLocation) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                            Text("Set Location")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(10)
                    }
                    .disabled(locationName.isEmpty || isLoading)
                }
                
                HStack(spacing: 10) {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Home straight direction
                TextField("Home Straight Direction (°)", text: $homeDir)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Geocode
    private func geocodeLocation() {
        isLoading = true
        geocodeService.geocode(address: locationName) { coord in
            DispatchQueue.main.async {
                isLoading = false
                if let coord = coord {
                    latitude = "\(coord.latitude)"
                    longitude = "\(coord.longitude)"
                } else {
                    print("Failed to geocode address")
                }
            }
        }
    }
}

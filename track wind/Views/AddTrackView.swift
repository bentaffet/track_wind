//
//  AddTrackView.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/8/26.
//

//
//  AddTrackView.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/8/26.
//

import SwiftUI
import CoreLocation

struct AddTrackView: View {

    @Environment(\.dismiss) private var dismiss
    @Binding var tracks: [Track]
    @Binding var showMap: Bool

    // MARK: - Track Info
    @State private var name = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var homeDir = ""
    
    @State private var inputMode: InputMode = .map
    @State private var locationName: String = ""
    @State private var isLoading: Bool = false
    
    private let geocodeService = GeocodingService(apiKey: Secrets.geocodingAPIKey)
    
    enum InputMode: String, CaseIterable, Identifiable {
        case map = "Map"
        case location = "Search"
        case manual = "Manual"
        var id: String { self.rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Mode Picker
                Picker("Input Mode", selection: $inputMode) {
                    ForEach(InputMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 5)

                // MARK: - Input Fields
                VStack(alignment: .leading, spacing: 12) {

                    TextField("New Track Name", text: $name)
                        .textFieldStyle(.roundedBorder)

                    switch inputMode {
                    case .map, .location:
                        if !latitude.isEmpty && !longitude.isEmpty {
                            // Location is set – show indicator + reset button
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Location set")
                                        .foregroundColor(.green)
                                        .fontWeight(.medium)
                                }
                                Spacer()
                                Button(action: {
                                    latitude = ""
                                    longitude = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(8)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(8)
                        } else {
                            // Location not set – show map/search buttons
                            if inputMode == .map {
                                mapButton()
                            } else {
                                locationSearchField()
                            }
                        }

                        homeDirectionField() // always show home direction

                    case .manual:
                        manualLatLonFields()
                        homeDirectionField()
                    }

                    addButton()
                }
                .padding(.bottom, 20) // gives some breathing room at the bottom
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .top) // naturally aligns content to top
        }
        .background(.ultraThinMaterial)   // just the material

        .navigationTitle("Add Track")
        .fullScreenCover(isPresented: $showMap) {
            MapPickerView(
                initialCoordinate: initialCoordinate(),
                onSelect: { coord in
                    latitude = "\(coord.latitude)"
                    longitude = "\(coord.longitude)"
                }
            )
        }
    }

    // MARK: - Subviews
    private func mapButton() -> some View {
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
    }

    private func homeDirectionField() -> some View {
        TextField("Home Straight Direction (°)", text: $homeDir)
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
    }

    private func locationSearchField() -> some View {
        VStack(spacing: 8) {
            TextField("Enter location name", text: $locationName)
                .textFieldStyle(.roundedBorder)
            
            Button(action: geocodeLocation) {
                HStack {
                    if isLoading { ProgressView().progressViewStyle(.circular) }
                    Text("Set Location").fontWeight(.medium)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.15))
                .foregroundColor(.green)
                .cornerRadius(10)
            }
            .disabled(locationName.isEmpty || isLoading)
        }
    }

    private func manualLatLonFields() -> some View {
        HStack(spacing: 10) {
            TextField("Latitude", text: $latitude)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
            TextField("Longitude", text: $longitude)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func addButton() -> some View {
        Button(action: { addTrack() }) {
            Text("Add Track")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? Color.blue : Color.gray)
                .cornerRadius(12)
                .shadow(radius: 2)
        }
        .disabled(!isValid)
    }

    // MARK: - Helpers
    private var isValid: Bool {
        !name.isEmpty && Double(latitude) != nil && Double(longitude) != nil && Double(homeDir) != nil
    }

    private func addTrack() {
        guard let lat = Double(latitude),
              let lon = Double(longitude),
              let dir = Double(homeDir) else { return }
        
        tracks.append(Track(name: name, latitude: lat, longitude: lon, direction: dir))
        dismiss()
    }

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

    private func initialCoordinate() -> CLLocationCoordinate2D? {
        if let lat = Double(latitude), let lon = Double(longitude) {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
}

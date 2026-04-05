//
//  MapPickerView.swift
//  track wind
//

import SwiftUI
import MapKit
import CoreLocation

struct MapPickerView: View {
    @Environment(\.dismiss) var dismiss

    let onSelect: (CLLocationCoordinate2D) -> Void
    var initialCoordinate: CLLocationCoordinate2D? // Coordinates already set
    private let defaultCoordinate = CLLocationCoordinate2D(latitude: 41.55, longitude: -72.66)

    @State private var region: MKCoordinateRegion
    @State private var locationManager = CLLocationManager()
    
    init(initialCoordinate: CLLocationCoordinate2D? = nil, onSelect: @escaping (CLLocationCoordinate2D) -> Void) {
        self.initialCoordinate = initialCoordinate
        self.onSelect = onSelect
        // Temporarily set region; will update in onAppear
        _region = State(initialValue: MKCoordinateRegion(
            center: initialCoordinate ?? CLLocationCoordinate2D(latitude: 41.55, longitude: -72.66),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all)
                .ignoresSafeArea()

            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)
                .shadow(radius: 3)
            
            VStack {
                HStack {
                    Spacer()
                    Button("Cancel") {
                        dismiss()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding()
                }
                Spacer()
                Button("Use This Location") {
                    onSelect(region.center)
                    dismiss()
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.bottom)
            }
        }
        .onAppear {
            // If initial coordinates exist, use them
            if let coord = initialCoordinate {
                region.center = coord
            } else {
                // Otherwise, request current location
                locationManager.requestWhenInUseAuthorization()
                if let current = locationManager.location?.coordinate {
                    region.center = current
                } else {
                    // fallback: defaultCoordinate already set
                    region.center = defaultCoordinate
                }
            }
        }
    }
}

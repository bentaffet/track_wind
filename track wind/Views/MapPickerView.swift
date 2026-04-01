//
//  MapPickerView.swift
//  track wind
//

import SwiftUI
import MapKit

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

import SwiftUI
import MapKit

struct MapPickerView: View {
    @Environment(\.dismiss) var dismiss

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.55, longitude: -72.66),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    let onSelect: (CLLocationCoordinate2D) -> Void

    var body: some View {
        ZStack {
            // Map view
            Map(coordinateRegion: $region, interactionModes: .all)
                .ignoresSafeArea()

            // Pin always at center
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)
                .shadow(radius: 3)
            
            VStack {
                HStack {
                    Spacer()
                    // Cancel button
                    Button("Cancel") {
                        dismiss()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding()
                }
                Spacer()
                // Confirm button
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
    }
}

// Helper to convert tap location to coordinate
extension GeometryProxy {
    func convert(valueLocation: CGPoint, in size: CGSize, region: MKCoordinateRegion) -> CLLocationCoordinate2D {
        let xPercent = valueLocation.x / size.width
        let yPercent = valueLocation.y / size.height
        
        let lonDelta = region.span.longitudeDelta
        let latDelta = region.span.latitudeDelta
        
        let lon = region.center.longitude + (xPercent - 0.5) * lonDelta
        let lat = region.center.latitude - (yPercent - 0.5) * latDelta
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

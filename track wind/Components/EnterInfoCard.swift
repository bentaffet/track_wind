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
    @Binding var tracks: [Track]

    // MARK: - New state
    @State private var locationName: String = ""
    @State private var isLoading: Bool = false
    
    
    
    var body: some View {
        VStack(spacing: 16) {
            
            TrackMatcher(
                latitude: $latitude,
                longitude: $longitude,
                homeDir: $homeDir,
                tracks: $tracks
            )
            
            
            
//            VStack(alignment: .leading, spacing: 12) {
//                
//
//                
//                HStack(spacing: 10) {
//                    TextField("Latitude", text: $latitude)
//                        .keyboardType(.decimalPad)
//                        .textFieldStyle(.roundedBorder)
//                    
//                    TextField("Longitude", text: $longitude)
//                        .keyboardType(.decimalPad)
//                        .textFieldStyle(.roundedBorder)
//                }
//                
//                TextField("Home Straight Direction (°)", text: $homeDir)
//                    .keyboardType(.decimalPad)
//                    .textFieldStyle(.roundedBorder)
//            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    

    
}

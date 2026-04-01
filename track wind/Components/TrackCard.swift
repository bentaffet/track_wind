//
//  TrackCard.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

import SwiftUI

struct TrackCard: View {
    let homeDir: Double
    let windDirection: Double?   // optional because currentWind might be nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Track Visualization")
                .font(.headline)
            
            TrackView(
                homeDirection: homeDir,
                windTo: ((windDirection ?? 0) + 180)
            )
            .frame(height: 260)
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

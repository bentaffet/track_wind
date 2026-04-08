//
//  TrackMatcher.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/3/26.
//

//
//  TrackMatcher.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/3/26.
//

import SwiftUI






// MARK: - Main Track Matcher View

struct TrackMatcher: View {

    @Binding var latitude: String
    @Binding var longitude: String
    @Binding var homeDir: String

    @Binding var tracks: [Track]

    @State private var showPicker = false
    @State private var selectedTrackName: String = ""

    var body: some View {
        VStack(spacing: 12) {

            Button {
                showPicker = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Track")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(selectedTrackName.isEmpty ? "Select a track" : selectedTrackName)
                            .foregroundColor(selectedTrackName.isEmpty ? .secondary : .primary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showPicker) {
            TrackPickerSheet(tracks: tracks) { track in
                select(track)
            }
        }
    }

    private func select(_ track: Track) {
        latitude = "\(track.latitude)"
        longitude = "\(track.longitude)"
        homeDir = "\(track.direction)"
        selectedTrackName = track.name
    }
}

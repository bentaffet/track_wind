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

// MARK: - Track Model
struct Track: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let direction: Double
}

// MARK: - Main Track Matcher View
struct TrackMatcher: View {
    @Binding var latitude: String
    @Binding var longitude: String
    @Binding var homeDir: String

    @State private var showPicker = false
    @State private var selectedTrackName: String = ""

    // Your track database
    let tracks: [Track] = [
        Track(name: "Wesleyan University", latitude: 41.555, longitude: -72.656, direction: 261),
        Track(name: "Amherst College", latitude: 42.368514, longitude: -72.524181, direction: 120),
        Track(name: "Trinity College", latitude: 41.748, longitude: -72.690, direction: 357),
        Track(name: "Connecticut College", latitude: 41.381476, longitude: -72.101230, direction: 166),
        Track(name: "Coast Guard Academy", latitude: 41.375648, longitude: -72.097870, direction: 170)
    ]
    


    var body: some View {
        VStack(spacing: 12) {

            // MARK: - Apple-style picker button
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

    // MARK: - Handle selection
    private func select(_ track: Track) {
        latitude = "\(track.latitude)"
        longitude = "\(track.longitude)"
        homeDir = "\(track.direction)"
        selectedTrackName = track.name
    }
}

// MARK: - Apple-style Search Sheet
struct TrackPickerSheet: View {
    let tracks: [Track]
    var onSelect: (Track) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var filteredTracks: [Track] {
        if searchText.isEmpty { return tracks }
        return tracks.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        NavigationView {
            List(filteredTracks) { track in
                Button {
                    onSelect(track)
                    dismiss() // closes sheet immediately
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(track.name)
                        Text("\(track.latitude), \(track.longitude)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Select Track")
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

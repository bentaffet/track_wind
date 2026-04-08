//
//  TrackPickerSheet.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/8/26.
//

import SwiftUI

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
                    dismiss()
                } label: {
                    VStack(alignment: .leading) {
                        Text(track.name)
                        Text("\(track.latitude), \(track.longitude)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Select Track")
            .searchable(text: $searchText)
        }
    }
}

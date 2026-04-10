//
//  TrackPickerSheet.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/8/26.
//

import SwiftUI

struct TrackPickerSheet: View {
    @Binding var tracks: [Track]       // <-- must be a binding to mutate
    var onSelect: (Track) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var filteredTracks: [Track] {
        if searchText.isEmpty { return tracks }
        return tracks.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredTracks) { track in
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
                .onDelete { offsets in
                    // Delete directly from the original tracks array
                    offsets.forEach { index in
                        let trackToDelete = filteredTracks[index]
                        if let originalIndex = tracks.firstIndex(where: { $0.id == trackToDelete.id }) {
                            tracks.remove(at: originalIndex)
                        }
                    }
                }
            }
            .navigationTitle("Select Track")
            .toolbar { EditButton() }   // swipe-to-delete
            .searchable(text: $searchText)
        }
    }
}

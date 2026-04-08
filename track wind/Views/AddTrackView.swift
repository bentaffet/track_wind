//
//  AddTrackView.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/8/26.
//

import SwiftUI

struct AddTrackView: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var tracks: [Track]

    @State private var name = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var direction = ""

    var body: some View {
        NavigationView {

            Form {

                Section("Track Info") {
                    TextField("Name", text: $name)

                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)

                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)

                    TextField("Direction (°)", text: $direction)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Button("Add Track") {
                        addTrack()
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Add Track")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var isValid: Bool {
        !name.isEmpty &&
        Double(latitude) != nil &&
        Double(longitude) != nil &&
        Double(direction) != nil
    }

    private func addTrack() {
        guard
            let lat = Double(latitude),
            let lon = Double(longitude),
            let dir = Double(direction)
        else { return }

        let newTrack = Track(
            name: name,
            latitude: lat,
            longitude: lon,
            direction: dir
        )

        tracks.append(newTrack)
        dismiss()
    }
}


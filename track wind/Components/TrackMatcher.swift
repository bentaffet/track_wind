//
//  TrackMatcher.swift
//  track wind
//
//  Created by Benjamin Taffet on 4/3/26.
//

import SwiftUI

struct DirectionPicker: View {
    @Binding var homeDir: String

    // Compass directions → degrees
    let directionMap: [String: Int] = [
        "Wesleyan University": 261,
        "Amherst College": 120,
        "Trinity College": 357
    ]

    @State private var searchText: String = ""

    var body: some View {
        HStack {
            // Manual input
            TextField("Home Direction (°)", text: $homeDir)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
            
            // Dropdown Menu for words
            Menu {
                ForEach(directionMap.keys.sorted(), id: \.self) { key in
                    Button(key) {
                        if let degree = directionMap[key] {
                            homeDir = "\(degree)"
                        }
                    }
                }
            } label: {
                Image(systemName: "chevron.down.circle")
                    .font(.title3)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

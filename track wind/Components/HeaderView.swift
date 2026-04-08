//
//  HeaderView.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

import SwiftUI

struct HeaderView: View {

    @Binding var tracks: [Track]

    var body: some View {
        HStack {
            Text("Wind on the Track")
                .font(.largeTitle.bold())

            Spacer()

            NavigationLink {
                AddTrackView(tracks: $tracks)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(.blue.gradient))
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

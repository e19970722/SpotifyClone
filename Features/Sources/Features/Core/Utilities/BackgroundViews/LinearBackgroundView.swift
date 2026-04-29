//
//  LinearBackgroundView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/24.
//

import SwiftUI

struct LinearBackgroundView: View {
    let mainColor: Color
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: mainColor, location: 0.0),
                        Gradient.Stop(color: Color.theme.background, location: 0.5),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

#Preview {
    LinearBackgroundView(mainColor: .purple)
}

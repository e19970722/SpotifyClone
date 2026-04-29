//
//  PlayingProgressView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/20.
//

import AVKit
import SwiftUI

struct PlayingProgressView: View {
    @Binding var progress: Double
    @Binding var lastProgressDrag: Double
    @Binding var isSeeking: Bool

    @GestureState private var isDragging: Bool = false
    
    var canDrag: Bool = false
    var onSeekTo: ((_ progress: Double) -> Void)? = nil
        
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.gray)
                
                Rectangle()
                    .fill(.white)
                    .frame(width: max(geo.size.width * progress, 0))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .leading) {
                if canDrag {
                    circleView(size: geo.size)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black

        PlayingProgressView(progress: .constant(1.0),
                            lastProgressDrag: .constant(0.0),
                            isSeeking: .constant(false),
                            canDrag: true)
            .frame(width: UIScreen.main.bounds.size.width, height: 10)
    }
}

extension PlayingProgressView {
    private func circleView(size: CGSize) -> some View {
        let componentHeight = size.height * 2
        return Circle()
            .fill(.white)
            .frame(width: componentHeight, height: componentHeight)
            /// For Dragging Space
            .frame(width: 50, height: 50)
            .contentShape(Rectangle())
            /// Moving along with gesture progress
            .offset(x: (size.width * progress) - (componentHeight / 2))
            .gesture(
                DragGesture()
                    .updating($isDragging, body: { _, out, _ in
                        out = true
                    })
                    .onChanged({ value in
                        let translationX: CGFloat = value.translation.width
                        let calculatedProgress = (translationX / size.width) + lastProgressDrag
                        progress = max(min(calculatedProgress, 1), 0)
                        
                        isSeeking = true
                    })
                    .onEnded({ value in
                        lastProgressDrag = progress
                        onSeekTo?(progress)
                    })
            )
            .frame(width: componentHeight, height: componentHeight)
    }
}

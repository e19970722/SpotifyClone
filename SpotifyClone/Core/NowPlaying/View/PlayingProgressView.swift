//
//  PlayingProgressView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/20.
//

import SwiftUI

struct PlayingProgressView: View {
    @Binding var progress: Double
    
    @GestureState private var isDragging: Bool = false
    @State private var isSeeking: Bool = false
    @State private var lastProgressDrag: CGFloat = 0
    
    var canDrag: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.gray)
                
                Rectangle()
                    .fill(.white)
                    .frame(width: max(geo.size.width * progress + geo.size.height, 0))
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
    PlayingProgressView(progress: .constant(0.0), canDrag: true)
        .background(.black)
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
            .offset(x: (progress == 1) ? size.width * progress - 16 : size.width * progress)
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isSeeking = false
                        }
                    })
            )
            .frame(width: componentHeight, height: componentHeight)
    }
}

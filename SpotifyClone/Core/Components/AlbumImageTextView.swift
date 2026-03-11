//
//  AlbumImageTextView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/10/2.
//

import SwiftUI

struct AlbumImageTextView: View {
    
    var imageName: String
    var description: String
    
    var body: some View {
        GeometryReader { geo in
            
            let imageWidth = geo.size.width
            VStack(alignment: .center, spacing: 8) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageWidth, height: imageWidth)
                    
                Text(description)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondaryTextColor2)
                    .frame(width: imageWidth, alignment: .leading)
            }
            .frame(width: geo.size.width)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    AlbumImageTextView(imageName: DeveloperPreview.instance.currentSong.albumImageName,
                       description: DeveloperPreview.instance.currentSong.albumName)
    .background(.black)
}

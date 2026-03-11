//
//  HomeSectionView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/10/2.
//

import SwiftUI

struct HomeSectionView: View {
    
    var section: HomeSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(section.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, .design.padding16)
            
            albumsView(fullWidth: UIScreen.main.bounds.size.width)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    if let firstSection = DeveloperPreview.instance.homeSections.first {
        HomeSectionView(section: firstSection)
            .background(.black)
            .frame(width: UIScreen.main.bounds.size.width,
                   height: UIScreen.main.bounds.size.height * 0.3)
            .padding(.horizontal, 16)
    }
}

extension HomeSectionView {
    private func albumsView(fullWidth: CGFloat) -> some View {
        let itemCount: CGFloat = section.layout == .three ? 3 : 4
        let spacing: CGFloat = 16
        var itemWidth = (fullWidth - (spacing * (itemCount - 1))) / itemCount
        itemWidth += (itemWidth / 5)
        
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(section.albums) { album in
                    AlbumImageTextView(imageName: album.albumImageName,
                                       description: album.albumName)
                        .frame(width: itemWidth, height: itemWidth)
                }
            }
            .padding(.horizontal, .design.padding16)
        }
    }
}

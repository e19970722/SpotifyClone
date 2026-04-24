//
//  PlaylistCollectionView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import SwiftUI
import Kingfisher

struct PlaylistCollectionView: View {
    
    let imageURL: URL?
    let title: String

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                albumImage(size: geometry.size.height)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
            .foregroundColor(.white)
            // 如果單純設定cornerRadius無效，額外給他個框框
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.theme.secondaryBtn)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

extension PlaylistCollectionView {

    private func albumImage(size: CGFloat) -> some View {
        KFImage(imageURL)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipped()
            .cornerRadius(2)
            .background(.black)
    }
}

#Preview {
    PlaylistCollectionView(imageURL: URL(string: "about:blank"), title: "Playlist Name")
        .frame(width: UIScreen.main.bounds.width, height: 120)
}

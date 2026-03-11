//
//  PlaylistCollectionView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import SwiftUI

struct PlaylistCollectionView: View {
    
    let imageName: String
    let imageURL: URL?
    let title: String

    init(imageName: String = "", imageURL: URL? = nil, title: String) {
        self.imageName = imageName
        self.imageURL = imageURL
        self.title = title
    }

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

    @ViewBuilder
    private func albumImage(size: CGFloat) -> some View {
        if let url = imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                        .foregroundColor(.white)
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: size, height: size)
            .clipped()
            .cornerRadius(2)
            .background(.black)
        } else {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipped()
                .cornerRadius(2)
                .background(.black)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    PlaylistCollectionView(imageName: DeveloperPreview.instance.playLists.first!.imageName, title: DeveloperPreview.instance.playLists.first!.title)
        .frame(width: UIScreen.main.bounds.width, height: 120)
}

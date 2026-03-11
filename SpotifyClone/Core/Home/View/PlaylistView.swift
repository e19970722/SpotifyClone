//
//  PlaylistView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/10/3.
//

import SwiftUI

struct PlaylistView: View {
    
    @Binding var inputText: String
    var playlist: PlaylistItem
    
    init(inputText: Binding<String>, playlist: PlaylistItem) {
        self._inputText = inputText
        self.playlist = playlist
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 48) {
                searchView
                    .frame(height: geo.size.height * 0.05)
                
                Image(playlist.imageName)
                    .resizable()
                    .frame(width: geo.size.width * 5/8,
                           height: geo.size.width * 5/8)
                
                detailView
                mainControlView
            }
            .padding(.all, 16)
        }
    }
}

#Preview {
    if let firstPlaylist = DeveloperPreview.instance.playLists.first {
        PlaylistView(inputText: .constant(""), playlist: firstPlaylist)
            .background(.black)
    }
}

extension PlaylistView {
    
    private var searchView: some View {
        HStack(spacing: 8) {
            let opacity = 0.8
            let fontSize = 14.0
            let cornerRadius = 4.0
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    
                TextField("Find on this page", text: $inputText)
                    .font(.system(size: fontSize, weight: .semibold))

            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(.white)
            .opacity(opacity)
            .clipped()
            .cornerRadius(cornerRadius)
            
            Button {
                
            } label: {
                Text("Sort")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(.gray)
                    .background(.white)
                    .opacity(opacity)
                    .clipped()
                    .cornerRadius(cornerRadius)
            }
        }
    }
    
    private var detailView: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let artists = self.playlist.artists {
                    Text(artists.joined(separator: ", "))
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))

                    if artists.count >= 3 {
                        Text("and more")
                            .font(.system(size: 12))
                            .foregroundColor(.greyColor1)
                    }
                }
                Spacer()
            }
            
            Text(self.playlist.durationSum)
                .foregroundColor(.greyColor1)
                .font(.system(size: 14, weight: .semibold))
        }
    }
    
    private var mainControlView: some View {
        HStack {
            mainControlLeftView
            Spacer()
            mainControlRightView
        }
    }
    
    private var mainControlLeftView: some View {
        HStack(spacing: 24) {
            Button {
                
            } label: {
                Image("")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .background(.red)
            }
            
            Button {
                
            } label: {
                Image("")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .background(.red)
            }
            
            Button {
                
            } label: {
                Image("")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .background(.red)
            }
            
            Button {
                
            } label: {
                Image("")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .background(.red)
            }
        }
    }
    
    private var mainControlRightView: some View {
        HStack(spacing: 24) {
            Button {
                
            } label: {
                Image("")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .background(.red)
            }
            
            Button {
                
            } label: {
                Image("")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .background(.red)
            }

        }
    }
}

//
//  NowPlayingView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/10.
//

import SwiftUI

struct NowPlayingView: View {
    
    @EnvironmentObject var vm: NowPlayingViewModel
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 8) {
                songMainView
                    .frame(maxHeight: .infinity)
                
                progressView(width: geo.size.width,
                             height: geo.size.height * 0.03)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .background(Color.theme.nowPlayingView)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            vm.loadSong(song: DeveloperPreview.instance.currentSong)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    NowPlayingView()
        .frame(height: UIScreen.main.bounds.height * (70 / 874))
        .environmentObject(NowPlayingViewModel())
}

extension NowPlayingView {
    
    private var songMainView: some View {
        HStack {
            songInfoView
            Spacer()
            // Test
            controlBtns
        }
    }
    
    private func progressView(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.greyColor1)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .frame(width: width * vm.currentProgress)
        }
        .frame(height: height)
    }
    
    private var songInfoView: some View {
        HStack(spacing: 8) {
            Image(vm.currentSong.albumImageName)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            songTitleAndDeviceView
        }
    }
    
    private var songTitleAndDeviceView: some View {
        VStack(alignment: .leading, spacing: 4) {
            songTitle
            deviceView
        }
    }
    
    private var songTitle: some View {
        HStack(spacing: 4) {
            HStack {
                Text(vm.currentSong.songName)
                    .lineLimit(1)
                Text("·")
            }
            .foregroundColor(.white)
            
            Text(vm.currentSong.artist)
                .lineLimit(1)
                .foregroundColor(.secondaryTextColor2)
        }
        .font(.system(size: 14))
    }
    
    private var deviceView: some View {
        HStack(spacing: 2) {
            Image(vm.playingDevice.rawValue)
                .resizable()
                .frame(width: 14, height: 14)
            Text(vm.deviceName)
                .font(.system(size: 12))
        }
        .foregroundColor(Color.theme.green)
    }
    
    private var controlBtns: some View {
        HStack(spacing: 24) {
            Button {
                
            } label: {
                Image(systemName: "headphones")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.theme.green)
            }
            
            Button {
                vm.isPlaying.toggle()
                if vm.isPlaying {
                    vm.play()
                } else {
                    vm.pause()
                }
            } label: {
                Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
    }
}

//
//  NowPlayingView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/10.
//

import SwiftUI
import Kingfisher

struct NowPlayingView: View {
    @EnvironmentObject var vm: NowPlayingViewModel
    
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            songMainView
            progressView
        }
        .padding(.horizontal, .design.padding8)
        .padding(.top, .design.padding8)
        .background(Color.theme.nowPlayingView)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NowPlayingView()
        .frame(height: UIScreen.main.bounds.height * (70 / 874))
        .environmentObject(NowPlayingViewModel())
}

extension NowPlayingView {
    
    private var songMainView: some View {
        HStack {
            songInfoView
            Spacer()
            controlBtns
        }
    }
    
    private var progressView: some View {
        PlayingProgressView(progress: $vm.progress,
                            lastProgressDrag: $vm.lastProgressDrag,
                            isSeeking: $vm.isSeeking,
                            canDrag: false)
            .frame(height: 2)
    }
    
    private var songInfoView: some View {
        HStack(spacing: 8) {
            KFImage(vm.currentSong?.imageURL)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .background(.black)
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
        Text(getDisplaySongInfo())
            .font(.system(size: 14))
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func getDisplaySongInfo() -> AttributedString {
        var displayStr = AttributedString("")

        var songName = AttributedString("\(vm.currentSong?.title ?? "") · ")
        songName.foregroundColor = .white
        displayStr += songName

        var artistName = AttributedString("\(vm.currentSong?.artists ?? "")")
        artistName.foregroundColor = .secondaryTextColor2
        displayStr += artistName

        return displayStr
    }
    
    private var deviceView: some View {
        HStack(spacing: 2) {
            Image(vm.playingDevice.rawValue)
                .resizable()
                .frame(width: 14, height: 14)
            
            Text(vm.deviceName)
                .font(.system(size: 12))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
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

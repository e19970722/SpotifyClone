//
//  NowPlayingFullScreenView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/20.
//

import SwiftUI
import Kingfisher

struct NowPlayingFullScreenView: View {

    @EnvironmentObject private var vm: NowPlayingViewModel
    @Environment(\.dismiss) private var dismiss

    private var screenWidth: CGFloat { UIScreen.main.bounds.width }

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    topBarView
                    albumArtView
                    songInfoView
                    progressBarView
                    controlsView
                    deviceInfoView
                }
            }
        }
    }
}

#Preview {
    NowPlayingFullScreenView()
        .environmentObject(NowPlayingViewModel())
}

// MARK: - Extension

extension NowPlayingFullScreenView {

    private var topBarView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            Text(vm.currentSong?.title ?? "")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()

            Button {
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, .design.padding16)
        .padding(.top, .design.padding16)
        .padding(.bottom, 24)
    }

    private var albumArtView: some View {
        let size = screenWidth - .design.padding16 * 2
        return KFImage(vm.currentSong?.imageURL)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: size, height: size)
            .background(Color.theme.secondaryBtn)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.bottom, 32)
    }

    private var songInfoView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.currentSong?.title ?? "")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(vm.currentSong?.artists ?? "")
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.theme.green)
            }
        }
        .padding(.horizontal, .design.padding16)
        .padding(.bottom, 24)
    }

    private var progressBarView: some View {
        VStack(spacing: 4) {
            PlayingProgressView(progress: $vm.progress,
                                lastProgressDrag: $vm.lastProgressDrag,
                                isSeeking: $vm.isSeeking,
                                canDrag: true,
                                onSeekTo: { progress in
                vm.playerSeek(to: progress)
            })
            .frame(height: 6)

            HStack {
                Text(vm.currentDuration.rounded().formatTimeStr())
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)

                Spacer()

                let remainingTime = vm.totalDuration - vm.currentDuration
                Text("-\(remainingTime.rounded().formatTimeStr())")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, .design.padding16)
        .padding(.bottom, 32)
    }

    private var controlsView: some View {
        HStack {
            Button {
            } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
                vm.isPlaying.toggle()
                
            } label: {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 64, height: 64)

                    Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.black)
                }
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "repeat")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, .design.padding16)
        .padding(.bottom, 32)
    }

    private var deviceInfoView: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "headphones")
                    .font(.system(size: 14))

                Text(vm.deviceName)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(Color.theme.green)

            Spacer()

            HStack(spacing: 20) {
                Button {
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }

                Button {
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.horizontal, .design.padding16)
    }
}

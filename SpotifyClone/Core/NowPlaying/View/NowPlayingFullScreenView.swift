//
//  NowPlayingFullScreenView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/20.
//

import SwiftUI

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

            Text(vm.currentSong.albumName)
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
        return Image(vm.currentSong.albumImageName)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.bottom, 32)
    }

    private var songInfoView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.currentSong.songName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(vm.currentSong.artist)
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
            PlayingProgressView(progress: $vm.currentProgress,
                                canDrag: true)
            .frame(height: 6)

            HStack {
                Text(formatTime(vm.currentTimerSec))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.theme.secondaryText)

                Spacer()

                Text(formatRemainingTime())
                    .font(.system(size: 12))
                    .foregroundStyle(Color.theme.secondaryText)
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
                vm.isPlaying ? vm.play() : vm.pause()
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

    // MARK: - Helpers

    private func formatTime(_ seconds: Double) -> String {
        let total = Int(seconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    private func formatRemainingTime() -> String {
        guard let duration = vm.currentSong.duration else { return "-0:00" }
        let remaining = Int(duration - vm.currentTimerSec)
        return String(format: "-%d:%02d", remaining / 60, remaining % 60)
    }
}

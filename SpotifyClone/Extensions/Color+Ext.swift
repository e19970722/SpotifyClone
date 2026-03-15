//
//  Color.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let green = Color("GreenColor1")
    let red = Color("RedColor")
    let secondaryText = Color("SecondaryTextColor")
    let secondaryBtn = Color("SecondaryBtnColor")
    let nowPlayingView = Color("NowPlayingViewColor")
    let newMusicVideoView = Color("NewMusicVideoView")
}

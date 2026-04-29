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
    let accent = Color("AccentColor", bundle: .module)
    let background = Color("BackgroundColor", bundle: .module)
    let green = Color("GreenColor1", bundle: .module)
    let red = Color("RedColor", bundle: .module)
    let secondaryText = Color("SecondaryTextColor", bundle: .module)
    let secondaryText2 = Color("SecondaryTextColor2", bundle: .module)
    let greyColor1 = Color("GreyColor1", bundle: .module)
    let secondaryBtn = Color("SecondaryBtnColor", bundle: .module)
    let nowPlayingView = Color("NowPlayingViewColor", bundle: .module)
    let newMusicVideoView = Color("NewMusicVideoView", bundle: .module)
}

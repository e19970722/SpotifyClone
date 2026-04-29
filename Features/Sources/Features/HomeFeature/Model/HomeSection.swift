//
//  HomeSection.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/10/2.
//

import Foundation

enum SectionLayout {
    case three
    case four
}

struct HomeSection: Identifiable {
    var id: String = UUID().uuidString
    let title: String
    let albums: [MusicItem]
    let layout: SectionLayout
    let heightPortion: CGFloat
    
    init(name: String, albums: [MusicItem], layout: SectionLayout = .three, heightPortion: CGFloat = 0.25) {
        self.title = name
        self.albums = albums
        self.layout = layout
        self.heightPortion = heightPortion
    }
}

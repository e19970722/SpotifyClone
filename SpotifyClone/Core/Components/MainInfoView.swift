//
//  MainInfoView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/9/16.
//

import SwiftUI

struct MainInfoView: View {
    
    @State private var showAlertMsg: AlertItem? = nil
    var profileImageName: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(profileImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            
            FillSegmentBtnView(isSelected: .constant(false), title: "All")
            FillSegmentBtnView(isSelected: .constant(false), title: "Music")
            FillSegmentBtnView(isSelected: .constant(false), title: "Podcasts")
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    MainInfoView(profileImageName: DeveloperPreview.instance.user.userImage)
        .frame(height: UIScreen.main.bounds.height * 0.05)
}

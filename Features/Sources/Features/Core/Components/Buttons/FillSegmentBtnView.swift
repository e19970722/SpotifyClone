//
//  FillSegmentBtnView.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/11.
//

import SwiftUI

struct FillSegmentBtnView: View {
    @Binding var isSelected: Bool
    
    let title: String
    
    var body: some View {
        Button {
            isSelected.toggle()
            
        } label: {
            Text(title)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? Color.theme.secondaryText : Color.white)
                .background(isSelected ? .green : Color.theme.secondaryBtn)
                .clipShape(RoundedRectangle(cornerRadius: 36))
        }
    }
}

#Preview {
    FillSegmentBtnView(isSelected: .constant(true), title: "All")
}

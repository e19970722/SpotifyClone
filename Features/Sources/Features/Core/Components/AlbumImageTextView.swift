//
//  AlbumImageTextView.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/10/2.
//

import SwiftUI

struct AlbumImageTextView: View {
    
    let imageName: String
    let description: String
     
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(imageName, bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fill)
                
            Text(description)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.theme.secondaryText2)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    AlbumImageTextView(imageName: "",
                       description: "")
    .background(.black)
    .frame(width: 200, height: 200)
}

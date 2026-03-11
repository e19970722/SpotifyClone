//
//  AlertItem.swift
//  SwiftUIPractice_20250803
//
//  Created by Yen Lin on 2025/8/3.
//

import Foundation

struct AlertItem: Identifiable {
    var id: String = UUID().uuidString
    let title: String
    let msg: String
}

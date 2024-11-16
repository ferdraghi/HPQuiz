//
//  BookStatus.swift
//  HP Quiz
//
//  Created by Fernando Draghi on 13/11/2024.
//

import SwiftUI

enum BookStatus: Codable {
    case selected, unselected, locked
    
    var statusIcon: String {
        switch self {
        case .selected: return "checkmark.circle.fill"
        case .unselected: return "circle"
        case .locked: return "lock.fill"
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .selected, .unselected:
            return .black
        case .locked:
            return .white.opacity(0.75)
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .selected, .unselected:
            return 1
        case .locked:
            return 3
        }
    }
    
    @ViewBuilder
    var overlay: some View {
        switch self {
        case .selected:
            EmptyView()
        case .unselected:
            Rectangle().opacity(0.25)
        case .locked:
            Rectangle().opacity(0.5)
        }
    }
}

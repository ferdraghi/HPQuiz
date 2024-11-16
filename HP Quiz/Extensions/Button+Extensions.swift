//
//  Button+Extensions.swift
//  HP Quiz
//
//  Created by Fernando Draghi on 13/11/2024.
//
import SwiftUI

extension Button {
    func doneButtonStyle() -> some View {
        self
            .font(.largeTitle)
            .padding()
            .buttonStyle(.borderedProminent)
            .tint(.brown)
            .foregroundStyle(.white)
    }
}

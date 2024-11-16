//
//  BookCellView.swift
//  HP Quiz
//
//  Created by Fernando Draghi on 13/11/2024.
//

import SwiftUI

struct BookCellView: View {
    var bookName: String
    @Binding var status: BookStatus
    
    var body: some View {
        Image(bookName)
            .resizable()
            .scaledToFit()
            .shadow(radius: 7)
            .overlay(content: {
                status.overlay
            })
            .overlay(
                Image(systemName: status.statusIcon)
                    .font(.largeTitle)
                    .imageScale(.large)
                    .foregroundStyle(status == .locked ? .black : .green)
                    .shadow(color: status.shadowColor, radius: status.shadowRadius)
                    .padding(3),
                alignment: status == .locked ? .center : .bottomTrailing)
            .foregroundStyle(.black)
    }
}

#Preview {
    BookCellView(bookName: "hp1", status: .constant(.unselected))
}

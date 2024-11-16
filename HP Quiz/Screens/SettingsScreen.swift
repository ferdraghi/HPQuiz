//
//  SettingsScreen.swift
//  HP Quiz
//
//  Created by Fernando Draghi on 13/11/2024.
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: Store
    var body: some View {
        ZStack {
            CommonBackgrounds.parchment
            
            VStack {
                Text("Which books would you like to see questions from?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(0..<7) { index in
                            BookCellView(bookName: "hp\(index+1)", status: .constant(store.books[index]))
                                .onTapGesture {
                                    selected(index)
                                }
                        }
                    }
                    .padding()
                }

                Button("Done") {
                    dismiss()
                }
                .doneButtonStyle()
            }
        }
        .foregroundStyle(.black)
    }
    
    private func selected(_ index: Int) {
        switch store.books[index] {
            case .selected:
            store.markBookAt(index: index, with: .unselected)
        case .unselected:
            store.markBookAt(index: index, with: .selected)
        case .locked:
            if let product = store.products.first(where: { product in
                product.id == "hp\(index+1)"
            }) {
                Task {
                    await store.purchase(product)
                }
            }
        }
    }
}

#Preview {
    SettingsScreen()
        .environmentObject(Store())
}

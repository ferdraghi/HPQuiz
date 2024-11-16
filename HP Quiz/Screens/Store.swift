//
//  Store.swift
//  HP Quiz
//
//  Created by Fernando Draghi on 14/11/2024.
//

import StoreKit

@MainActor
class Store: ObservableObject {
    @Published private(set) var books: [BookStatus] = [.selected, .selected, .unselected, .locked, .locked, .locked, .locked]
    @Published var products: [Product] = []
    @Published var purchasedIDs = Set<String>()
    private var savePath: URL {
        FileManager.documentsDirectory.appendingPathComponent("store.json")
    }
    private var productIDs = ["hp4", "hp5", "hp6", "hp7"]
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        loadSelectedBooks()
        updates = watchForUpdates()
        Task {
            await restorePurchases()
        }
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .unverified(let signedType, let verificationError):
                    print("Error on \(signedType): \(verificationError)")
                case .verified(let signedType):
                    unlock(signedType.productID)
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Failed to buy product \(product) with error: \(error)")
        }
    }
    
    func restorePurchases() async {
        for product in products {
            guard let state = await product.currentEntitlement else { return }
            if case .verified(let signedType) = state {
                DispatchQueue.main.async {
                    if signedType.revocationDate == nil {
                        self.unlock(signedType.productID)
                    } else {
                        self.lock(signedType.productID)
                    }
                }
            }
        }
    }
    
    func markBookAt(index: Int, with status: BookStatus) {
        guard index > 0, index < books.count else { return }
        books[index] = status
        
        saveSelectedBooks()
    }
    
    private func watchForUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                await restorePurchases()
            }
        }
    }
    
    private func unlock(_ id: String) {
        let index = index(for: id)
        guard index >= 0 else { return }

        purchasedIDs.insert(id)
        if books[index] == .locked {
            markBookAt(index: index, with: .selected)
        }
    }
    
    private func lock(_ id: String) {
        let index = index(for: id)
        guard index >= 0 else { return }

        purchasedIDs.remove(id)
        markBookAt(index: index, with: .locked)
    }
    
    private func saveSelectedBooks() {
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: savePath)
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    private func loadSelectedBooks() {
        do {
            let data = try Data(contentsOf: savePath)
            books = try JSONDecoder().decode([BookStatus].self, from: data)
        } catch {
            print("Failed to load store data: \(error)")
            books = [.selected, .selected, .unselected, .locked, .locked, .locked, .locked]
        }
    }
    
    private func index(for id: String) -> Int {
        switch id {
        case "hp4":
            return 3
        case "hp5":
            return 4
        case "hp6":
            return 5
        case "hp7":
            return 6
        default:
            return -1
        }
    }
}

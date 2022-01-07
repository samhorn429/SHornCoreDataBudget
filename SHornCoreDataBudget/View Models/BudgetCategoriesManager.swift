//
//  BudgetCategoriesManager.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/10/21.
//

import Foundation

class BudgetCategoriesManager: ObservableObject {
    @Published var scManager: SubCategoriesManager
    @Published var groups: [String] = Array<String>()
    @Published var categories: [Category] = Array<Category>()
    init() throws {
        scManager = try! SubCategoriesManager()
        for scIndex in scManager.subCategories.indices {
            if !groups.contains(scManager.subCategories[scIndex].group) {
                groups.append(scManager.subCategories[scIndex].group)
            }
            if !categories.contains(where: {$0.category == scManager.subCategories[scIndex].category }) {
                categories.append(Category(
                    category: scManager.subCategories[scIndex].category,
                    group: scManager.subCategories[scIndex].group))
            }
        }
    }
}

struct Category: Identifiable, Codable {
    var id = UUID()
    var category: String
    var group: String
}



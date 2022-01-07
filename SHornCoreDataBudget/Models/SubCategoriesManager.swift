//
//  SubCategoriesManager.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/10/21.
//

import Foundation
import SwiftUI

struct SubCategoriesManager {
    var subCategories: [SubCategory] = []
    private let filename = "subcategories"
    
    init() throws {
        let mainBundle = Bundle.main
        let subCategoryURL = mainBundle.url(forResource: filename, withExtension: ".json")!
        
        do {
            let subCategoryData = try Data(contentsOf: subCategoryURL)
            let decoder = JSONDecoder()
            subCategories = try decoder.decode([SubCategory].self, from: subCategoryData)
        }
        catch {
            print(error)
            subCategories = []
        }
    }
}

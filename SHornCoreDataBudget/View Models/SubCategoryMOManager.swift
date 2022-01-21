//
//  SubCategoryMOManager.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 1/21/22.
//

import Foundation
import SwiftUI

class UserCategoryCoreDataManager: ObservableObject {
    @FetchRequest(
        entity: UserCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \UserCategory.ucid, ascending: true)],
        animation: .default)
    var userCategories: FetchedResults<UserCategory>
    
    func getGroups() -> [String] {
        var groups = Array<String>()
        for userCategory in userCategories {
            if !groups.contains(where: {
                $0 == userCategory.subCategory?.group ?? ""
            }) {
                groups.append(userCategory.subCategory?.group ?? "")
            }
        }
        return groups
    }
    
    func getCategories(group: String) -> [String] {
        var categories = Array<String>()
        for userCategory in userCategories.filter({
            $0.subCategory?.group ?? "" == group
        }) {
            if !categories.contains(where: {
                $0 == userCategory.subCategory?.category ?? ""
            }) {
                categories.append(userCategory.subCategory?.category ?? "")
            }
        }
        return categories
    }
    
    func getSubCategories(group: String, category: String) -> [String] {
        var subCategoriesArr = Array<String>()
        for userCategory in userCategories.filter({
            $0.subCategory?.group ?? "" == group &&
            $0.subCategory?.category ?? "" == category
        }) {
            subCategoriesArr.append(userCategory.subCategory?.subCategory ?? "")
        }
        return subCategoriesArr
    }

    
    
    func getTotalBudgetAmount() -> Float {
        var totalBudget: Float = 0.00
        for userCategory in userCategories {
            totalBudget += userCategory.budgetAmount
        }
        return totalBudget
    }
    
}

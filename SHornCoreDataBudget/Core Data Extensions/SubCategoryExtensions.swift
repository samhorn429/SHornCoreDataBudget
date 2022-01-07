//
//  SubCategoryAndUserCategoryExtensions.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/20/21.
//

import Foundation
import SwiftUI
import CoreData

struct SubCategoryMethods {
    
    static func getGroups(subCategories: FetchedResults<SubCategoryMO>) -> [String] {
        var groups = Array<String>()
        for subCategory in subCategories {
            if !groups.contains(where: {
                $0 == subCategory.group ?? ""
            }) {
                groups.append(subCategory.group ?? "")
            }
        }
        return groups
    }
    
    static func getGroups(userCategories: FetchedResults<UserCategory>) -> [String] {
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
    
    static func getCategories(group: String, subCategories: FetchedResults<SubCategoryMO>) -> [String] {
        var categories = Array<String>()
        for subCategory in subCategories.filter({
            $0.group ?? "" == group
        }) {
            if !categories.contains(where: {
                $0 == subCategory.category ?? ""
            }) {
                categories.append(subCategory.category ?? "")
            }
        }
        return categories
    }
    
    static func getCategories(group: String, userCategories: FetchedResults<UserCategory>) -> [String] {
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
    
    static func getSubCategories(group: String, category: String, subCategories: FetchedResults<SubCategoryMO>) -> [String] {
        var subCategoriesArr = Array<String>()
        for subCategory in subCategories.filter({
            $0.group ?? "" == group &&
            $0.category ?? "" == category
        }) {
            subCategoriesArr.append(subCategory.subCategory ?? "")
        }
        return subCategoriesArr
    }
    
    static func getSubCategories(group: String, category: String, userCategories: FetchedResults<UserCategory>) -> [String] {
        var subCategoriesArr = Array<String>()
        for userCategory in userCategories.filter({
            $0.subCategory?.group ?? "" == group &&
            $0.subCategory?.category ?? "" == category
        }) {
            subCategoriesArr.append(userCategory.subCategory?.subCategory ?? "")
        }
        return subCategoriesArr
    }
    
    static func getTotalBudgetAmount(subCategories: FetchedResults<SubCategoryMO>) -> Float {
        var totalBudget: Float = 0.00
        for subCategory in subCategories {
            totalBudget += subCategory.userCategory?.budgetAmount ?? 0.00
        }
        return totalBudget
    }
}


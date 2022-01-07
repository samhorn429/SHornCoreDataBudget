//
//  CategoryBudgetAmounts.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/10/21.
//

import Foundation
import SwiftUI

class UserCategoryBudgetManager: ObservableObject {
    @Published var userCategoryBudgetDict: [String: [String: [String: Float]]]   //= [:] = [:] //= [:[:]]
    @Published var userCategoryAmountDict: [String: [String: [String: Float]]] //= [:[:]]
    @Published var userCategoryBudgetTotals: [String : [String: Float]]
    @Published var userCategoryAmountTotals: [String : [String: Float]]
    
    init() {
        //super.init()
        userCategoryBudgetDict = Dictionary<String, Dictionary<String, Dictionary<String, Float>>>()
        userCategoryAmountDict = Dictionary<String, Dictionary<String, Dictionary<String, Float>>>()
        userCategoryBudgetTotals = Dictionary<String, Dictionary<String, Float>>()
        userCategoryAmountTotals = Dictionary<String, Dictionary<String, Float>>()
    }
}


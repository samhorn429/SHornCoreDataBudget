//
//  MoneyValuesOnly.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 1/18/22.
//

import Foundation
import CoreData
import SwiftUI

class MoneyValueText: ObservableObject {
    var subCategory: SubCategoryMO
    @Published var value = "" {
        didSet {

            let tempVal = value
            if tempVal == "." {
                value = "0."
            } else {

                if Float(value) != nil {
                    if value.contains(".") &&
                        value.distance(
                            from: value.startIndex,
                            to: value.range(of: ".")!.lowerBound) < value.count - 3
                    {
                        value = oldValue
                    }
                } else {
                    value = oldValue
                }
            }
        }
    }
    
    init(subCategory: SubCategoryMO) {
        self.subCategory = subCategory
        value = String(format: "%.2f", subCategory.userCategory?.budgetAmount ?? 0.00)
    }
}

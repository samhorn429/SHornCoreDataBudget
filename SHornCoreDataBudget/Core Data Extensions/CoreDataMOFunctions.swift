//
//  CoreDataTransactionMethods.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 12/12/21.
//

import Foundation
import SwiftUI

struct TransactionMethods {
    
    static func getTotalAmountSpent(transactions: FetchedResults<UserTransaction>) -> Float {
        var totalAmount: Float = 0.00
        for transaction in transactions {
            totalAmount += transaction.amount
        }
        return totalAmount
    }
    
    static func getActualGroupTotal(transactions: FetchedResults<UserTransaction>, group: String?) -> Float {
        var totalAmount: Float = 0.00
        for transaction in transactions {
            if transaction.subCategory?.group == group {
                totalAmount += transaction.amount
            }
        }
        return totalAmount
    }
    
    static func getActualCategoryTotal(transactions: FetchedResults<UserTransaction>, group: String?, category: String?) -> Float {
        var totalAmount: Float = 0.00
        for transaction in transactions {
            if transaction.subCategory?.group == group &&
                transaction.subCategory?.category == category {
                totalAmount += transaction.amount
            }
        }
        return totalAmount
    }
    
    static func getActualSubCategoryTotal(transactions: FetchedResults<UserTransaction>, subCategory: SubCategoryMO) -> Float {
        var totalAmount: Float = 0.00
        for transaction in transactions {
            if transaction.subCategory == subCategory {
                totalAmount += transaction.amount
            }
        }
        return totalAmount
    }
}

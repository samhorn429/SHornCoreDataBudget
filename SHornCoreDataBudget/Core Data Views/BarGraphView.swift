//
//  BarGraphView.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 12/12/21.
//

import Foundation
import SwiftUI
import CoreData

struct BarInfo: Identifiable {
    var id = UUID()
    var height: Double
    var color: Color
}

struct BarGraphBar: View {
    
    var barInfo: BarInfo
    var numBars: Int
    var barIndex: Int
    var amountString: String
    var percentString: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let width: CGFloat = geometry.size.width
                    
                    path.addRect(
                        CGRect(
                            x: width * 0.5,
                            y: 0.0,
                            width: width,
                            height: barInfo.height
                        )
                    )
                }
                VStack {
                    Text(amountString)
                        .font(.caption)
                    Text(percentString)
                        .font(.caption)
                }
            }
        }
    }
}
//
//struct BudgetBarGraph: View {
//    @Environment(\.managedObjectContext) var viewContext
//    @Binding var totalHeight: CGFloat
//    @Binding var group: String?
//    @Binding var category: String?
//    var payChecks: FetchedResults<PayCheckMO>
//    var userCategories: FetchedResults<UserCategory>
//    var subCategories: FetchedResults<SubCategoryMO>
//    
//    @EnvironmentObject var budgetManager: BudgetCategoriesManager
//    @EnvironmentObject var ucSubmitManager: UserCategorySubmitManager
//    @Binding var isBudgetAmount: Bool
//    var transactions: FetchedResults<UserTransaction>
//    
//    var actualTotalAmount: Float {
//        return MOFunctions.getTotalAmountSpent(transactions: transactions)
//    }
//    
//    func actualGroupTotalAmount(_ group: String?) -> Float {
//        return MOFunctions.getActualGroupTotal(transactions: transactions, group: group)
//    }
//    
//    func actualCategoryTotalAmount(group: String?, category: String?) -> Float {
//        return MOFunctions.getActualCategoryTotal(transactions: transactions, group: group, category: category)
//    }
//    
//    func actualSubCategoryTotalAmount(_ subCategory: SubCategoryMO) -> Float {
//        return MOFunctions.getActualSubCategoryTotal(transactions: transactions, subCategory: subCategory)
//    }
//    
//    var totalAmount: Float {
////        var totalBudget: Float = 0.00
////        for payCheck in payChecks {
////            totalBudget += payCheck.amount
////        }
////        return totalBudget
//        var totalBudget: Float = 0.00
//        
//        if !isBudgetAmount {
//            return actualTotalAmount
//        }
//        for userCategory in userCategories {
////            if isBudgetAmount {
////                totalBudget += userCategory.budgetAmount
////            } else {
////                //totalBudget += userCategory.actualAmount
////            }
//            totalBudget += userCategory.budgetAmount
//        }
//        
//        return totalBudget
//    }
//    
//    var categoryAmount: Float {
//        return getCategoryAmount(group: group, category: category)
//    }
//    
////    func getCategoryAmount(_ category: String?) -> Float {
////        if group != nil {
////            if category != nil {
////                var categoryAmount: Float = 0.00
////                for userCategory in userCategories.filter({$0.subCategory?.category ?? nil == category!}) {
////                    if isBudgetAmount {
////                        categoryAmount += userCategory.budgetAmount
////                    } else {
////                        categoryAmount += userCategory.actualAmount
////                    }
////                }
////                return categoryAmount
////            }
////            return 0.00
////        }
////        return 0.00
////    }
//    
//    func getCategoryAmount(group: String?, category: String?) -> Float {
//        if group != nil {
//            if category != nil {
//                if !isBudgetAmount {
//                    return actualCategoryTotalAmount(group: group, category: category)
//                }
//                var categoryAmount: Float = 0.00
//                for userCategory in userCategories.filter({$0.subCategory?.category ?? nil == category!}) {
//
//                    categoryAmount += userCategory.budgetAmount
//                }
//                return categoryAmount
//            }
//            return 0.00
//        }
//        return 0.00
//    }
//    
//    var groupAmount: Float {
//        return getGroupAmount(group)
//    }
//    
////    func getGroupAmount(_ group: String?) -> Float {
////        if group != nil {
////            var groupAmount: Float = 0.00
////            for userCategory in userCategories.filter({$0.subCategory?.group ?? nil == group!}) {
////                if isBudgetAmount {
////                    groupAmount += userCategory.budgetAmount
////                } else {
////                    groupAmount += userCategory.actualAmount
////                }
////            }
////            return groupAmount
////        }
////        return 0.00
////    }
//    
//    func getGroupAmount(_ group: String?) -> Float {
//        if group != nil {
//            if !isBudgetAmount {
//                return actualGroupTotalAmount(group)
//            }
//            var groupAmount: Float = 0.00
//            for userCategory in userCategories.filter({$0.subCategory?.group ?? nil == group!}) {
//                groupAmount += userCategory.budgetAmount
//            }
//            return groupAmount
//        }
//        return 0.00
//    }
//    
//    
//    
//    var mainBars: [BarInfo] {
//        var tempBars = Array<BarInfo>()
//        let groupColors = Color.chartColorList
//        
//        var groupColorsIndex: Int = 0
//        let totalAmount = totalAmount
//        
//        let groups = SubCategoryMethods.getGroups(userCategories: userCategories)
//        
//        if totalAmount > Float(0.00) {
//            for group in groups {
//                
//            }
//        }
//    }
//}

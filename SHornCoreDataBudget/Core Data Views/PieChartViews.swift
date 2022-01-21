//
//  PieChartViews.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/17/21.
//

import Foundation
import SwiftUI
import CoreData

struct PieSliceInfo: Identifiable {
    var id = UUID()
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
}

struct PieSlice: View {
    
    var pieSliceInfo: PieSliceInfo
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width : CGFloat = min(geometry.size.width, geometry.size.height)
                let height = width
                
                let center = CGPoint(x: width * 0.5, y: height * 0.5)
                
                path.move(to: center)
                
                path.addArc(
                    center: center,
                    radius: width * 0.5,
                    startAngle: Angle(radians: -Double.pi/2) + pieSliceInfo.startAngle,
                    endAngle: Angle(radians: -Double.pi/2) + pieSliceInfo.endAngle,
                    clockwise: false
                )
            }
            .fill(pieSliceInfo.color)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct BudgetPieChart: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var totalAngle: Angle
    @Binding var group: String?
    @Binding var category: String?
    var payChecks: FetchedResults<PayCheckMO>
    var subCategories: FetchedResults<SubCategoryMO>
    var userCategories: FetchedResults<UserCategory>
    @Binding var isBudgetAmount: Bool
    var transactions: FetchedResults<UserTransaction>
    
    var actualTotalAmount: Float {
        return TransactionMethods.getTotalAmountSpent(transactions: transactions)
    }
    
    func actualGroupTotalAmount(_ group: String?) -> Float {
        return TransactionMethods.getActualGroupTotal(transactions: transactions, group: group)
    }
    
    func actualCategoryTotalAmount(group: String?, category: String?) -> Float {
        return TransactionMethods.getActualCategoryTotal(transactions: transactions, group: group, category: category)
    }
    
    func actualSubCategoryTotalAmount(_ subCategory: SubCategoryMO) -> Float {
        return TransactionMethods.getActualSubCategoryTotal(transactions: transactions, subCategory: subCategory)
    }
    
    var totalAmount: Float {
        var totalBudget: Float = 0.00
        
        if !isBudgetAmount {
            return actualTotalAmount
        }
        for userCategory in userCategories {
            totalBudget += userCategory.budgetAmount
        }
        
        return totalBudget
    }
    
    var categoryAmount: Float {
        return getCategoryAmount(group: group, category: category)
    }
    
    func getCategoryAmount(group: String?, category: String?) -> Float {
        if group != nil {
            if category != nil {
                if !isBudgetAmount {
                    return actualCategoryTotalAmount(group: group, category: category)
                }
                var categoryAmount: Float = 0.00
                for userCategory in userCategories.filter({$0.subCategory?.category ?? nil == category!}) {

                    categoryAmount += userCategory.budgetAmount
                }
                return categoryAmount
            }
            return 0.00
        }
        return 0.00
    }
    
    var groupAmount: Float {
        return getGroupAmount(group)
    }
    
    func getGroupAmount(_ group: String?) -> Float {
        if group != nil {
            if !isBudgetAmount {
                return actualGroupTotalAmount(group)
            }
            var groupAmount: Float = 0.00
            for userCategory in userCategories.filter({$0.subCategory?.group ?? nil == group!}) {
                groupAmount += userCategory.budgetAmount
            }
            return groupAmount
        }
        return 0.00
    }
    
    var mainPieSlices: [PieSliceInfo] {

        var tempPieSlices = Array<PieSliceInfo>()
        var endRadians: Double = 0.00
        let groupColors = Color.chartColorList
        var groupColorsIndex: Int = 0
        let totalAmount = totalAmount
        
        let groups = SubCategoryMethods.getGroups(userCategories: userCategories)
        
        if totalAmount > Float(0.00) {
            for group in groups {
                let radians: Double = 2*Double.pi*Double(getGroupAmount(group)/totalAmount)
                tempPieSlices.append(PieSliceInfo(
                    startAngle: Angle(radians: endRadians),
                    endAngle: Angle(radians: endRadians + radians),
                    color: groupColors[groupColorsIndex]
                ))
                endRadians += radians
                groupColorsIndex +=  1
            }
        }
        return tempPieSlices
    }
    
    var groupPieSlices: [PieSliceInfo] {
        var tempPieSlices = Array<PieSliceInfo>()
        var endRadians: Double = 0.00
        let categoryColors = Color.chartColorList
        var categoryColorsIndex: Int = 0
        let groupAmount = groupAmount
    
        let categories = SubCategoryMethods.getCategories(group: group ?? "", userCategories: userCategories)
        
        if groupAmount > Float(0.00) {
            for category in categories {
                let radians: Double = 2*Double.pi*Double(getCategoryAmount(group: group, category: category)/groupAmount)
                tempPieSlices.append(PieSliceInfo(
                    startAngle: Angle(radians: endRadians),
                    endAngle: Angle(radians: endRadians + radians),
                    color: categoryColors[categoryColorsIndex]))
                endRadians += radians
                categoryColorsIndex += 1
            }
        }
        
        return tempPieSlices
    }
    
    var categoryPieSlices: [PieSliceInfo] {
        var tempPieSlices = Array<PieSliceInfo>()
        
        var endRadians: Double = 0.00
        let filteredUserCategories = userCategories.filter({$0.subCategory?.category ?? nil == category!})
        let subCategoryColors = Color.chartColorList
        let categoryBudget = categoryAmount
        var subCategoryColorsIndex = 0
                                                                
        for userCategory in filteredUserCategories {
            let radians = isBudgetAmount ?
            2*Double.pi*Double(userCategory.budgetAmount/categoryBudget) :
            2*Double.pi*Double(actualSubCategoryTotalAmount(userCategory.subCategory!)/categoryBudget)
            tempPieSlices.append(PieSliceInfo(
                startAngle: Angle(radians: endRadians),
                endAngle: Angle(radians: endRadians + radians),
                color: subCategoryColors[subCategoryColorsIndex]
            ))
            endRadians += radians
            subCategoryColorsIndex += 1
            
        }
        
        return tempPieSlices
    }
    
    var pieSlices: [PieSliceInfo] {
        if category == nil && group == nil {
            return mainPieSlices
        } else if group != nil && category == nil {
            return groupPieSlices
        } else {
            return categoryPieSlices
        }
    }
    
    var currentPieSlices: [PieSliceInfo] {
        let pieSlices = pieSlices
        var newPieSlices = Array<PieSliceInfo>()
        var newAngle = Angle(radians: 0.0)
        var lastPieSlice: PieSliceInfo? = nil
        for pieSlice in pieSlices {
            if newAngle + pieSlice.endAngle - pieSlice.startAngle >= totalAngle {
                lastPieSlice = pieSlice
                break
            }
            newAngle += pieSlice.endAngle - pieSlice.startAngle
            newPieSlices.append(pieSlice)
        }
        if lastPieSlice != nil {
            lastPieSlice!.endAngle = totalAngle
            newPieSlices.append(lastPieSlice!)
        }
        return newPieSlices
    }
    
    var amount: Float {
        if category == nil && group == nil {
            return totalAmount
        } else if group != nil && category == nil {
            return groupAmount
        } else {
            return categoryAmount
        }
    }
    
    var currentAmount: Float {
        if totalAngle.radians < 2.0*Double.pi {
            return amount*Float(totalAngle.radians/(2.0*Double.pi))
        } else {
            return amount
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(currentPieSlices) {pieSlice in
                PieSlice(pieSliceInfo: pieSlice)
            }
            .frame(width: UIScreen.main.bounds.width*2/3, height: UIScreen.main.bounds.width*2/3)
            Circle()
                .fill(.white)
                .frame(width: UIScreen.main.bounds.width*2/5, height: UIScreen.main.bounds.height*2/5)
            VStack {
                Text("Total")
                    .bold()
                    .foregroundColor(.gray)
                    .font(.title3)
                Text("$\(String(format: "%.2f", currentAmount))")
                    .bold()
                    .foregroundColor(.black)
                    .font(.title2)
            }
        }
    }
}






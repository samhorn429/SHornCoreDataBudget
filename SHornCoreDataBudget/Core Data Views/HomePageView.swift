//
//  HomePageView.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/17/21.
//

import Foundation
import SwiftUI
import CoreData
import Combine

struct HomePageView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        entity: UserCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \UserCategory.ucid, ascending: true)],
        animation: .default)
    var userCategories: FetchedResults<UserCategory>
    @FetchRequest(
        entity: PayCheckMO.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \PayCheckMO.pcid, ascending: true)],
        animation: .default
    ) var payChecks: FetchedResults<PayCheckMO>
    @FetchRequest(
        entity: SubCategoryMO.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SubCategoryMO.id, ascending: true)],
        animation: .default
    ) var subCategories: FetchedResults<SubCategoryMO>
    @FetchRequest(
        entity: UserTransaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \UserTransaction.tid, ascending: true)],
        animation: .default
    ) var userTransactions: FetchedResults<UserTransaction>
    
    @EnvironmentObject var budgetManager: BudgetCategoriesManager
    @EnvironmentObject var budgetDateManager: BudgetMonthAndYearManager
    
    @AppStorage("isPieChart") var isPieChart: Bool = true
    @State var group: String? = nil
    @State var category: String? = nil
    @State var classification: Classification = .none
    @AppStorage("isBudgetAmount") var isBudgetAmount: Bool = true
    @State var navBarHidden: Bool = false
    @State var totalAngle = Angle(radians: 0.0)
    @State var timeInterval: Double = 0.0

    var title: String {
        if category != nil {
            return category!
        }
        else if group != nil {
            return group!
        }
        else {
            return "Home Page"
        }
    }
   
    
    private var filteredSubCategories: [FetchedResults<SubCategoryMO>.Element] {

        switch(classification) {
        case .group:
            return subCategories.filter({
                $0.group == group!
            })
        case .category:
            return subCategories.filter({
                $0.group == group!
                && $0.category == category!
            })
        case .none:
            return subCategories.filter({_ in true})
        }
    }
    
    private var nameList: [String] {
        switch(classification) {
        case .none:
            return SubCategoryMethods.getGroups(subCategories: subCategories)
        case .group:
            return SubCategoryMethods.getCategories(group: group ?? "", userCategories: userCategories)
        case .category:
            return SubCategoryMethods.getSubCategories(group: group ?? "", category: category ?? "", userCategories: userCategories)
        }
    }
    
    private var nameListIndices: Range<Int> {
        return nameList.indices
    }
    
    private func subCategory(index: Int) -> String? {
        if classification == .category {
            return nameList[index]
        }
        else {
            return nil
        }
    }

    private func setGroup(value: String) -> Binding<String?> {
        if group == nil {
            group = value
        }
        return $group
    }
    
    private func setCategory(value: String) -> Binding<String?> {
        if category == nil {
            group = value
        }
        return $category
    }
    
    private func timeBudgetGraph() {
        totalAngle = Angle(radians: 0.0)
        let ogTimeInterval = timeInterval
        let timer = Timer.scheduledTimer(
            withTimeInterval: timeInterval,
            repeats: true,
            block: {timer in
        
                totalAngle = Angle(radians: totalAngle.radians + 0.005*Double.pi)
                if(totalAngle.radians >= 2*Double.pi) {
                    timer.invalidate()
                }
            })
        timer.fire()
        navBarHidden = false
        timeInterval = ogTimeInterval
    }
    
    var body: some View {

        NavigationView {
            ScrollView {
            VStack(spacing: UIScreen.main.bounds.width/32) {
                
                Picker("Actual or Budget", selection: $isBudgetAmount, content: {
                    Text("Budget").tag(true)
                    Text("Actual Spending").tag(false)
                })
                    .onChange(of: isBudgetAmount) {_ in
                        timeBudgetGraph()
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    BudgetPieChart(
                        totalAngle: $totalAngle,
                        group: $group,
                        category: $category,
                        payChecks: payChecks,
                        subCategories: subCategories,
                        userCategories: userCategories,
                        isBudgetAmount: $isBudgetAmount,
                        transactions: userTransactions
                    )
                    .environment(\.managedObjectContext, viewContext)

                   
                
                Group {
                    if category != nil {
                        ForEach(nameListIndices) {nameListIndex in
                            ChartOrGraphRow(
                                classification: classification,
                                textName: nameList[nameListIndex],
                                group: group,
                                category: category,
                                subCategory: subCategory(index: nameListIndex),
                                subCategories: subCategories,
                                transactions: userTransactions,
                                colorIndex: nameListIndex,
                                isBudgetAmount: $isBudgetAmount,
                                totalAngle: $totalAngle
                            )
                        }
                    } else if group != nil {
                        ForEach(nameListIndices) {nameListIndex in
                            NavigationLink(destination:
                                            HomePageView(
                                                group: group,
                                                category: nameList[nameListIndex],
                                                classification: .category
                                            )
                                            .environmentObject(budgetManager)
                                            .environment(\.managedObjectContext, viewContext)
                            ) {
                                ChartOrGraphRow(
                                    classification: classification,
                                    textName: nameList[nameListIndex],
                                    group: group,
                                    category: nameList[nameListIndex],
                                    subCategory: subCategory(index: nameListIndex),
                                    subCategories: subCategories,
                                    transactions: userTransactions,
                                    colorIndex: nameListIndex,
                                    isBudgetAmount: $isBudgetAmount,
                                    totalAngle: $totalAngle
                                )
                            }
                        }
                    } else {
                        ForEach(nameListIndices) {nameListIndex in
                            NavigationLink(destination:
                                            HomePageView(
                                                group: nameList[nameListIndex],
                                                category: category,
                                                classification: .group
                                            )
                                            .environmentObject(budgetManager)
                                            .environment(\.managedObjectContext, viewContext)
                            ) {
                                ChartOrGraphRow(
                                    classification: classification,
                                    textName: nameList[nameListIndex],
                                    group: nameList[nameListIndex],
                                    category: category,
                                    subCategory: subCategory(index: nameListIndex),
                                    subCategories: subCategories,
                                    transactions: userTransactions,
                                    colorIndex: nameListIndex,
                                    isBudgetAmount: $isBudgetAmount,
                                    totalAngle: $totalAngle
                                )
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(
                leading:
                    NavigationLink(destination:
                                    BudgetView(navBarHidden: $navBarHidden)
                                    .environment(\.managedObjectContext, viewContext)
                                    .environmentObject(budgetManager)
                                    .environmentObject(budgetDateManager)) {
                                        Text("Edit Budget")
                                    },
                trailing:
                    NavigationLink(destination:
                                  TransactionView(
                                    transactions: userTransactions,
                                    subCategories: subCategories)
                                    .environment(\.managedObjectContext, viewContext)) {
                                        Text("Transactions")
                                    }
                
            )
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    
                }
            }
            .onAppear {
                timeBudgetGraph()
            }
            
        }
    }
}

struct ChartOrGraphRow: View {
    let colorBoxSideLength = UIScreen.main.bounds.width/10
    var classification: Classification
    var textName: String
    var group: String?
    var category: String?
    var subCategory: String?
    var subCategories: FetchedResults<SubCategoryMO>
    var transactions: FetchedResults<UserTransaction>
    var colorIndex: Int
    @Binding var isBudgetAmount: Bool
    @Binding var totalAngle: Angle
    
    
    private func subCategoryList(classification: Classification) -> [FetchedResults<SubCategoryMO>.Element] {
        switch classification {
            case .group:
            return subCategories.filter({
                $0.group == group
            })
        case .category:
            return subCategories.filter({
                $0.group == group &&
                $0.category == category
            })
        case .none:
            return subCategories.filter({_ in true})
        }
    }
    
    private func totalFromList(classification: Classification, isBudgetAmount: Bool) -> Float {
        var totalBudget: Float = 0.00
        for subCategory in subCategoryList(classification: classification) {
            if isBudgetAmount {
                totalBudget += subCategory.userCategory?.budgetAmount ?? Float(0.00)
            }
            else {
                totalBudget += TransactionMethods.getActualSubCategoryTotal(transactions: transactions, subCategory: subCategory)
            }
        }
        return totalBudget
    }
    
    private func subCategoryAmount(isBudgetAmount: Bool) -> Float {
        if isBudgetAmount {
            return subCategories.filter({
                $0.group == group &&
                $0.category == category! &&
                $0.subCategory == subCategory!
            })[0].userCategory?.budgetAmount ?? Float(0.00)
        } else {
            return TransactionMethods.getActualSubCategoryTotal(transactions: transactions, subCategory: subCategories.filter({
                                $0.group == group &&
                                $0.category == category! &&
                                $0.subCategory == subCategory!
                            })[0])
        }
    }
    
    private func fragmentTotal(isBudgetAmount: Bool) -> Float {
        switch classification {
            case .none:
            return totalFromList(classification: .group, isBudgetAmount: isBudgetAmount)
            case .group:
            return totalFromList(classification: .category, isBudgetAmount: isBudgetAmount)
            case .category:
            return subCategoryAmount(isBudgetAmount: isBudgetAmount)
        }
    }
    
    private var fragmentTotal: Float {
        return fragmentTotal(isBudgetAmount: isBudgetAmount)
    }
    
    private var totalAmount: Float {
        return totalFromList(classification: classification, isBudgetAmount: isBudgetAmount)
    }
    
    private var amountTextColor: Color {
        if isBudgetAmount {
            return Color.black
        } else {
            if group == "Savings" {
                if fragmentTotal(isBudgetAmount: false) < fragmentTotal(isBudgetAmount: true) {
                    return Color.red
                } else {
                    return Color.green
                }
            } else {
                if fragmentTotal(isBudgetAmount: true) < fragmentTotal(isBudgetAmount: false) {
                    return Color.red
                } else {
                    return Color.green
                }
            }
        }
    }
    
    private var amountText: String {
        //let amountText = "$\(String(format: "%.2f", fragmentTotal))"
        if isBudgetAmount {
            return "$\(String(format: "%.2f", fragmentTotal))"
        } else {
            let budgetFragmentTotal = fragmentTotal(isBudgetAmount: true)
            let actualFragmentTotal = fragmentTotal(isBudgetAmount: false)
            let amountText = "$\(String(format: "%.2f", Float(abs(actualFragmentTotal - budgetFragmentTotal))))"
            if actualFragmentTotal == budgetFragmentTotal {
                return amountText
            } else if actualFragmentTotal < budgetFragmentTotal {
                return "- \(amountText)"
            } else {
                return "+ \(amountText)"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: UIScreen.main.bounds.height/32) {
            VStack(alignment: .leading) {
                HStack(spacing: UIScreen.main.bounds.width/16) {
                    Rectangle()
                        .frame(width: colorBoxSideLength, height: colorBoxSideLength)
                        .foregroundColor(Color.chartColorList[colorIndex])
                    Text(textName)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                .padding()
            }
            Spacer()
            VStack(alignment: .trailing) {
                HStack(spacing: UIScreen.main.bounds.width/12) {
                    Text(amountText)
                        .font(.caption)
                        .foregroundColor(amountTextColor)
                    Group {
                        if isBudgetAmount {
                            Text("\(String(format: "%.0f", fragmentTotal/totalAmount*100))%")
                                .font(.caption)
                                .foregroundColor(.black)
                        } else {
                            VStack {
                                Text("$\(String(format: "%.2f",  fragmentTotal(isBudgetAmount: true)))")
                                    .font(.caption2)
                                    .foregroundColor(.black)
                                Text("\(String(format: "%.0f", fragmentTotal(isBudgetAmount: true)/totalFromList(classification: classification, isBudgetAmount: true)*100))%")
                                    .font(.caption2)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    
                }
                .padding()
            }
        }
        .frame(width: UIScreen.main.bounds.width*11/12)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .stroke(lineWidth: 2)
                .foregroundColor(.black)
        )

    }
    
}

enum Classification: String {
    case group = "Group"
    case category = "Category"
    case none = "None"
}



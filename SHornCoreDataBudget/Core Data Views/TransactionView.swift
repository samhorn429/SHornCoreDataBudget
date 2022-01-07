//
//  TransactionView.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/27/21.
//

import Foundation
import SwiftUI
import CoreData

enum TransactionFocusField {
    case name
    case merchant
    case amount
    case title
}

struct TransactionRow: View {

    @Environment(\.managedObjectContext) var viewContext
    var transaction: UserTransaction
    
    private var subCategoryActualAmount: Float {
        if transaction.subCategory != nil {
            var actualAmount: Float = 0.00
            for tIndex in 0..<(transaction.subCategory!.transactions?.count ?? 0) {
                actualAmount += (transaction.subCategory!.transactions!.object(at: tIndex) as! UserTransaction).amount
            }
            return actualAmount
        } else {
            return Float(0.00)
        }
    }
    
    private var subCategoryBudgetAmount: Float {
        if transaction.subCategory != nil {
            if transaction.subCategory!.userCategory != nil {
                return transaction.subCategory!.userCategory!.budgetAmount
            } else {
                return Float(0.00)
            }
        } else {
            return Float(0.00)
        }
    }

    private var amountText: String {
        let amountText = "$\(String(format: "%.2f", transaction.amount))"
        if transaction.subCategory != nil {
            if transaction.subCategory!.group! == "Savings" {
                return "+ \(amountText)"
            } else {
                return "- \(amountText)"
            }
        } else {
            return ""
        }
    }

    private var amountTextColor: Color {
        if transaction.subCategory != nil && transaction.subCategory!.group! == "Savings" {
            return Color.green
        } else {
            return Color.red
        }
    }

    private var amountDescriptionText: String {
        let amountText = "$\(String(format: "%.2f", abs(subCategoryActualAmount - subCategoryBudgetAmount)))"
        if transaction.subCategory != nil && transaction.subCategory!.group! == "Savings" {
            if subCategoryActualAmount == subCategoryBudgetAmount {
                return "Savings Goal Reached"
            } else if subCategoryActualAmount < subCategoryBudgetAmount {
                return "\(amountText) from Savings Goal"
            } else {
                return "\(amountText) over Savings Goal"
            }
        } else {
            if subCategoryActualAmount == subCategoryBudgetAmount {
                return "Spending Limit\nReached"
            } else if subCategoryActualAmount < subCategoryBudgetAmount {
                return "\(amountText) from Spending Limit"
            } else {
                return "\(amountText) over the Budget"
            }
        }
    }

    private var amountDescriptionTextColor: Color {
        if transaction.subCategory != nil && transaction.subCategory!.group! == "Savings" {
            if subCategoryActualAmount < subCategoryBudgetAmount {
                return Color.black
            } else {
                return Color.green
            }
        } else {
            if subCategoryActualAmount == subCategoryBudgetAmount {
                return Color.green
            } else if subCategoryActualAmount < subCategoryBudgetAmount {
                return Color.black
            } else {
                return Color.red
            }
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.name ?? "")
                    .font(Font.headline)
                Text(transaction.merchant ?? "")
                Text("\(transaction.subCategory?.category ?? "") - \(transaction.subCategory?.subCategory ?? "")")
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                Spacer()
                Text(amountText)
                    .foregroundColor(amountTextColor)
                Text(amountDescriptionText)
                    .foregroundColor(amountDescriptionTextColor)
            }
        }
    }
}

struct TransactionView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    var transactions: FetchedResults<UserTransaction>
    var subCategories: FetchedResults<SubCategoryMO>
    @EnvironmentObject var budgetDateManager: BudgetMonthAndYearManager
    @State var showNewTransactionDialog: Bool = false
    @State var titleText: String = ""
    @State var merchantText: String = ""
    @State var subCategory: SubCategoryMO? = nil
    @State var subCatIndex: Int = 0;
    @State var transactionDate = Date()
    @State var amountText: String = ""
    @FocusState var focusField: TransactionFocusField?
    @State var showTitleAlert: Bool = false
    @State var showMerchantAlert: Bool = false
    @State var showAmountAlert: Bool = false
    @State var showCategoryAlert: Bool = false
    @State var unusedCategoryAlert: Bool = false
    @State var wrongMonthAndYearAlert: Bool = false
    @AppStorage("gitErDone") var gitErDone: Bool = true
    
    var datesList: [Date] {
        var datesList = Array<Date>()
        for transaction in transactions {
            if transaction.date != nil && !datesList.contains(where: {
                transaction.date!.dayEqual($0)
            }) {
                datesList.append(transaction.date!)
            }
        }
        return datesList
    }
    
    func datesIndex(date: Date) -> Int {
        return datesList.firstIndex(where: {
            date.id == $0.id
        }) ?? 0
    }
    var datesListIndices: Range<Int> {
        return datesList.indices
    }
    
    var sortedByDateTransactions: [String: [UserTransaction]] {
        return Dictionary(grouping: transactions) {transaction in
            getDateString(transaction.date ?? Date())
        }
    }
    
    var dateSections: [String] {
        return sortedByDateTransactions.keys.sorted(by: {a, b in
            stringToDate(a) > stringToDate(b)
        })
    }
    
    func subCategoryChange(_ subCategory: SubCategoryMO) {
        self.subCategory = subCategory
    }
    
    private var sortedSubCategories: [FetchedResults<SubCategoryMO>.Element] {
        var categoryDict = Dictionary<String, Array<FetchedResults<SubCategoryMO>.Element>>()
        
        for subCategory in subCategories {
            if categoryDict[subCategory.category ?? ""] == nil {
                categoryDict[subCategory.category ?? ""] = Array<FetchedResults<SubCategoryMO>.Element>()
            }
            categoryDict[subCategory.category ?? ""]!.append(subCategory)
        }
        
        var finalArr = Array<FetchedResults<SubCategoryMO>.Element>()
        var catKeys = Array<String>(categoryDict.keys)
        let sortedCatKeys = catKeys.sorted()
        for catKey in sortedCatKeys {
            let sortedCatList = categoryDict[catKey]!.sorted(by: {a, b in
                a.subCategory ?? "" < b.subCategory ?? ""
            })
            for subCategory in sortedCatList {
                finalArr.append(subCategory)
            }
        }
        
        return finalArr
    }
    
    private func getSubCatIndex(transaction: UserTransaction) -> Int {
        return sortedSubCategories.firstIndex(where: {
            $0.id == transaction.scid
        }) ?? 0
    }
    
    private func getDateString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func stringToDate(_ string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.date(from: string) ?? Date()
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dateSections, id: \.self) {dateString in
                    Section(header: Text(dateString)) {
                        ForEach(sortedByDateTransactions[dateString]!) {transaction in
                            TransactionRow(transaction: transaction)
                                .environment(\.managedObjectContext, viewContext)
                        }
                        .onDelete(perform: {offsets in
                            for index in offsets {
                                let transaction = sortedByDateTransactions[dateString]?[index]
                                if transaction != nil {
                                    viewContext.delete(transaction!)
                                }
                            }
                            
                            do {
                                try viewContext.save()
                            } catch {
                                print(error)
                            }
                        })
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Spending")
        .listStyle(GroupedListStyle())
        .navigationBarItems(
            trailing:
                Button(action: {
                    showNewTransactionDialog = true
                }) {
                    Text("Add Purchase")
                }
        )
        .sheet(isPresented: $showNewTransactionDialog, onDismiss: {}) {
            Form {
                    Text("Transaction Name")
                        .bold()
                        .font(.title2)
                    TextField("Transaction Name", text: $titleText)
                        .focused($focusField, equals: .name)
                    Text("Merchant")
                        .bold()
                        .font(.title2)
                    TextField("Merchant", text: $merchantText)
                        .focused($focusField, equals: .merchant)
                    Text("Category")
                        .bold()
                        .font(.title2)
                Picker("Categories", selection: $subCatIndex) {
                    ForEach(sortedSubCategories.indices) {index in
                            Text("\(sortedSubCategories[index].category ?? "") - \(sortedSubCategories[index].subCategory ?? "")").tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: subCatIndex) {subCatIndex in
                        self.subCategory = sortedSubCategories[subCatIndex]
                    }
                    Text("Amount")
                        .bold()
                        .font(.title2)
                    TextField("Amount", text: $amountText)
                        .focused($focusField, equals: .amount)
               Group {
                    Text("Date of Transaction")
                        .bold()
                        .font(.title2)
                    DatePicker("Transaction Date", selection: $transactionDate, displayedComponents: [.date])
               }

                    Button(action: {
                        submitTransactions()
                    }) {
                        SetBudgetButtonBackground(text: "Submit Transaction")
                    }
                
            }
            .alert("Please Enter Transaction Name", isPresented: $showTitleAlert, actions: {})
            .alert("Please Enter Merchant Name", isPresented: $showMerchantAlert, actions: {})
            .alert("Please Enter Valid Transaction Amount Greater Than Zero", isPresented: $showAmountAlert, actions: {})
            .alert("Please Select a Category", isPresented: $showCategoryAlert, actions: {})
            .alert("The Selected Category is not a part of the Budget", isPresented: $unusedCategoryAlert, actions: {})
            .alert("The Date of the Transaction must be within the Budget Month and Year", isPresented: $wrongMonthAndYearAlert, actions: {})
        }
        
    }
    
    
    func submitTransactions() {
        if titleText != "" {
            if merchantText != "" {
                if subCategory != nil {
                    if let floatAmount = Float(amountText) {
                        if floatAmount < 0.00 {
                            showAmountAlert = true
                            focusField = .amount
                        } else {
                            if subCategory!.userCategory == nil {
                                unusedCategoryAlert = true
                            } else {
                                if !(CurrentDateFunctions.currentMonth == budgetDateManager.recentBudgetMonth
                                     && CurrentDateFunctions.currentYear == budgetDateManager.recentBudgetYear) {
                                    wrongMonthAndYearAlert = true
                                } else {
                                    
                                    
                                    let newTransaction = UserTransaction(context: viewContext)
                                    newTransaction.tid = UUID()
                                    newTransaction.amount = floatAmount
                                    newTransaction.date = transactionDate
                                    newTransaction.merchant = merchantText
                                    newTransaction.scid = subCategory!.id
                                    newTransaction.name = titleText
                                    newTransaction.subCategory = subCategory
                                    
                                    subCategory!.addToTransactions(newTransaction)
                                    
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        print(error)
                                    }

                                    titleText = ""
                                    amountText = ""
                                    subCategory = nil
                                    merchantText = ""
                                    transactionDate = Date()
                                    showNewTransactionDialog = false
                                }
                            }
                        }
                    } else {
                        showAmountAlert = true
                        focusField = .amount
                    }
                } else {
                    showCategoryAlert = true
                }
            } else {
                showMerchantAlert = true
                focusField = .merchant
            }
        } else {
            showTitleAlert = true
            focusField = .title
        }
    }
}

extension Date: Identifiable {
    public var id: UUID {
        return UUID()
    }
    func dayEqual(_ date: Date) -> Bool {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        let date1Month = monthFormatter.string(from: self)
        let date2Month = monthFormatter.string(from: date)
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let date1Year = yearFormatter.string(from: self)
        let date2Year = yearFormatter.string(from: date)
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let date1Day = dayFormatter.string(from: self)
        let date2Day = dayFormatter.string(from: date)
        
        return date1Month == date2Month &&
            date1Year == date2Year &&
            date1Day == date2Day
    }
}

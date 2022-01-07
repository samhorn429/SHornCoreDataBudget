//
//  Transactions.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/21/21.
//

import Foundation
import SwiftUI
import CoreData

//enum TransactionFocusField {
//    case name
//    case merchant
//    case amount
//}
//
//struct TransactionRow: View {
//
//
//    var transaction: UserTransaction
//
//    private var amountText: String {
//        let amountText = "$\(String(format: "%.2f", transaction.amount))"
//        if transaction.subCategory!.group! == "Savings" {
//            return "+ \(amountText)"
//        } else {
//            return "- \(amountText)"
//        }
//    }
//
//    private var amountTextColor: Color {
//        if transaction.subCategory!.group! == "Savings" {
//            return Color.green
//        } else {
//            return Color.red
//        }
//    }
//
//    private var amountDescriptionText: String {
//        let amountText = "$\(String(format: "%.2f", abs(transaction.subCategoryAmount - transaction.subCategoryBudget)))"
//        if transaction.subCategory!.group! == "Savings" {
//            if transaction.subCategoryAmount == transaction.subCategoryBudget {
//                return "Savings Goal Reached"
//            } else if transaction.subCategoryAmount < transaction.subCategoryBudget {
//                return "\(amountText) from Savings Goal"
//            } else {
//                return "\(amountText) over Savings Goal"
//            }
//        } else {
//            if transaction.subCategoryAmount == transaction.subCategoryBudget {
//                return "Spending Limit Reached"
//            } else if transaction.subCategoryAmount < transaction.subCategoryBudget {
//                return "\(amountText) from Spending Limit"
//            } else {
//                return "\(amountText) over the Budget"
//            }
//        }
//    }
//
//    private var amountDescriptionTextColor: Color {
//        if transaction.subCategory!.group! == "Savings" {
//            if transaction.subCategoryAmount < transaction.subCategoryBudget {
//                return Color.black
//            } else {
//                return Color.green
//            }
//        } else {
//            if transaction.subCategoryAmount == transaction.subCategoryBudget {
//                return Color.green
//            } else if transaction.subCategoryAmount < transaction.subCategoryBudget {
//                return Color.black
//            } else {
//                return Color.red
//            }
//        }
//    }
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text(transaction.name!)
//                    .font(Font.headline)
//                Text(transaction.merchant!)
//                Text("\(transaction.subCategory!.category!) - \(transaction.subCategory!.subCategory!)")
//            }
//            VStack(alignment: .trailing) {
//                Text(amountText)
//                    .foregroundColor(amountTextColor)
//                Text(amountDescriptionText)
//                    .foregroundColor(amountDescriptionTextColor)
//            }
//        }
//    }
//}
//
//struct TransactionView: View {
//    @Environment(\.managedObjectContext) var viewContext
//    var transactions: FetchedResults<UserTransaction>
//    var subCategories: FetchedResults<SubCategoryMO>
//    @State var showNewTransactionDialog: Bool = false
//    @State var titleText: String = ""
//    @State var merchantText: String = ""
//    @State var subCategory: SubCategoryMO? = nil
//    @State var transactionDate: Date = Date()
//    @State var amountText: String = ""
//    @FocusState var focusField: TransactionFocusField?
//    @State var showTitleAlert: Bool = false
//    @State var showMerchantAlert: Bool = false
//    @State var showAmountAlert: Bool = false
//    @State var showCategoryAlert: Bool = false
//    @State var unusedCategoryAlert: Bool = false
//
//    var datesList: [Date] {
//        var datesList = Array<Date>()
//        for transaction in transactions {
//            if !datesList.contains(transaction.date!) {
//                datesList.append(transaction.date!)
//            }
//        }
//        return datesList
//    }
//
//
//
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(datesList.indices) {dateIndex in
//                    Section(header: Text(String(datesList[dateIndex]))) {
//                        ForEach(transactions.filter({
//                            $0.date == datesList[dateIndex]
//                        })) {transaction in
//                            TransactionRow(transaction: transaction)
//                        }
//                    }
//                }
//            }
//            //EmptyView()
//            .sheet(isPresented: $showNewTransactionDialog, onDismiss: {}) {
//                Form {
//                    VStack {
//                        Text("Transaction Name")
//                            .bold()
//                            .font(.title2)
//                        TextField("Transaction Name", text: $titleText)
//                            .focused($focusField, equals: .name)
//                    }
//
//                    VStack {
//                        Text("Merchant")
//                            .bold()
//                            .font(.title2)
//                        TextField("Merchant", text: $merchantText)
//                            .focused($focusField, equals: .merchant)
//                    }
//
//                    VStack {
//                        Text("Date of Transaction")
//                            .bold()
//                            .font(.title2)
//                        DatePicker("Transaction Date", selection: $transactionDate, displayedComponents: [.date])
//                    }
//
//                    VStack {
//                        Text("Category")
//                            .bold()
//                            .font(.title2)
//                        Picker("Categories", selection: $subCategory) {
//                            ForEach(subCategories) {subCategory in
//                                Text("\(subCategory.category!) - \(subCategory.subCategory!)")
//                            }
//                        }
//                    }
//
//                    VStack {
//                        Text("Amount")
//                            .bold()
//                            .font(.title2)
//                        TextField("Amount", text: $amountText)
//                            .focused($focusField, equals: .amount)
//                    }
//
//                    Button(action: {
//                        if titleText != "" {
//                            if merchantText != "" {
//                                if subCategory != nil {
//                                    if let floatAmount = Float(amountText) {
//                                        if floatAmount < 0.00 {
//                                            showAmountAlert = true
//                                            focusField = .amount
//                                        } else {
//                                            if subCategory.userCategory == nil {
//                                                unusedCategoryAlert = true
//                                            } else {
//                                                let newTransaction = UserTransaction(context: viewContext)
//                                                newTransaction.tid = UUID()
//                                                newTransaction.amount = floatAmount
//                                                newTransaction.date = transactionDate
//                                                newTransaction.merchant = merchantText
//                                                newTransaction.scid = subCategory!.id
//                                                newTransaction.name = titleText
//                                                subCategory.userCategory!.actualAmount += floatAmount
//                                                newTransaction.subCategoryAmount = subCategory.userCategory!.actualAmount
//                                                newTransaction.subCategoryBudget = subCategory.userCategory!.budgetAmount
//                                                newTransaction.subCategory = subCategory
//
//                                                do {
//                                                    try viewContext.save()
//                                                } catch {
//                                                    print(error)
//                                                }
//
//                                                titleText = ""
//                                                amountText = ""
//                                                subCategory = nil
//                                                merchantText = ""
//                                                transactionDate = Date()
//                                                showNewTransactionDialog = false
//                                            }
//                                        }
//                                    } else {
//                                        showAmountAlert = true
//                                        focusField = .amount
//                                    }
//                                } else {
//                                    showCategoryAlert = true
//                                }
//                            } else {
//                                showMerchantAlert = true
//                                focusField = .merchant
//                            }
//                        } else {
//                            showTitleAlert = true
//                            focusField = .title
//                        }
//                    }) {
//                        SetBudgetButtonBackground(text: "Submit Transaction")
//                    }
//                }
//                .alert("Please Enter Transaction Name", isPresented: $showTitleAlert)
//                .alert("Please Enter Merchant Name", isPresented: $showMerchantAlert)
//                .alert("Please Enter Valid Transaction Amount Greater Than Zero", isPresented: $showAmountAlert)
//                .alert("Please Select a Category", isPresented: $showCategoryAlert)
//                .alert("The Selected Category is not a part of the Budget", isPresented: $unusedCategoryAlert)
//            }
//        }
//        .navigationBarTitle("Spending")
//        .listStyle(GroupedListStyle())
//        .navigationBarItems(
//            trailing:
//                Button(action: {
//                    showNewTransactionDialog=true
//                }) {
//                    Text("Add Purchase")
//                }
//        )
//
//    }
//}

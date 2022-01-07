//
//  View Extensions.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/17/21.
//

import Foundation
import SwiftUI
import CoreData

//extension View {
////    struct IncomeAddTextAlert<ViewPresented>: View where ViewPresented: View {
////             
////            @Environment(\.managedObjectContext) var viewContext
////            @Binding var showAddConfirmDialog: Bool
////            @Binding var titleText: String
////            @Binding var amountText: String
////            let viewPresented: ViewPresented
////            private let title = "Create New Pay Check"
////            @FocusState var focusedOnTitle: Bool?
////            @State var showInvalidTitleInputAlert: Bool = false
////            @State var showInvalidAmountInputAlert: Bool = false
////            
////            var body: some View {
////                GeometryReader { (deviceSize: GeometryProxy) in
////                    ZStack {
////                        self.viewPresented
////                            .disabled(showAddConfirmDialog)
////                        VStack {
////                            Text(title)
////                            TextField("title", text: $titleText)
////                                .focused($focusedOnTitle, equals: true)
////                            TextField("amount", text: $amountText)
////                                .focused($focusedOnTitle, equals: false)
////        //                        .onSubmit {
////        //                            validateAmountInput()
////        //                        }
////        //                        .onChange(of: focusedOnTitle) {focusedOnTitle in
////        //                            if focusedOnTitle != nil {
////        //                                validateAmountInput()
////        //                            }
////        //                        }
////                            Divider()
////                            HStack {
////                                Button(action: {
////                                    if titleText != "" {
////                                        if let floatIncomeAmount = Float(amountText) {
////                                            if floatIncomeAmount <= 0.00 {
////                                                showInvalidAmountInputAlert = true
////                                                focusedOnTitle = false
////                                            }
////                                            else {
////                                                let newIncome = PayCheckMO(context: viewContext)
////                                                newIncome.pcid = UUID()
////                                                newIncome.date = Date()
////                                                newIncome.amount = floatIncomeAmount
////                                                newIncome.title = titleText
////                                                
////                                                do {
////                                                    try viewContext.save()
////                                                } catch {
////                                                    print(error)
////                                                }
////                                                
////                                                showAddConfirmDialog = false
////                                            }
////                                        } else {
////                                            showInvalidAmountInputAlert = true
////                                            focusedOnTitle = false
////                                        }
////                                    } else {
////                                        showInvalidTitleInputAlert = true
////                                        focusedOnTitle = true
////                                    }
////                                    
////                                }) {
////                                    Text("Add")
////                                }
////                                Divider()
////                                Button(action: {
////                                            
////                                }) {
////                                    Text("Dismiss")
////                                }
////                            }
////                        }
////                        .padding()
////                        .background(Color.white)
////                        .frame(
////                            width: deviceSize.size.width*0.7,
////                            height: deviceSize.size.height*0.7
////                        )
////                        .shadow(radius: 1)
////                        .opacity(self.showAddConfirmDialog ? 1 : 0)
////                    }
////                }
////                .alert("Please Enter a Valid Title", isPresented: $showInvalidTitleInputAlert, actions: {})
////                .alert("Please Enter a Valid Amount Greater Than Zero", isPresented: $showInvalidAmountInputAlert, actions: {})
////            }
////        }
//
//    
//    func incomeAddTextAlert(viewContext: NSManagedObjectContext,
//                            showAddConfirmDialog: Binding<Bool>,
//                            titleText: Binding<String>,
//                            amountText: Binding<String>) -> some View {
//        IncomeAddTextAlert(showAddConfirmDialog: showAddConfirmDialog,
//                            titleText: titleText,
//                            amountText: amountText,
//                            viewPresented: self)
//            .environment(\.managedObjectContext, viewContext)
//            
//    }
    
//    struct IncomeAddTextAlert<ViewPresented>: View where ViewPresented: View {
//
//        @Environment(\.managedObjectContext) var viewContext
//        @Binding var showAddConfirmDialog: Bool
//        @Binding var titleText: String
//        @Binding var amountText: String
//        let viewPresented: ViewPresented
//        private let title = "Create New Pay Check"
//        @FocusState var focusedOnTitle: Bool?
//        @State var showInvalidTitleInputAlert: Bool = false
//        @State var showInvalidAmountInputAlert: Bool = false
//
//        var body: some View {
//            GeometryReader { (deviceSize: GeometryProxy) in
//                ZStack {
//                    self.viewPresented
//                        .disabled(showAddConfirmDialog)
//                    VStack {
//                        Text(title)
//                        TextField("title", text: $titleText)
//                            .focused($focusedOnTitle, equals: true)
//                        TextField("amount", text: $amountText)
//                            .focused($focusedOnTitle, equals: false)
//    //                        .onSubmit {
//    //                            validateAmountInput()
//    //                        }
//    //                        .onChange(of: focusedOnTitle) {focusedOnTitle in
//    //                            if focusedOnTitle != nil {
//    //                                validateAmountInput()
//    //                            }
//    //                        }
//                        Divider()
//                        HStack {
//                            Button(action: {
//                                if titleText != "" {
//                                    if let floatIncomeAmount = Float(amountText) {
//                                        if floatIncomeAmount <= 0.00 {
//                                            showInvalidAmountInputAlert = true
//                                            focusedOnTitle = false
//                                        }
//                                        else {
//                                            let newIncome = PayCheckMO(context: viewContext)
//                                            newIncome.pcid = UUID()
//                                            newIncome.date = Date()
//                                            newIncome.amount = floatIncomeAmount
//                                            newIncome.title = titleText
//
//                                            do {
//                                                try viewContext.save()
//                                            } catch {
//                                                print(error)
//                                            }
//
//                                            showAddConfirmDialog = false
//                                        }
//                                    } else {
//                                        showInvalidAmountInputAlert = true
//                                        focusedOnTitle = false
//                                    }
//                                } else {
//                                    showInvalidTitleInputAlert = true
//                                    focusedOnTitle = true
//                                }
//
//                            }) {
//                                Text("Add")
//                            }
//                            Divider()
//                            Button(action: {
//
//                            }) {
//                                Text("Dismiss")
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color.white)
//                    .frame(
//                        width: deviceSize.size.width*0.7,
//                        height: deviceSize.size.height*0.7
//                    )
//                    .shadow(radius: 1)
//                    .opacity(self.showAddConfirmDialog ? 1 : 0)
//                }
//            }
//            .alert("Please Enter a Valid Title", isPresented: $showInvalidTitleInputAlert, actions: {})
//            .alert("Please Enter a Valid Amount Greater Than Zero", isPresented: $showInvalidAmountInputAlert, actions: {})
//        }
//    }


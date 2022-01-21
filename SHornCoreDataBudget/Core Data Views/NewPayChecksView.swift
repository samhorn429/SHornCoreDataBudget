//
//  NewPayChecksView.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 1/18/22.
//

import Foundation
import SwiftUI
import CoreData

struct NewPayChecksView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var payChecks: FetchedResults<PayCheckMO>
    @State var titleText: String = ""
    @State var amountText: String = ""
    @State var payCheckDate: Date = Date()
    @FocusState var isFocusedOnTitle: Bool?
    @State var showNewPayCheckTitleAlert: Bool = false
    @State var showNewPayCheckAmountAlert: Bool = false
    var isNewPayCheck: Bool
    
    var body: some View {
        NavigationView {
            Form {
                VStack {
                    Text("PayCheck Name:")
                        .bold()
                        .font(.title2)
                    TextField("PayCheck Name", text: $titleText)
                        .focused($isFocusedOnTitle, equals: true)
                }
                
                VStack {
                    Text("PayCheck Amount:")
                        .bold()
                        .font(.title2)
                    TextField("PayCheck Amount", text: $amountText)
                        .focused($isFocusedOnTitle, equals: false)
                }
                
                VStack {
                    Text("Date of Payment:")
                        .bold()
                        .font(.title2)
                    DatePicker("PayCheck Date", selection: $payCheckDate, displayedComponents: [.date])
                }
            }
            .navigationBarTitle("Create New Paycheck",
                displayMode: .inline)
            
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(
                leading:
                    Button("Cancel", action: {
                        presentationMode.wrappedValue.dismiss()
                    }),
                trailing:
                    Group {
                        if isNewPayCheck {
                            Button("Save", action: {
                                if titleText != "" {
                                    if let floatNewPayCheckAmount = Float(amountText) {
                                        if floatNewPayCheckAmount <= 0.00 {
                                            showNewPayCheckAmountAlert = true
                                            isFocusedOnTitle = false
                                        } else {
                                            let newPayCheck = PayCheckMO(context: viewContext)
                                            newPayCheck.pcid = UUID()
                                            newPayCheck.title = titleText
                                            newPayCheck.amount = floatNewPayCheckAmount
                                            newPayCheck.date = payCheckDate

                                            titleText = ""
                                            amountText = ""
                                            payCheckDate = Date()
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    } else {
                                        showNewPayCheckAmountAlert = true
                                        isFocusedOnTitle = false
                                    }
                                } else {
                                    showNewPayCheckTitleAlert = true
                                    isFocusedOnTitle = true
                                }
                            })
                        } else {
                            Menu {
                                Button("Save Pay Check", action: {
                                    if titleText != "" {
                                        if let floatNewPayCheckAmount = Float(amountText) {
                                            if floatNewPayCheckAmount <= 0.00 {
                                                showNewPayCheckAmountAlert = true
                                                isFocusedOnTitle = false
                                            } else {
                                                let newPayCheck = PayCheckMO(context: viewContext)
                                                newPayCheck.pcid = UUID()
                                                newPayCheck.title = titleText
                                                newPayCheck.amount = floatNewPayCheckAmount
                                                newPayCheck.date = payCheckDate

                                                titleText = ""
                                                amountText = ""
                                                payCheckDate = Date()
                                                presentationMode.wrappedValue.dismiss()
                                            }
                                        } else {
                                            showNewPayCheckAmountAlert = true
                                            isFocusedOnTitle = false
                                        }
                                    } else {
                                        showNewPayCheckTitleAlert = true
                                        isFocusedOnTitle = true
                                    }
                                })
                                
                                Button("Delete PayCheck", action: {
                                    //ViewContext.delete(p)
                                })
                            } label: {
                                Image(systemName: "line.horizontal.3")
                                    .imageScale(.large)
                            }
                        }
                    }
            )
        }
        .navigationBarBackButtonHidden(true)
    }
}

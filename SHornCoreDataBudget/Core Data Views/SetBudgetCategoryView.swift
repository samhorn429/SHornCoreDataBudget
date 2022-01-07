//
//  SetBudgetCategoryView.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/18/21.
//

import Foundation
import SwiftUI
import CoreData

struct BudgetCategoryView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var navBarHidden: Bool
    var subCategories: FetchedResults<SubCategoryMO>
    @FetchRequest(
        entity: UserCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \UserCategory.ucid, ascending: true)],
        animation: .default)
    var userCategories: FetchedResults<UserCategory>
    var category: Category
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var budgetManager: BudgetCategoriesManager
    @EnvironmentObject var ucSubmitManager: UserCategorySubmitManager
    @FocusState var focusSubCategory: String?
    @Binding var toolBarButtonsHidden: Bool
    @State var buttonPressed: Bool = false
    
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(subCategories.filter{
                    $0.category == category.category &&
                    $0.group == category.group
                }) {
                    subCategory in
                    SubCategoryView(
                        subCategory: subCategory,
                        budgetAmountText: "\(subCategory.userCategory?.budgetAmount ?? 0.00)",
                        focusSubCategory: _focusSubCategory
                    )
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(ucSubmitManager)
                }
                HStack {
                    Spacer()
                    Button(action: {
                        for scid in ucSubmitManager.ucBudgetDict.keys {
                            let subCategory = subCategories.first(where: {
                                $0.id == scid
                            })!
                            if ucSubmitManager.ucBudgetDict[scid]! > 0.00 {

                                if let _ = subCategory.userCategory {
                                    subCategory.userCategory!.budgetAmount = ucSubmitManager.ucBudgetDict[scid]!
                                } else {
                                    let userCategory = UserCategory(context: viewContext)
                                    userCategory.ucid = UUID()
                                    userCategory.scid = subCategory.id
                                    userCategory.budgetAmount = ucSubmitManager.ucBudgetDict[scid]!
                                    userCategory.actualAmount = Float(0.00)
                                    userCategory.date = Date()
                                    subCategory.userCategory = userCategory
                                    userCategory.subCategory = subCategory
                                }
                            } else {
                                if let _ = subCategory.userCategory {
                                    viewContext.delete(subCategory.userCategory!)
                                }
                            }
                        }
                        ucSubmitManager.ucBudgetDict.removeAll()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        SetBudgetButtonBackground(text: "Submit Entries")
                    }
                    Spacer()
                }
            }
            .navigationBarTitle("Set Budget For \(category.category)", displayMode: .inline)
            .navigationViewStyle(StackNavigationViewStyle())
            //.navigationBarHidden(navBarHidden)
//            .navigationBarItems(leading:
//                                    Button("Blah Blah") {}
//            )
            .onAppear {
                navBarHidden = true
            }
            
        }
        //.navigationBarHidden(navBarHidden)
        //.navigationBarTitle("Set Budget For \(category.category)", displayMode: .inline)
        //.navigationBarTitle("Set Budget For \(category.category)", displayMode: .inline)
        
    }
}

struct SubCategoryView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    var subCategory: SubCategoryMO
    @EnvironmentObject var ucSubmitManager: UserCategorySubmitManager
    @State var budgetAmountText: String
    @FocusState var focusSubCategory: String?
    @State var showInvalidInputAlert: Bool = false
    
    var body: some View {
        VStack {
            Text("\(subCategory.subCategory ?? ""):")
                .bold()
                .font(.title2)
            TextField(subCategory.subCategory ?? "", text: $budgetAmountText)
                .focused($focusSubCategory, equals: subCategory.subCategory ?? "")
                .onChange(of: focusSubCategory) {focusSubCategory in
                    if focusSubCategory != nil {
                        validateInputAndSetToDict()
                    }
                }
                .onSubmit {
                    validateInputAndSetToDict()
                }
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .alert("Please Enter a Valid Input", isPresented: $showInvalidInputAlert, actions: {})
    }
    func validateInputAndSetToDict() {
        if let floatBudgetAmount = Float(budgetAmountText) {
            ucSubmitManager.ucBudgetDict[subCategory.id!] = floatBudgetAmount
            if floatBudgetAmount < 0.00 {
                showInvalidInputAlert = true
                focusSubCategory = subCategory.subCategory
            }
        } else if budgetAmountText == "" {
            budgetAmountText = "\(0.00)"
            ucSubmitManager.ucBudgetDict[subCategory.id!] = Float(budgetAmountText)
        } else {
            showInvalidInputAlert = true
            focusSubCategory = subCategory.subCategory
        }
    }
}

struct SetBudgetButtonBackground: View {
    var text: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ViewConstants.finishedButtonCornerRadius)
                .fill(.gray)
                .frame(width: ViewConstants.finishedButtonWidth, height: ViewConstants.finishedButtonHeight)
            Text(text)
                .font(Font.caption)
                .foregroundColor(.black)
                .bold()
        }
    }
}

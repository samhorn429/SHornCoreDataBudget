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
    @FocusState var focusSubCategory: UUID?
    @Binding var toolBarButtonsHidden: Bool
    @State var buttonPressed: Bool = false
    @State var showMenu: Bool = false
    
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
                        budgetAmountText: MoneyValueText(subCategory: subCategory),
                        focusSubCategory: _focusSubCategory
                    )
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .navigationBarTitle("Set Budget For \(category.category)", displayMode: .inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                navBarHidden = true
            }
        }
    }
}

struct SubCategoryView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    var subCategory: SubCategoryMO
    @State var budgetAmountText: MoneyValueText
    @FocusState var focusSubCategory: UUID?
    @State var showInvalidInputAlert: Bool = false
    
    var body: some View {
        let floatAmount = Binding<String>(get: {
            budgetAmountText.value
        }, set: {
            budgetAmountText.value = $0
            
            let floatBudget = Float(budgetAmountText.value) ?? 0.00
            if floatBudget > 0.00 {
                
                if let _ = subCategory.userCategory {
                    subCategory.userCategory!.budgetAmount = floatBudget
                } else {
                    let userCategory = UserCategory(context: viewContext)
                    userCategory.ucid = UUID()
                    userCategory.scid = subCategory.id
                    userCategory.budgetAmount = floatBudget
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
            
        })
        
        VStack {
            Text("\(subCategory.subCategory ?? ""):")
                .bold()
                .font(.title2)
            TextField(subCategory.subCategory ?? "", text: floatAmount)
                .focused($focusSubCategory, equals: subCategory.id ?? nil)
//                .onChange(of: focusSubCategory) {focusSubCategory in
//                    if focusSubCategory != nil {
//                        validateInputAndSetToDict()
//                    }
//                }
//                .onReceive(budgetAmountText.publisher.last())//(budgetAmountText.publisher.last()) {
//                {
//                    if focusSubCategory != nil {
//                        validateInputAndSetToDict()
//                    }
//                }
//                .onSubmit {
//                    validateInputAndSetToDict()
//                }
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .alert("Please Enter a Valid Input", isPresented: $showInvalidInputAlert, actions: {})
    }
//    func validateInputAndSetToDict() {
//        if let floatBudgetAmount = Float(budgetAmountText) {
//            ucSubmitManager.ucBudgetDict[subCategory.id!] = floatBudgetAmount
//            if floatBudgetAmount < 0.00 {
//                showInvalidInputAlert = true
//                focusSubCategory = subCategory.id
//            }
//        } else if budgetAmountText == "" {
//            budgetAmountText = "\(0.00)"
//            ucSubmitManager.ucBudgetDict[subCategory.id!] = Float(budgetAmountText)
//        } else {
//            showInvalidInputAlert = true
//            focusSubCategory = subCategory.id
//        }
//    }
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

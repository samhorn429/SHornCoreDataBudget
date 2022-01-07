//
//  SetBudgetView.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/10/21.
//

import Foundation
import SwiftUI
import CoreData

struct SetBudgetView: View {
    @Environment(\.managedObjectContext) var viewContext
    let subCategoryEntity = SubCategoryMO.entity()
    @FetchRequest(
        entity: SubCategoryMO.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SubCategoryMO.group, ascending: true)],
        animation: .default)
    var subCategories: FetchedResults<SubCategoryMO>
    
    @AppStorage("isInitialSubCategories") var isInitialSubCategories = true
    @EnvironmentObject var budgetManager: BudgetCategoriesManager
    @EnvironmentObject var ucBudgetManager: UserCategoryBudgetManager
    @EnvironmentObject var payCheckManager: PayCheckManager
    @State var managersPopulated = false
    
    private func populateManagers() {
        for group in budgetManager.groups {
            ucBudgetManager.userCategoryBudgetDict[group] = Dictionary<String, Dictionary<String, Float>>()
            ucBudgetManager.userCategoryBudgetTotals[group] = Dictionary<String, Float>()
        }
        for category in budgetManager.categories {
            ucBudgetManager.userCategoryBudgetDict[category.group]![category.category] = Dictionary<String, Float>()
            ucBudgetManager.userCategoryBudgetTotals[category.group]![category.category] = 0.00
        }
    }
    
    //private func
    
    var body: some View {
        
        return NavigationView {

                List {
//                    Section(header: Text("")) {
//                        EmptyView()
//                    }
                    Section(header: Text("Income")) {
//                        Button(action: {}) {
//                            Image(systemName: "plus")
//                        }
                        //DisclosureGroup()
                        IncomeDisclosureGroup()
                            .environment(\.managedObjectContext, viewContext)
                            .environmentObject(payCheckManager)
                    }
                    .navigationBarItems(
                        trailing:
                            Button(action: {}) {
                                Image(systemName: "plus")
                            }
                    )
                    ForEach(budgetManager.groups.indices) {groupIndex in
                        Section(header: Text(budgetManager.groups[groupIndex])) {
                            ForEach(budgetManager.categories.filter({$0.group == budgetManager.groups[groupIndex]})) {category in
                                CategoryDisclosureGroup(category: category, subCategories: subCategories)
                                    .environment(\.managedObjectContext, viewContext)
                                    .environmentObject(ucBudgetManager)
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .onAppear {
                if !managersPopulated {
                    populateManagers()
                    managersPopulated = true
                }
                if isInitialSubCategories {
                    for subCategory in budgetManager.scManager.subCategories {
                        withAnimation {
                            let newSubCategory = SubCategoryMO(context: viewContext)
                            newSubCategory.id = subCategory.id
                            newSubCategory.subCategory = subCategory.subCategory
                            newSubCategory.category = subCategory.category
                            newSubCategory.group = subCategory.group
                            
                            do {
                                try viewContext.save()
                            }
                            catch {
                                print(error)
                            }
                        }
                    }
                    isInitialSubCategories = false
                }
            }
            .navigationBarTitle("Set Budget")
            
}

struct IncomeDisclosureGroup: View {
      
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        entity: PayCheckMO.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \PayCheckMO.pcid, ascending: true)],
        animation: .default
    ) var payChecks: FetchedResults<PayCheckMO>
    @EnvironmentObject var payCheckManager: PayCheckManager
    @FocusState var focusIncomeId: UUID?
    //@State var payChecksPopulated: Bool = false
    @State var showAddConfirmDialog: Bool = false
    @State var titleText: String = ""
    @State var amountText: String = ""
    @State var payCheckDate: Date = Date()
    @FocusState var isFocusedOnTitle: Bool?
    @State var showNewPayCheckTitleAlert: Bool = false
    @State var showNewPayCheckAmountAlert: Bool = false
    
//    private func populatePayChecks() {
//        for payCheck in payChecks {
//            payCheckManager.payCheckList.append(PayCheck(
//                id: payCheck.pcid!,
//                amount: payCheck.amount,
//                date: payCheck.date ?? Date(),
//                title: payCheck.title ?? "")
//            )
//        }
//    }
    
    
    var body : some View {
        
        DisclosureGroup("Income") {
            ScrollView {
                VStack {
                    ForEach(payChecks) {payCheck in
                        IncomeEntryView(
                            payCheck: payCheck,
                            incomeAmountText: "\(payCheck.amount)",
                            focusIncomeId: _focusIncomeId
                        )
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(payCheckManager)
                    }
                    
                    HStack {
                        Button(action: {
                            showAddConfirmDialog = true
                        }) {
                            SetBudgetButtonBackground(text: "Add Income")
                        }
//                        .confirmationDialog(
//                            "Create New Pay Check",
//                            isPresented: $showAddConfirmDialog
//                        ) {
//                            Button("Add") {
//
//                            }
//                            Button("Cancel", role: .cancel) {
//                                showAddConfirmDialog = false
//                            }
//                        }
                        
                        Button(action: {
                            for payCheckId in payCheckManager.payCheckAmountDict.keys {
                                let payCheck = payChecks.first(where: {$0.pcid == payCheckId})
                                payCheck!.amount = payCheckManager.payCheckAmountDict[payCheckId]!
                            }
                            
                            do {
                                try viewContext.save()
                            } catch {
                                print(error)
                            }
                            
                            payCheckManager.payCheckAmountDict.removeAll()
                        }) {
                            SetBudgetButtonBackground(text: "Save Changes")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddConfirmDialog, onDismiss: {}) {
            VStack(spacing: 5, content: {
                HStack(spacing: 10, content: {
                    Text("PayCheck Name:")
                    Spacer()
                    TextField("PayCheck Name", text: $titleText)
                        .focused($isFocusedOnTitle, equals: true)
                })
                
                HStack(spacing: 10, content: {
                    Text("PayCheck Amount:")
                    Spacer()
                    TextField("PayCheck Amount", text: $amountText)
                        .focused($isFocusedOnTitle, equals: false)
                })
                
                HStack(spacing: 10, content: {
                    Text("Date of Payment:")
                    Spacer()
                    DatePicker(
                        "PayCheck Date",
                        selection: $payCheckDate,
                        displayedComponents: [.date]
                    )
                })
                
                Button(action: {
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
                                
                                do {
                                    try viewContext.save()
                                } catch {
                                    print(error)
                                }
                                
                                showAddConfirmDialog = false
                            }
                        } else {
                            showNewPayCheckAmountAlert = true
                            isFocusedOnTitle = false
                        }
                    } else {
                        showNewPayCheckTitleAlert = true
                        isFocusedOnTitle = true
                    }
                }) {
                    SetBudgetButtonBackground(text: "Add PayCheck")
                }
            })
                .alert("Please Enter PayCheck Name", isPresented: $showNewPayCheckTitleAlert, actions: {})
                .alert("Please Enter Valid PayCheck Amount Greater Than Zero", isPresented: $showNewPayCheckAmountAlert, actions: {})
                
            
        }
        //        .incomeAddTextAlert(
//            showAddConfirmDialog: $showAddConfirmDialog,
//            titleText: $titleText,
//            amountText: $amountText
//        )
//        .alert("Add Income", isPresented: $showAddConfirmDialog, presenting: {_ in }) {
//            IncomeAddTextAlert(
//                showAddConfirmDialog: $showAddConfirmDialog,
//                titleText: $titleText,
//                amountText: $amountText,
//                viewPresented: self)
//                    .environment(\.managedObjectContext, viewContext)
//        }
//        .onAppear {
//            if !payChecksPopulated {
//                populatePayChecks()
//                payChecksPopulated = true
//            }
//        }
    }
}
    
//    struct IncomeAddTextDialog<DialogContent: View>: ViewModifier {
//
//        @Environment(\.managedObjectContext) var viewContext
//        @Binding var showAddConfirmDialog: Bool
//        @Binding var titleText: String
//        @Binding var amountText: String
//        @FocusState var focusedOnTitle: Bool?
//        @State var showInvalidTitleInputAlert: Bool = false
//        @State var showInvalidAmountInputAlert: Bool = false
//
//        let dialogContent: DialogContent
//
//
//        init(showAddConfirmDialog: Binding<Bool>,
//             @ViewBuilder dialogContent: () -> DialogContent) {
//            _showAddConfirmDialog = showAddConfirmDialog
//            self.dialogContent =
//
//        }
//
//        func body(content: Content) -> some View {
//            ZStack {
//                content
//                if showAddConfirmDialog {
//                    ZStack {
//                        dialogContent
//                            .background(
//                                RoundedRectangle(cornerRadius: 5)
//                                    .foregroundColor(.gray)
//                                    .opacity(0.9)
//                            )
//                    }.padding(20)
//                }
//            }
//        }
//
//    }
//
//    struct IncomeAddTextContent: View {
//
//    }
//
//    struct IncomeAddTextAlert<ViewPresented>: View where ViewPresented: View {
//
//            @Environment(\.managedObjectContext) var viewContext
//            @Binding var showAddConfirmDialog: Bool
//            @Binding var titleText: String
//            @Binding var amountText: String
//            let viewPresented: ViewPresented
//            private let title = "Create New Pay Check"
//            @FocusState var focusedOnTitle: Bool?
//            @State var showInvalidTitleInputAlert: Bool = false
//            @State var showInvalidAmountInputAlert: Bool = false
//
//            var body: some View {
//                GeometryReader { (deviceSize: GeometryProxy) in
//                    ZStack {
//                        self.viewPresented
//                            .disabled(showAddConfirmDialog)
//                        VStack {
//                            Text(title)
//                            TextField("title", text: $titleText)
//                                .focused($focusedOnTitle, equals: true)
//                            TextField("amount", text: $amountText)
//                                .focused($focusedOnTitle, equals: false)
//        //                        .onSubmit {
//        //                            validateAmountInput()
//        //                        }
//        //                        .onChange(of: focusedOnTitle) {focusedOnTitle in
//        //                            if focusedOnTitle != nil {
//        //                                validateAmountInput()
//        //                            }
//        //                        }
//                            Divider()
//                            HStack {
//                                Button(action: {
//                                    if titleText != "" {
//                                        if let floatIncomeAmount = Float(amountText) {
//                                            if floatIncomeAmount <= 0.00 {
//                                                showInvalidAmountInputAlert = true
//                                                focusedOnTitle = false
//                                            }
//                                            else {
//                                                let newIncome = PayCheckMO(context: viewContext)
//                                                newIncome.pcid = UUID()
//                                                newIncome.date = Date()
//                                                newIncome.amount = floatIncomeAmount
//                                                newIncome.title = titleText
//
//                                                do {
//                                                    try viewContext.save()
//                                                } catch {
//                                                    print(error)
//                                                }
//
//                                                showAddConfirmDialog = false
//                                            }
//                                        } else {
//                                            showInvalidAmountInputAlert = true
//                                            focusedOnTitle = false
//                                        }
//                                    } else {
//                                        showInvalidTitleInputAlert = true
//                                        focusedOnTitle = true
//                                    }
//
//                                }) {
//                                    Text("Add")
//                                }
//                                Divider()
//                                Button(action: {
//
//                                }) {
//                                    Text("Dismiss")
//                                }
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .frame(
//                            width: deviceSize.size.width*0.7,
//                            height: deviceSize.size.height*0.7
//                        )
//                        .shadow(radius: 1)
//                        //.opacity(self.showAddConfirmDialog ? 1 : 0)
//                    }
//                }
//                .alert("Please Enter a Valid Title", isPresented: $showInvalidTitleInputAlert, actions: {})
//                .alert("Please Enter a Valid Amount Greater Than Zero", isPresented: $showInvalidAmountInputAlert, actions: {})
//            }
//    }


    

    
struct IncomeEntryView: View {

    @Environment(\.managedObjectContext) var viewContext
    var payCheck: PayCheckMO
    @EnvironmentObject var payCheckManager: PayCheckManager
    @State var incomeAmountText: String
    @FocusState var focusIncomeId: UUID?
    @State var showInvalidInputAlert: Bool = false
    @State var showDeleteConfirmDialog: Bool = false

    var body : some View {
        HStack {
            Button(action: {
                showDeleteConfirmDialog = true
            }) {
                Image(systemName: "trash.fill")
            }
            Text("\(payCheck.title ?? ""):")
                .bold()
            Spacer()
            Spacer()
            Spacer()
            TextField(payCheck.title ?? "", text: $incomeAmountText)
                .onSubmit {
                    validateInputAndSetToPayCheckList()
                }
                .focused($focusIncomeId, equals: payCheck.pcid ?? nil)
                .onChange(of: focusIncomeId) {focusIncomeId in
                    if focusIncomeId != nil {
                        validateInputAndSetToPayCheckList()
                    }
                }
        }
        .alert("Please Enter a Valid Input Greater Than Zero", isPresented: $showInvalidInputAlert, actions: {})
        .confirmationDialog("Confirm Removal of \(payCheck.title ?? "Unnamed PayCheck")",
                            isPresented: $showDeleteConfirmDialog) {
            Button("Confirm", role: .destructive) {
                payCheckManager.payCheckAmountDict.removeValue(forKey: payCheck.pcid!)
                payCheckManager.payCheckTitleDict.removeValue(forKey: payCheck.pcid!)
                viewContext.delete(payCheck)
                do {
                    try viewContext.save()
                } catch {
                    print(error)
                }
            }
            Button("Cancel", role: .cancel) {
                showDeleteConfirmDialog = false
            }
        }
    }
    
    func validateInputAndSetToPayCheckList() {
        if let floatPayCheckAmount = Float(incomeAmountText) {
            //ucBudgetManager.userCategoryBudgetDict[subCategory.group ?? ""]![subCategory.category ?? ""]![subCategory.subCategory ?? ""] = floatBudgetAmount
            //payCheckManager.payCheckList.firstIndex(where: {$0.id == payCheck.pcid}).
//            if payCheckManager.payCheckList.contains(where: {payCheck.pcid == $0.id}) {
//                payCheckManager.payCheckList.first(where: {payCheck.pcid == $0.id})
//            }
            
            //payCheckManager.payCheckAmountDict[payCheck.pcid!] = floatBudgetAmount
            //if payCheckManager.payCheckAmountDict.contains(where: {paycheck.pcid})
            payCheckManager.payCheckAmountDict[payCheck.pcid!] = floatPayCheckAmount
            if floatPayCheckAmount <= 0.00 {
                //ucBudgetManager.userCategoryBudgetDict[subCategory.group ?? ""]![subCategory.category ?? ""]!.removeValue(forKey: subCategory.subCategory ?? "")
                //payCheckManager.payCheckAmountDict.removeValue(forKey: payCheck.pcid!)
                showInvalidInputAlert = true
                focusIncomeId = payCheck.pcid!
            }
        }
//        else if incomeAmountText == "" {
//            incomeAmountText = "\(0.00)"
//            payCheckManager.payCheckAmountDict[payCheck.pcid!] = 0.00
//            payCheckManager.payCheckAmountDict
        //}
        else {
            showInvalidInputAlert = true
            focusIncomeId = payCheck.pcid!
            
        }
    }
}
    
struct CategoryDisclosureGroup: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        entity: UserCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \UserCategory.ucid, ascending: true)],
        animation: .default
    ) var userCategories: FetchedResults<UserCategory>
    @EnvironmentObject var ucBudgetManager: UserCategoryBudgetManager
    var category: Category
    var subCategories: FetchedResults<SubCategoryMO>
    @FocusState var focusSubCategory: String?
    var categoryBudgetTextDict: [String: Float] = [:]
    
    
    var body : some View {

        return DisclosureGroup("\(category.category)\t\t\t$\(getCategoryBudget(category: category))") {
            ScrollView {
             VStack {
                    ForEach(subCategories.filter{$0.category == category.category}) {subCategory in
                        
                        SubCategoryEntryView(subCategory: subCategory,
                                             budgetAmountText: "\(subCategory.userCategory?.budgetAmount ?? 0.00)", focusSubCategory: _focusSubCategory)
                            .environment(\.managedObjectContext, viewContext)
                            .environmentObject(ucBudgetManager)
                    }
                 Button(action: {
                     for subCategory in subCategories.filter({$0.category == category.category}) {
                         let newSCBudgetAmount = ucBudgetManager.userCategoryBudgetDict[subCategory.group ?? ""]![subCategory.category ?? ""]![subCategory.subCategory ?? ""] ?? 0.00
                         if subCategory.userCategory != nil {
                             if newSCBudgetAmount <= 0.00 {
                                 viewContext.delete(subCategory.userCategory!)
                             }
                             else {
                                 subCategory.userCategory!.budgetAmount = newSCBudgetAmount
                             }
                         }
                         else {
                             if newSCBudgetAmount > 0.00 {
                                 let userCategory = UserCategory(context: viewContext)
                                 userCategory.ucid = UUID()
                                 userCategory.scid = subCategory.id
                                 userCategory.date = Date()
                                 userCategory.actualAmount = 0.00
                                 userCategory.budgetAmount = newSCBudgetAmount
                                 userCategory.subCategory = subCategory
                                 subCategory.userCategory = userCategory
                             }
                         }
                     }
                     
                     do {
                         try viewContext.save()
                     } catch {
                         print(error)
                     }
                 }) {
                     SetBudgetButtonBackground(text: "Save Changes")
                 }
             }
            }
           }
    }
    
    func getCategoryBudget(category: Category) -> Float {

        var budgetAmount: Float = 0.00
        for subCategory in subCategories {
            if subCategory.category == category.category
                && subCategory.group == category.group {
                budgetAmount += subCategory.userCategory?.budgetAmount ?? 0.00
            }
        }
        return budgetAmount
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

struct SubCategoryEntryView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    var subCategory: SubCategoryMO
    @EnvironmentObject var ucBudgetManager: UserCategoryBudgetManager
    @State var budgetAmountText: String
    @FocusState var focusSubCategory: String?
    @State var showInvalidInputAlert: Bool = false

    var body : some View {
        HStack {
            Text("\(subCategory.subCategory ?? ""):")
                .bold()
            Spacer()
            Spacer()
            Spacer()
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
        .alert("Please Enter a Valid Input", isPresented: $showInvalidInputAlert, actions: {})
    }
    
    func validateInputAndSetToDict() {
        if let floatBudgetAmount = Float(budgetAmountText) {
            ucBudgetManager.userCategoryBudgetDict[subCategory.group ?? ""]![subCategory.category ?? ""]![subCategory.subCategory ?? ""] = floatBudgetAmount
            if floatBudgetAmount == 0.00 {
                ucBudgetManager.userCategoryBudgetDict[subCategory.group ?? ""]![subCategory.category ?? ""]!.removeValue(forKey: subCategory.subCategory ?? "")
            }
        } else if budgetAmountText == "" {
            budgetAmountText = "\(0.00)"
        } else {
            showInvalidInputAlert = true
            focusSubCategory = subCategory.subCategory
        }
    }
}

}

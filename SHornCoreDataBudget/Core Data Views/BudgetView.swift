//
//  BudgetView.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/18/21.
//

import Foundation
import SwiftUI
import CoreData

struct BudgetView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        entity: SubCategoryMO.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SubCategoryMO.group, ascending: true)],
        animation: .default)
    var subCategories: FetchedResults<SubCategoryMO>
    @FetchRequest(
        entity: PayCheckMO.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \PayCheckMO.pcid, ascending: true)],
        animation: .default
    )
    var payChecks: FetchedResults<PayCheckMO>
    @FetchRequest(
        entity: UserTransaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \UserTransaction.tid, ascending: true)],
        animation: .default
    )
    var transactions: FetchedResults<UserTransaction>
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @AppStorage("isInitialSubCategories") var isInitialSubCategories = true
    @AppStorage("recentBudgetMonth") var recentBudgetMonth: String = ""
    @AppStorage("recentBudgetYear") var recentBudgetYear: String = ""
    @EnvironmentObject var budgetManager: BudgetCategoriesManager
    @EnvironmentObject var ucSubmitManager: UserCategorySubmitManager
    @EnvironmentObject var budgetDateManager: BudgetMonthAndYearManager
    @State var managersPopulated = false
    @FocusState var focusSubCategory: String?
    @Binding var navBarHidden: Bool
    @State var showSubCategoryForm: Bool = false
    @State var showExceedingBudgetForm: Bool = false
    @State var refreshId = UUID()
    @State var toolBarButtonsHidden: Bool = false
    @State var showNewBudgetModal: Bool = false
    @State var isShown = true

    var totalIncome: Float {
        var totalIncome: Float = 0.00
        for payCheck in payChecks {
            totalIncome += payCheck.amount
        }
        return totalIncome
    }
    
    var totalBudgetAmount: Float {
        var totalBudgetAmount: Float = 0.00
        for category in budgetManager.categories {
            totalBudgetAmount += getCategoryBudgetTotal(category: category)
        }
        return totalBudgetAmount
    }
    
    private func getCategoryBudgetTotal(category: Category) -> Float {
        var categoryTotal: Float = 0.00
        for subCategory in subCategories.filter({$0.category == category.category && $0.group == category.group}) {
            categoryTotal += subCategory.userCategory?.budgetAmount ?? 0.00
        }
        return categoryTotal
    }
    
    private func navLink<Destination: View>(category: Category, destination: Destination) -> some View {
        return NavigationLink(destination: destination) {
            HStack {
                VStack(alignment: .leading) {
                    Text(category.category)
                        .bold()
                        .font(.title2)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("$\(String(format: "%.2f", getCategoryBudgetTotal(category: category)))")
                        .font(.title2)
                }
            }
            .padding()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Income").bold()) {
                        IncomeDisclosureGroup(payChecks: payChecks)
                            .environment(\.managedObjectContext, viewContext)
                    }
                    ForEach(budgetManager.groups.indices) {groupIndex in
                        Section(header: Text(budgetManager.groups[groupIndex])) {
                            ForEach(budgetManager.categories.filter({
                                $0.group == budgetManager.groups[groupIndex]})) {
                                    category in
//                                    navLink(category: category, destination:
//                                                BudgetCategoryView(
//                                                    navBarHidden: $navBarHidden,
//                                                    subCategories: subCategories,
//                                                    category: category,
//                                                    focusSubCategory: _focusSubCategory,
//                                                    toolBarButtonsHidden: $toolBarButtonsHidden)
//                                                        .environment(\.managedObjectContext, viewContext)
//                                                        .environmentObject(budgetManager)
//                                                            .environmentObject(ucSubmitManager)
//                                    )
                                    NavigationLink(destination:
                                                    BudgetCategoryView(
                                                        navBarHidden: $navBarHidden,
                                                        subCategories: subCategories,
                                                        category: category,
                                                        focusSubCategory: _focusSubCategory,
                                                        toolBarButtonsHidden: $toolBarButtonsHidden)
                                                            .environment(\.managedObjectContext, viewContext)
                                                            .environmentObject(budgetManager)
                                                                .environmentObject(ucSubmitManager)
//                                                    .onDisappear {
//                                        if (isShown) {
//                                            refreshId = UUID()
//                                        }
//                                    }
//                                                    .onAppear {
//                                        isShown = false
//                                    }
                                    ) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(category.category)
                                                    .bold()
                                                    .font(.title2)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing) {
                                                Text("$\(String(format: "%.2f", getCategoryBudgetTotal(category: category)))")
                                                    .font(.title2)
                                            }
                                        }
                                        .padding()
                                    }
                                }
                        }
                    }
                    HStack {
                        Spacer()
                        Button(action:{
                            let totalIncome = totalIncome
                            let totalBudgetAmount = totalBudgetAmount
                            if totalBudgetAmount > totalIncome {
                                showExceedingBudgetForm = true
                            } else {
                                if totalBudgetAmount < totalIncome {
                                    adjustMiscellaneousBudget(totalIncome: totalIncome, totalBudgetAmount: totalBudgetAmount)
                                }
                                
                                do {
                                    try viewContext.save()
                                    presentationMode.wrappedValue.dismiss()
                                } catch {
                                    print(error)
                                }
                                
                                budgetDateManager.recentBudgetYear = CurrentDateFunctions.currentYear
                                budgetDateManager.recentBudgetMonth = CurrentDateFunctions.currentMonth
                            }
                            
                        }) {
                            SetBudgetButtonBackground(text: "Save Changes")
                        }
                        Spacer()
                    }
                        //Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            if !(CurrentDateFunctions.currentYear == budgetDateManager.recentBudgetYear && CurrentDateFunctions.currentMonth == budgetDateManager.recentBudgetMonth) {
                                showNewBudgetModal = true
                            }
                            viewContext.undo()
                            
                            do {
                                try viewContext.save()
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                print(error)
                            }
                            
                        }) {
                            SetBudgetButtonBackground(text: "Undo Changes")
                        }
                        Spacer()
                    }
                   // }
                    //.padding()
                }
//                .onAppear {
//                    isShown = true
//                }
//                .toolbar(content: {
//                    ToolbarItem(placement: .bottomBar) {
//
//                    }
//
//                })
//                .id(refreshId)
                .navigationBarTitle("Set Budget", displayMode: .inline)
                .alert("Amounts Entered for Budget Categories Exceed Income", isPresented: $showExceedingBudgetForm, actions: {})
            }
        }
        .fullScreenCover(isPresented: $showNewBudgetModal) {
            VStack(spacing: UIScreen.main.bounds.height/25) {
                Text("Time to Set a New Budget")
                    .bold()
                    .font(Font.title)
                Spacer()
                Button(action: {
                    adjustMiscellaneousBudget(totalIncome: 0.0, totalBudgetAmount: 0.0)
                    for subCategory in subCategories {
                        
                        if subCategory.userCategory != nil {
                            subCategory.userCategory!.date = Date()
                            subCategory.userCategory!.actualAmount = Float(0.00)
                        }
                    }
                    for transaction in transactions {
                        viewContext.delete(transaction)
                    }
                    
                    for payCheck in payChecks {
                        payCheck.date = Date()
                    }
                    showNewBudgetModal = false
                }) {
                    FullScreenCoverButtonBackground(buttonText: "Use Previous Budget Amounts")
                }
                .padding()
                
                Button(action: {
                    for subCategory in subCategories {
                        if subCategory.userCategory != nil {
                            viewContext.delete(subCategory.userCategory!)
                        }
                    }
                    for transaction in transactions {
                        viewContext.delete(transaction)
                    }
                    for payCheck in payChecks {
                        viewContext.delete(payCheck)
                    }
                    showNewBudgetModal = false
                }) {
                    FullScreenCoverButtonBackground(buttonText: "Start Budget Amounts From Scratch")
                }
                .padding()
                
            }
            .padding(EdgeInsets(top: UIScreen.main.bounds.height/10, leading: 0, bottom: UIScreen.main.bounds.width/10, trailing: 0))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .listStyle(GroupedListStyle())
        .onAppear {
            if !(CurrentDateFunctions.currentYear == budgetDateManager.recentBudgetYear && CurrentDateFunctions.currentMonth == budgetDateManager.recentBudgetMonth) {
                showNewBudgetModal = true
            }
            navBarHidden = false
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
    }
    
    func adjustMiscellaneousBudget(totalIncome: Float, totalBudgetAmount: Float) {
        let miscSubCategory = subCategories.first(where: {
            $0.group == "Recreation & Fun" &&
            $0.category == "Miscellaneous Items" &&
            $0.subCategory == "Miscellaneous Items"
        })!
        
        if let _ = miscSubCategory.userCategory {
            miscSubCategory.userCategory!.budgetAmount += totalIncome - totalBudgetAmount
        } else {
            let miscUserCategory = UserCategory(context: viewContext)
            
            miscUserCategory.ucid = UUID()
            miscUserCategory.scid = miscSubCategory.id
            miscUserCategory.budgetAmount = Float(totalIncome - totalBudgetAmount)
            miscUserCategory.actualAmount = Float(0.00)
            miscUserCategory.date = Date()
            miscSubCategory.userCategory = miscUserCategory
            miscUserCategory.subCategory = miscSubCategory
        }
    }
}

struct FullScreenCoverButtonBackground: View {
    var buttonText: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ViewConstants.finishedButtonCornerRadius)
                .fill(.black)
                .frame(width: UIScreen.main.bounds.width*3/4, height: UIScreen.main.bounds.height/8)
            Text(buttonText)
                .font(Font.body)
                .foregroundColor(.white)
                .bold()
        }
    }
}

struct IncomeDisclosureGroup: View {
      
    @Environment(\.managedObjectContext) var viewContext
    var payChecks: FetchedResults<PayCheckMO>
    @FocusState var focusIncomeId: UUID?
    @State var showAddConfirmDialog: Bool = false
    @State var titleText: String = ""
    @State var amountText: String = ""
    @State var payCheckDate: Date = Date()
    @FocusState var isFocusedOnTitle: Bool?
    @State var showNewPayCheckTitleAlert: Bool = false
    @State var showNewPayCheckAmountAlert: Bool = false
    

    
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
                    }
                    
                    HStack {
                        Button(action: {
                            showAddConfirmDialog = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: ViewConstants.addIncomeButtonCornerRadius)
                                    .fill(.gray)
                                    .frame(width: ViewConstants.addIncomeButtonWidth, height: ViewConstants.addIncomeButtonHeight)
                                Text("Add Income")
                                    .font(Font.caption)
                                    .foregroundColor(.black)
                                    .bold()
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddConfirmDialog, onDismiss: {}) {
            
            Form {
                Text("PayCheck Name:")
                    .bold()
                    .font(.title2)
                TextField("PayCheck Name", text: $titleText)
                    .focused($isFocusedOnTitle, equals: true)
                
                Text("PayCheck Amount:")
                    .bold()
                    .font(.title2)
                TextField("PayCheck Amount", text: $amountText)
                    .focused($isFocusedOnTitle, equals: false)
                Text("Date of Payment:")
                    .bold()
                    .font(.title2)
                DatePicker(
                    "PayCheck Date",
                    selection: $payCheckDate,
                    displayedComponents: [.date]
                )
                
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

                                titleText = ""
                                amountText = ""
                                payCheckDate = Date()
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
            }
            .alert("Please Enter PayCheck Name", isPresented: $showNewPayCheckTitleAlert, actions: {})
            .alert("Please Enter Valid PayCheck Amount Greater Than Zero", isPresented: $showNewPayCheckAmountAlert, actions: {})
            
        }
    }
}

struct IncomeEntryView: View {

    @Environment(\.managedObjectContext) var viewContext
    var payCheck: PayCheckMO
    //@EnvironmentObject var payCheckManager: PayCheckManager
    @State var incomeAmountText: String
    @FocusState var focusIncomeId: UUID?
    @State var showInvalidInputAlert: Bool = false
    @State var showDeleteConfirmDialog: Bool = false

    var body : some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        showDeleteConfirmDialog = true
                    }) {
                        Image(systemName: "trash.fill")
                    }
                    Text("\(payCheck.title ?? ""):")
                        .bold()
                }
            }
            Spacer()
            Spacer()
            Spacer()
            VStack(alignment: .trailing) {
                TextField(payCheck.title ?? "", text: $incomeAmountText)
                    .onSubmit {
                        validateInputAndMakeChanges()
                    }
                    .focused($focusIncomeId, equals: payCheck.pcid ?? nil)
                    .onChange(of: focusIncomeId) {focusIncomeId in
                        if focusIncomeId != nil {
                            validateInputAndMakeChanges()
                        }
                    }
            }
        }
        .alert("Please Enter a Valid Input Greater Than Zero", isPresented: $showInvalidInputAlert, actions: {})
        .confirmationDialog("Confirm Removal of \(payCheck.title ?? "Unnamed PayCheck")",
                            isPresented: $showDeleteConfirmDialog) {
            Button("Confirm", role: .destructive) {
                viewContext.delete(payCheck)
            }
            Button("Cancel", role: .cancel) {
                showDeleteConfirmDialog = false
            }
        }
    }
    
    func validateInputAndMakeChanges() {
        if let floatPayCheckAmount = Float(incomeAmountText) {

            payCheck.amount = floatPayCheckAmount
            if floatPayCheckAmount <= 0.00 {
                showInvalidInputAlert = true
                focusIncomeId = payCheck.pcid!
            }
        }
        else {
            showInvalidInputAlert = true
            focusIncomeId = payCheck.pcid!
            
        }
    }
}

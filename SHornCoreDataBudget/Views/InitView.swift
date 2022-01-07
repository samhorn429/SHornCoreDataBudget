//
//  InitView.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 12/11/21.
//

import Foundation
import SwiftUI

struct InitView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var budgetManager: BudgetCategoriesManager
    @EnvironmentObject var ucSubmitManager: UserCategorySubmitManager
    @EnvironmentObject var payCheckManager: PayCheckManager
    @EnvironmentObject var budgetDateManager: BudgetMonthAndYearManager
    
    
    var body: some View {
        Group {
            if budgetDateManager.recentBudgetMonth == CurrentDateFunctions.currentMonth &&
                budgetDateManager.recentBudgetYear == CurrentDateFunctions.currentYear {
                HomePageView(classification: .none)
                     .environmentObject(budgetManager)
                     .environmentObject(ucSubmitManager)
                     .environmentObject(payCheckManager)
                     .environmentObject(budgetDateManager)
                     .environment(\.managedObjectContext, viewContext)
            } else {
                BudgetView(navBarHidden: Binding.constant(false))
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(budgetManager)
                    .environmentObject(budgetDateManager)
                    .environmentObject(ucSubmitManager)
            }
        }
    }
}

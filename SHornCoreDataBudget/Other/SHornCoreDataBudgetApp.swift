//
//  SHornCoreDataBudgetApp.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/3/21.
//

import SwiftUI

@main
struct SHornCoreDataBudgetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            InitView()
                .environmentObject(try! BudgetCategoriesManager())
                .environmentObject(UserCategorySubmitManager())
                .environmentObject(PayCheckManager())
                .environmentObject(BudgetMonthAndYearManager())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)

                
        }
    }
}



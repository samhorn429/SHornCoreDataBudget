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
                .environmentObject(BudgetMonthAndYearManager())
                .environmentObject(UserCategoryCoreDataManager())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)

                
        }
    }
}



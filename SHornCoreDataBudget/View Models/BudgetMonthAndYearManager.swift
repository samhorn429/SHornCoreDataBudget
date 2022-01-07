//
//  BudgetMonthAndYearManager.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 12/11/21.
//

import Foundation
import SwiftUI

class BudgetMonthAndYearManager: ObservableObject {
    @AppStorage("recentBudgetMonth") var recentBudgetMonth: String = ""
    @AppStorage("recentBudgetYear") var recentBudgetYear: String = ""
}

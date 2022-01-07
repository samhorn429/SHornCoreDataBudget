//
//  File.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/20/21.
//

import Foundation
import SwiftUI

class UserCategorySubmitManager: ObservableObject {
    
    @Published var ucBudgetDict: [UUID: Float]
    @Published var ucAmountDict: [UUID: Float]
    
    init() {
        ucBudgetDict = Dictionary<UUID, Float>()
        ucAmountDict = Dictionary<UUID, Float>()
    }
}

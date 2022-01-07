//
//  PayCheckManager.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/17/21.
//

import Foundation
import SwiftUI

class PayCheckManager: ObservableObject {
    //@Published var payCheckList: [PayCheck]
    @Published var payCheckAmountDict: [UUID: Float]
    @Published var payCheckTitleDict: [UUID: String]
    @Published var payCheckDateDict: [UUID: Date]
    
    init() {
        //payCheckList = Array<PayCheck>()
        payCheckAmountDict = Dictionary<UUID, Float>()
        payCheckTitleDict = Dictionary<UUID, String>()
        payCheckDateDict = Dictionary<UUID, Date>()
    }
}

//
//  PayCheckModel.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/17/21.
//

import Foundation

struct PayCheck {
    var id: UUID
    var amount: Float
    var date: Date
    var title: String
    
    init(title: String, amount: Float) {
        id = UUID()
        self.title = title
        self.amount = amount
        date = Date()
    }
    
    init(id: UUID, title: String, amount: Float, date: Date) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
    }
}

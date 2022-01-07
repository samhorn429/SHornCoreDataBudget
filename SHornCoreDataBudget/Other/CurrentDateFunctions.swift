//
//  CurrentDateFunctions.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 12/11/21.
//

import Foundation

struct CurrentDateFunctions {
    
    static var currentMonth: String {
        let currMonth = Date()
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL"
        return monthFormatter.string(from: currMonth)
    }
    
    static var currentYear: String {
        let currYear = Date()
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        return yearFormatter.string(from: currYear)
    }
}

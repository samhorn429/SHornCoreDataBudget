//
//  SubCategoriesModel.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/9/21.
//

import Foundation
import SwiftUI

struct SubCategory : Identifiable, Codable {
    
    var id: UUID
    var subCategory: String
    var category: String
    var group: String
    
    enum CodingKeys: String, CodingKey {
        case subCategory
        case category
        case group
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        subCategory = try values.decode(String.self, forKey: .subCategory)
        category = try values.decode(String.self, forKey: .category)
        group = try values.decode(String.self, forKey: .group)
    }
}

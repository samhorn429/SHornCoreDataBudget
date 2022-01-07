//
//  ColorExtensions.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/20/21.
//

import Foundation
import SwiftUI

extension Color {
    static var randomColor: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
    
    static func randomColorCollection(size: Int) -> [Color] {
        var colorCollection = Array<Color>()
        var nextColor: Color
        for _ in 0..<size {
            nextColor = Color.randomColor
            while colorCollection.contains(nextColor) {
                nextColor = Color.randomColor
            }
            colorCollection.append(nextColor)
            
        }
        return colorCollection
    }
    
    static var chartColorList: [Color] {
        return [Color.red,
        Color.blue,
        Color.yellow,
        Color.green,
        Color.purple,
        Color.orange,
        Color.cyan,
        Color.pink]
    }
}

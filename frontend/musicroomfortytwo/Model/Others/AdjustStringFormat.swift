//
//  AdjustStringFormat.swift
//  musicroomfortytwo
//
//  Created by ML on 03/02/2021.
//

import Foundation

class AdjustStringFormat {
    
    static let shared = AdjustStringFormat()
    private init() {}

    func prepareStringFormat(_ list: [String]) {
        let count = list.count
        var newList = ""
        if count > 0  {
            for i in 0...(count - 1) {
                if i > 0 {
                    newList = newList + "," + list[i]
                } else {
                    newList = list[i]
                }
            }
        }
        UserDefaults.standard.setValue(newList, forKey: "testString")
    }
}

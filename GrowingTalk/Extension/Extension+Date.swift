//
//  Extension+Date.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/6/24.
//

import Foundation

extension Date {
    func dateToString(targetString: String? = nil) -> String {
        let dateFormatter = DateFormatter()
        if targetString != nil {
            dateFormatter.dateFormat = targetString
        } else {
            dateFormatter.dateFormat = "yy. MM. dd."
        }
        
        return dateFormatter.string(from: self)
        
    }
}

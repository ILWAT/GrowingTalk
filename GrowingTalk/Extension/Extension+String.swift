//
//  Extension+String.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/7/24.
//

import Foundation

extension String {
    
    var decimalFilteredString: String {
        get { return String(unicodeScalars.filter(CharacterSet.decimalDigits.contains))}
    }
    
    func convertPhoneNumber() -> String {
        let input: [Character] = Array(self.decimalFilteredString)
        
        guard input.count > 3 else { return String(input) }
        
        let defaultNumberPattern = "###-####-####"
        let oldNumberPattern = "###-###-####"
        
        let replacingSpace: Character = "#"
        
        let pattern: [Character]
        
        switch input[2] {
        case "1":
            pattern = Array(oldNumberPattern)
        default:
            pattern = Array(defaultNumberPattern)
        }
        
        var formattedCharArray: [Character] = []
        
        var inputIndex = 0
        var patternIndex = 0
        
        while inputIndex < input.count {
            guard patternIndex < pattern.count else { return String(formattedCharArray)} //입력되는 값이 pattern보다 더 많을 수 있으니 확인 필요
            
            let inputChar = input[inputIndex]
            
            let patternChar = pattern[patternIndex]
            
            if patternChar != replacingSpace {
                formattedCharArray.append(patternChar)
            } else {
                formattedCharArray.append(inputChar)
                inputIndex += 1
            }
            
            patternIndex += 1
            
        }
        
        return String(formattedCharArray)
    }
}

//
//  TokenManger.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/10/24.
//

import Foundation

final class TokenManger {
    static let shared = TokenManger()
    
    private init() { }
    
    func saveTokenInUserDefaults(tokenData: String, tokenCase: UserDefaultsCase) {
        UserDefaults.standard.setValue(tokenData, forKey: tokenCase.rawValue)
    }
    
    func obtainTokenFromUserDefaults(tokenCase: UserDefaultsCase) -> String {
        guard let token = UserDefaults.standard.string(forKey: tokenCase.rawValue) else { return "" }
        return token
    }
}

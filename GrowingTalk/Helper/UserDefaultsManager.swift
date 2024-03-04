//
//  TokenManger.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/10/24.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private init() { }
    
    func saveTokenInUserDefaults(tokenData: String, tokenCase: UserDefaultsCase) {
        UserDefaults.standard.setValue(tokenData, forKey: tokenCase.rawValue)
    }
    
    func obtainTokenFromUserDefaults(tokenCase: UserDefaultsCase) -> String {
        guard let token = UserDefaults.standard.string(forKey: tokenCase.rawValue) else { return "" }
        return token
    }
    
    func savingSignupUserDefaults(data: SignupResultModel) {
        let token = data.token
        self.saveTokenInUserDefaults(tokenData: token.accessToken, tokenCase: .accessToken)
        self.saveTokenInUserDefaults(tokenData: token.refreshToken, tokenCase: .refreshToken)
        if let userProfileImage = data.profileImage {
            UserDefaults.standard.setValue(userProfileImage, forKey: UserDefaultsCase.userProfileImageURL.rawValue)
        }
    }
}

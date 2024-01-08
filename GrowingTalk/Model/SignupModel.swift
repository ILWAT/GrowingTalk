//
//  SignupMode.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/8/24.
//

import Foundation

struct SignupModel: Encodable {
    let email: String
    let password: String
    let nickname: String
    let phone: String
    let deviceToken: String
}

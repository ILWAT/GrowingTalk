//
//  LoginModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/12/24.
//

import Foundation

struct LoginBodyModel: Encodable {
    let email: String
    let password: String
    let deviceToken: String?
}

struct LoginResultModel_V1: Decodable {
    let user_id: Int
    let nickname: String
    let accessToken: String
    let refreshToken: String
}

struct LoginResultModel_V2: Decodable {
    let user_id: Int
    let email: String
    let nickname: String
    let profileImage: String?
    let phone: String?
    let vendor: String?
    let createdAt: String
    let token: Tokens
}

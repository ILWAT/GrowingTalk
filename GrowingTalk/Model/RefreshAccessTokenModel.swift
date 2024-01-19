//
//  RefreshAccessTokenModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/18/24.
//

import Foundation

struct RefreshAccessTokenBodyModel: Encodable {
    let RefreshToken: String
}

struct RefreshAccessTokenResultModel: Decodable {
    let accessToken: String
}

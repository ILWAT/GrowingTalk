//
//  PostPaymentValidationModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 3/1/24.
//

import Foundation

struct PostPaymentValidationModel: Encodable {
    let imp_uid: String
    let merchant_uid: String
}

struct PostPaymentValidationResultModel: Decodable {
    let billing_id: Int
    let merchant_uid: String
    let amount: Int
    let sesacCoin: Int
    let success: Bool
    let createdAt: String
}

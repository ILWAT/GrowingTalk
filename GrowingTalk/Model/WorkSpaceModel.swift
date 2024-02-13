//
//  GetUserWorkSpaceModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/21/24.
//

import Foundation

struct WorkSpaceModel: Decodable, Hashable {
    let workspace_id: Int
    let name: String
    let description: String
    let thumbnail: String
    let owner_id: Int
    let createdAt: String
}

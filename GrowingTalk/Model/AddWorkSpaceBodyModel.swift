//
//  AddWorkSpaceModel.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/15/24.
//

import UIKit

struct AddWorkSpaceBodyModel {
    let name: String
    let description: String?
    let image: Data
}

struct AddWorkSpaceResultModel: Decodable {
    /*
     {
         "workspace_id": 102,
         "name": "mooneoTest1",
         "description": "",
         "thumbnail": "/static/workspaceThumbnail/1705299189020.png",
         "owner_id": 69,
         "createdAt": "2024-01-15T15:13:09.024Z"
     }
     */
    
    let workspace_id: Int
    let name:String
    let description: String
    let thumbnail: String
    let owner_id: Int
    let createdAt: String
}



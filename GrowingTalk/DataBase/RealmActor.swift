//
//  RealmManager.swift
//  GrowingTalk
//
//  Created by 문정호 on 2/22/24.
//

import Foundation
import RealmSwift

actor RealmActor {
    //MARK: - Properties
    private let realm: Realm!
    
    //MARK: - Init
    init() async throws {
        realm = try await Realm(actor: self)
    }
    
    
    func readObjectFromRealm<T: Object>(type:T.Type) -> T {
        let result = realm.objects(<#T##type: RealmFetchable.Protocol##RealmFetchable.Protocol#>)
    }
    
}

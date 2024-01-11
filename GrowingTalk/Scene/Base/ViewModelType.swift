//
//  ViewModelType.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/3/24.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}

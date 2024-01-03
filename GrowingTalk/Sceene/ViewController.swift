//
//  ViewController.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/2/24.
//

import UIKit

class ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for family in UIFont.familyNames {
            let familyName = family as String
            print(familyName)
            
            for name in UIFont.fontNames(forFamilyName: familyName){
                print("\(familyName): \(name)")
            }
        }
    }


}


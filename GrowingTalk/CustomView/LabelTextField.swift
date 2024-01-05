//
//  LabelTextField.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/4/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class LabelTextField: UIStackView {
    //MARK: - Component
    
    var textField: UITextField
    
    required init(coder: NSCoder) {
        fatalError("cannot use coder")
    }
    
    init(labelString: String, textFieldPlaceHolder: String?){
        textField = UITextField(frame: .zero).then { view in
            view.placeholder = textFieldPlaceHolder
            view.layer.cornerRadius = 8
            view.borderStyle = .roundedRect
            view.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
        }
        
        super.init(frame: .zero)
        
        self.axis = .vertical
        self.spacing = 8
        self.distribution = .equalSpacing
        self.alignment = .fill
        
        let label = UILabel().then { view in
            view.font = .Custom.appTitle2
            view.textAlignment = .left
            view.textColor = .label
            view.text = labelString
        }
        
        
        for view in [label, textField] {
            self.addArrangedSubview(view)
        }
        
    }
    
}

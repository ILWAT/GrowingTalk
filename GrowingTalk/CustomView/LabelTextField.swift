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
    private var label: UILabel
    
    var textField: UITextField
    
    required init(coder: NSCoder) {
        fatalError("cannot use coder")
    }
    
    init(labelString: String, textFieldPlaceHolder: String?, isSecure: Bool = false){
        textField = UITextField(frame: .zero).then { view in
            view.placeholder = textFieldPlaceHolder
            view.layer.cornerRadius = 8
            view.borderStyle = .roundedRect
            view.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
            view.isSecureTextEntry = isSecure
        }
        
        label = UILabel().then { view in
            view.font = .Custom.appTitle2
            view.textAlignment = .left
            view.textColor = .label
            view.text = labelString
        }
        
        super.init(frame: .zero)
        
        self.axis = .vertical
        self.spacing = 8
        self.distribution = .equalSpacing
        self.alignment = .fill
        
        
        
        
        for view in [label, textField] {
            self.addArrangedSubview(view)
        }
    }
    
    func chageLabelColor(color: UIColor) {
        self.label.textColor = color
    }
    
    func fillText(inputText: String) {
        self.textField.text = inputText
    }
    
}

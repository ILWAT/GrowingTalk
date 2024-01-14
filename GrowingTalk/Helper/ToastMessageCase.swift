//
//  SignupToastMessageCase.swift
//  GrowingTalk
//
//  Created by 문정호 on 1/9/24.
//

import Foundation

enum ToastMessageCase{
    enum Signup: String {
        case emilNotValid = "이메일 형식이 올바르지 않습니다."
        case emailIsValid = "사용 가능한 이메일입니다."
        case emailDuplicated = "이미 가입된 회원입니다. 로그인을 진행해주세요."
        case emailNotChecked = "이메일 중복 확인을 진행해주세요."
        case nicknameNotValid = "닉네임은 1글자 이상 30글자 이내로 부탁드려요."
        case passwordNotValid = "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."
        case passwordNotMatch = "작성하신 비밀번호가 일치하지 않습니다."
        case etc = "에러가 발생했어요. 잠시 후 다시 시도해주세요."
    }
}

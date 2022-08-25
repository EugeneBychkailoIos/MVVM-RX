//  LoginViewModelUpdate.swift
//
//  Created by jekster on 14.05.2021.
//


import Foundation

extension LoginViewModel {
    enum Update {
        case initialSetup(title: String)
        case updateData(sections: [TableViewSection])
    }
}


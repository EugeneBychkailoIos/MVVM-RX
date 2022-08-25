//  LoginViewModelEvent.swift
//
//  Created by jekster on 14.05.2021.
//

import UIKit
import Foundation

protocol LoginModule: class {
    var onEvent: Closure<LoginModuleEvent> { get }
}

enum LoginModuleEvent {
    case didTapNew
    case didTapLogin
    case didTapForgot
}

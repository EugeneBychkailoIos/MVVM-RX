//  LoginCoordinatorOutput.swift
//
//  Created by jekster on 14.05.2021.
//

import UIKit
import Foundation

protocol LoginCoordinatorOutput: class {
    var finishFlow: (() -> Void)? { get set }
    var logInSuccess: (() -> Void)? { get set }
    var registrationSuccess: (() -> Void)? { get set }
}

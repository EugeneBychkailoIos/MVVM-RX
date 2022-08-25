//  LoginViewModel.swift
//
//  Created by jekster on 14.05.2021.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class LoginViewModel: LoginModule {

    // MARK: - Private properties
    private let passwordMaxCount = 21

    // MARK: - LoginModule
    let onEvent = Closure<LoginModuleEvent>()

    // MARK: View bindings
    let isLoading = Closure<Bool>()
    let onError = Closure<Error>()
    let onUpdate = Closure<Update>()
    let savedText: String = ""
    
    let loginLoader = PublishSubject<Bool>()
    
    var data = LoginData(email: "test28@gmail.com", password: "Test28282828")
    private let authService: AuthService
    private let authStotage: AuthStorage
    private let disposeBag = DisposeBag()
    
    private let locationManager = LocationManager()
    
    // MARK: - View output
    func onViewEvent(_ event: LoginViewEvent) {
        switch event {
        case .viewDidLoad:
            onUpdate.call(.initialSetup(title: "Login in account"))
            makeSection()
        }
    }

    // MARK: - Lifecycle
    init(authService: AuthService, authStotage: AuthStorage) {
        self.authService = authService
        self.authStotage = authStotage
    }
    
    func makeSectionsToolTip() -> [TableViewSection] {
        var rows = [AnyTableCellEntity]()
        
        let cellSpace = SpaceCellEntity(top: 2)
        
        let titleString = "About us".attributed
            .color(Style.Colors.white)
            .alignment(.left)
            .font(Style.Font.latoRegular(value: 12).font)
        
        let cell = ToolTipTableCellEntity(title: titleString) {
            debugPrint("1")
        }
        
        rows.append(cell)
        rows.append(cellSpace)
        
        
        let titleString2 = "FAQ".attributed
            .color(Style.Colors.white)
            .alignment(.left)
            .font(Style.Font.latoRegular(value: 12).font)
        
        let cell2 = ToolTipTableCellEntity(title: titleString2) {
            debugPrint("2")
        }
        
        rows.append(cell2)
        rows.append(cellSpace)
        
        let titleString3 = "Press".attributed
            .color(Style.Colors.white)
            .alignment(.left)
            .font(Style.Font.latoRegular(value: 12).font)
        
        
        let cell3 = ToolTipTableCellEntity(title: titleString3) {
            debugPrint("3")
        }
        
        rows.append(cell3)
        rows.append(cellSpace)
        
        let section = TableViewSection(rows: rows)
        
        return [section]
    }

    
    private func makeSection() {
        var rows = [AnyTableCellEntity]()
        
        let titleString = "Email adress".attributed
            .color(Style.Colors.white)
            .alignment(.left)
            .font(Style.Font.cellFont(value: 10).font)
        
        let titleString2 = "Password".attributed
            .color(Style.Colors.white)
            .alignment(.left)
            .font(Style.Font.cellFont(value: 10).font)
        
        let cellSpace = SpaceCellEntity(top: 8)

    // MARK: - Email

        let errorEmailText = data.emailErrorMessage
            .attributed
            .font(Style.Font.latoMedium(10))
            .color(Style.Colors.warningColor)
            .alignment(.left)

        let cell = InputTextFieldTableCellEntity(id: 0, state: data.isShowEmailValid ? .empty : .error, title: titleString, errorTitle: errorEmailText, text: data.email, placeholder: "Emter your Email adress", isSecureTextEntry: false, keyboardType: .default, mask: nil, primaryFormat: nil) {(_, value, _) in
            self.data.email = value
            self.data.isShowEmailValid = true
        } 
        rows.append(cell)
        rows.append(cellSpace)

        // MARK: - Password
        let passwordMask = "[\(String(repeating: "-", count: passwordMaxCount))]"

        let errorPasswordText = data.passwordErrorMessage
            .attributed
            .font(Style.Font.latoMedium(10))
            .color(Style.Colors.warningColor)
            .alignment(.left)
        
        let cell2 = InputTextFieldTableCellEntity(id: 0, state: data.isShowPasswordValid ? .withImage : .error, title: titleString2, errorTitle: errorPasswordText, text: data.password, placeholder: "Enter your password", isSecureTextEntry: data.isSecurePassword, keyboardType: .default, mask: passwordMask, primaryFormat: passwordMask) { (_, value, _) in
//            print(value)
            self.data.password = value
            self.data.isShowEmailValid = true
        }  imageDidTapped: { [weak self ] _ in
            self?.data.isSecurePassword.toggle()
            self?.makeSection()
        }
        rows.append(cell2)
        rows.append(cellSpace)
        
        // MARK: - Login
        let titleCell3 = "Login".attributed
            .color(Style.Colors.buttonTitle)
            .font(Style.Font.cellFont(value: 14).font)
        
        let cell3 = ButtonTableCellEntity(style: .base, title: titleCell3) { [weak self ] in
            self?.validateData()
        }
        rows.append(cell3)
        rows.append(cellSpace)

        // MARK: - Forgot
        let titleCell4 = "Forgot password?".attributed
            .color(Style.Colors.titleCellGray)
            .font(Style.Font.cellFont(value: 14).font)
        
        let cell4 = ButtonTableCellEntity(style: .transparent, title: titleCell4) { [weak self] in
            self?.onEvent.call(.didTapForgot)
        }
        rows.append(cell4)
        rows.append(cellSpace)
        
        // MARK: - Signup
        let titleFirst = "New to Antella? ".attributed
            .font(Style.Font.cellFont(value: 14).font).color(.white)
        let titleSecond = "Sing Up".attributed
            .font(Style.Font.cellFont(value: 14).font).color(.orange)
        
        let titleCell5 = NSMutableAttributedString()
        titleCell5.append(titleFirst)
        titleCell5.append(titleSecond)
        
        let cell5 = ButtonTableCellEntity(style: .empty, title: titleCell5) { [weak self] in
            self?.onEvent.call(.didTapNew)
        }
        rows.append(cell5)
        rows.append(cellSpace)
        
        
        let section = TableViewSection(rows: rows)
        onUpdate.call(.updateData(sections: [section]))
    }
    
    func validateData() {
        if data.isValidData() {
            makeLogin()
            
        } else {
            makeSection()
        }
    }
    
    func makeLogin() {
        loginLoader.onNext(true)
        authService.signIn(email: data.email, password: data.password)
            .subscribe { [weak self] response in
                print(response)
                self?.loginLoader.onNext(false)
                self?.authStotage.authToken.accept(response.data)
                self?.onEvent.call(.didTapLogin)
            } onError: { [weak self] error in
                print("error:\(error)")
                self?.makeSection()
            } onCompleted: {
            }.disposed(by: disposeBag)
    }

}

// MARK: - Private functions

private extension LoginViewModel {

}

extension NSMutableAttributedString {

    func setColor(color: UIColor, forText stringValue: String) {
       let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }

}

extension LoginViewModel {
    struct LoginData {
        var email: String
        var password: String

        var emailErrorMessage = "Please, provide valid email address"

        // флаги для отображения красная ячейка или нет
        var isShowEmailValid = true
        var isShowPasswordValid = true

        // внутреняя валидация
        var isValidEmail: Bool {
            return email.isValidEmail
        }

        var isValidPassword: Bool {
            return password.count >= 8
        }
        
        var isSecurePassword = true
        
        var passwordErrorMessage: String {
             if password.count < 8 {
                return "Password at least 8 characters"
            } else {
                return ""
            }
        }

        mutating func isValidData() -> Bool {

            if !isValidEmail {
                isShowEmailValid = false
            }

            if !isValidPassword {
                isShowPasswordValid = false
            }

            return isValidEmail && isValidPassword
        }

    }
}

//
//  ResetPasswordViewController.swift
//  Alltenna
//
//  Created by jekster on 6/11/21.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol ResetModule: class {
    var onEvent: Closure<ExitModuleEvent> { get }
}

enum ResetModuleEvent {
    case didTapLogout
}

final class ResetPasswordController: ViewController {
    
    // MARK: - Public
    var onEvent = Closure<ResetModuleEvent>()
    
    // MARK: - Private properties
    private let containerView = UIView()
    private let titlelBL = UILabel()
    private let messageLbl = UILabel()
    
    private let emailTextFieldContainer = UIView()
    private let emailTextFieldTitle = UILabel()
    private let emailTextField = UICustomTextInput()
    
    private let button = DefaultButton()
    private var textView = TextView()
    private let passwordMaxCount = 10
    var data = RegisterData(email: "")
    
    private let disposeBag = DisposeBag()
    private var authService: AuthService
    private let router: Router
    
    // MARK: - Lifecycle
    init(router: Router, authService: AuthService) {
        self.authService = authService
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NavigationBarDecorator(self).decorate(
            as: .gray,
            with: "",
            animated: true,
            hideBackButton: false
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()
        navigationController?.navigationBar.isHidden = true
        buttonActions()
    }
    
    func openConfirmationAlertController(title: String?, message: String?, handler: @escaping () -> Void) {
        presentAlertController(with: "", message: "", anotherMessage: "") {
        }
    }
    
    func inputEmail(_ email: String) {
        self.data.email = email
    }
    
    private func buttonActions() {
        button.action = {
            self.authService.passwordReset(email: self.data.email)
                .subscribe { response in
                debugPrint("code sended to ur email")
            } onError: { error in
                print("error:\(error)")
            } onCompleted: {
            }.disposed(by: self.disposeBag)
        }
    }
}

// MARK: - Private functions

private extension ResetPasswordController {
    
    private func setupViews() {
        self.view.addSubview(containerView)
        containerView.backgroundColor = Style.Colors.defaultBackground
        
        containerView.addSubview(emailTextFieldContainer)
        
        emailTextFieldContainer.addSubview(emailTextFieldTitle)
        emailTextFieldContainer.addSubview(emailTextField)
        
        containerView.addSubview(messageLbl)
        containerView.addSubview(titlelBL)
        containerView.addSubview(button)
        
        emailTextFieldContainer.backgroundColor = Style.Colors.cellBackground
        emailTextFieldContainer.layer.cornerRadius = 10
        
        emailTextFieldTitle.attributedText = "Email address".attributed.alignment(.left).color(Style.Colors.white).font(Style.Font.latoMedium(10))
        
        _ = "[\(String(repeating: "0", count: passwordMaxCount))]"
        emailTextField.setData(text: data.email.attributed,
                               placeholder: "Enter your email",
                               isSecureTextEntry: data.isValidEmail ,
                               mask: nil,
                               primaryFormat: nil,
                               onMaskedTextChangedCallback: nil,
                               textFieldDisabled: false,
                               isBlackout: false,
                               textDidChange: ({ [weak self] text in
                                self?.inputEmail(text)
                               }))
        emailTextField.sampleTextField?.keyboardType = .default
        
        messageLbl.numberOfLines = 0
        messageLbl.attributedText = " Enter the email address from your account. A password reset code will be sent to it".attributed.alignment(.center).color(Style.Colors.titleCellGray).font(Style.Font.latoSemiBold(14))
        titlelBL.attributedText = "Reset password".attributed.alignment(.center).color(Style.Colors.white).font(Style.Font.latoBold(18))
        titlelBL.numberOfLines = 0
        
        button.gradientStyle = .base
        button.setAttributedTitle("Send code".attributed.alignment(.center).color(Style.Colors.white).font(Style.Font.latoSemiBold(14)), for: .normal)
        
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emailTextFieldContainer.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(44)
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
        }
        
        emailTextFieldTitle.snp.makeConstraints { (make) in
            make.left.equalTo(emailTextFieldContainer.snp.left).offset(8)
            make.top.equalTo(emailTextFieldContainer.snp.top).offset(6)
        }
        
        emailTextField.snp.makeConstraints { (make) in
            make.left.equalTo(emailTextFieldContainer.snp.left).offset(8)
            make.bottom.equalTo(emailTextFieldContainer.snp.bottom).offset(-6)
            make.top.equalTo(emailTextFieldTitle.snp.bottom).offset(5)
            make.right.equalTo(emailTextFieldContainer.snp.right).offset(-8)
        }
        
        
        messageLbl.snp.makeConstraints { (make) in
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.bottom.equalTo(emailTextFieldContainer.snp.top).offset(-16)
        }
        
        titlelBL.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make .bottom.equalTo(messageLbl.snp.top).offset(-8)
        }
        
        button.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(emailTextFieldContainer.snp.bottom).offset(11)
        }
    }
    
    private func setupBindings() {
        
    }
}

extension ResetPasswordController {
    struct RegisterData {

        var email: String
        var isShowEmailValid = true

        var isValidEmail: Bool {
            return email.isValidEmail
        }

        mutating func isValidData() -> Bool {

            if !isValidEmail {
                isShowEmailValid = false
            }

            return isValidEmail
        }
    }
}

//  LoginCoordinator.swift
//
//  Created by jekster on 14.05.2021.
//

import  UIKit
import Foundation

final class LoginCoordinator: BaseCoordinator, LoginCoordinatorOutput {

    // MARK: - LoginCoordinatorOutput
    
    var finishFlow: (() -> Void)?
    var logInSuccess: (() -> Void)?
    var registrationSuccess: (() -> Void)?

    // MARK: - Private properties
    
    private let router: Router

    init(router: Router) {
        self.router = router
    }

    override func start() {
        showController()
    }
    
    deinit {
        debugPrint("")
    }
}

// MARK: - Private functions

private extension LoginCoordinator {
    func showController() {
        let authService = ServiceFactory.shared.authService()
        let authStotage = ServiceFactory.shared.authStorage()

        let viewModel = LoginViewModel(authService: authService, authStotage: authStotage)

        viewModel.onEvent.delegate(to: self) { (coordinator, event) in
            switch event {
            case .didTapNew:
                coordinator.showRegistrationFlow()

            case .didTapLogin:
                coordinator.logInSuccess?()
                
            case .didTapForgot:
                coordinator.showResetPasswordFlow()
            }
        }

        let controller = LoginViewController(viewModel: viewModel)

        router.push(controller)
    }
    
    func showRegistrationFlow() {
        let authService = ServiceFactory.shared.authService()
        let authStorage = ServiceFactory.shared.authStorage()
        let viewModel = RegistrationViewModel(authService: authService, authStorage: authStorage)
        let coordinator = RegistrationCoordinator(router: router, viewModel: viewModel)
        addDependency(coordinator)
        
        coordinator.finishFlow = { [weak coordinator] in
            coordinator?.removeDependency(coordinator)
        }
        
        coordinator.start()
    }
    
    func showResetPasswordFlow() {
        let authService = ServiceFactory.shared.authService()
        let controller = ResetPasswordController(router: router, authService: authService)
        
        router.push(controller, animated: true, hideBottomBar: true, completion: nil)
    }
}


//  LoginViewController.swift
//
//  Created by jekster on 14.05.2021.
//

import UIKit
import RxSwift
import RxCocoa


public struct defaultPadding {
    let top: CGFloat = 16.0
    let left: CGFloat = 16.0
    let right: CGFloat = -16.0
    let bottom: CGFloat = 4
}

final class LoginViewController: ViewController {

    // MARK: - Public

    // LoginViewProtocol
    var onEvent = Closure<LoginViewEvent>()
    let padding = defaultPadding()
    // MARK: - Private properties
    private let viewModel: LoginViewModel
    private var containerView = UIView()
    private var tableView = TableView()
    private var disposeBag = DisposeBag()
    
    private var containerTip = UIView()
    private var tableViewTip = TableView(frame: CGRect(x: 0, y: 0, width: 80, height: 92))
    
    // MARK: - Lifecycle
    init(viewModel: LoginViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NavigationBarDecorator(self).decorate(as: .gray, with: "Login in account", animated: true, hideBackButton: false)
    }
    
    
        override func viewDidLoad() {
            super.viewDidLoad()
            setupViews()
            setupConstraints()
            setupBindings()
            viewModel.onViewEvent(.viewDidLoad)
  
            let rightButton = UIBarButtonItem(image: R.image.question(), style: .plain, target: self, action: #selector(buttonTapped))
            self.navigationItem.rightBarButtonItem  = rightButton
            self.navigationItem.rightBarButtonItem?.tintColor = Style.Colors.baseGrey
            
        }
    
    @objc func buttonTapped() {
                
        tableViewTip.update(sections: viewModel.makeSectionsToolTip())
        tableViewTip.backgroundColor = .clear
        tableViewTip.isScrollEnabled = false
        
        guard let item = self.navigationItem.rightBarButtonItem else { return }

        var preferences = ToolTipView.Preferences()
        preferences.positioning.contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        preferences.drawing.shadowOffset = CGSize(width: 0, height: 4)
        preferences.drawing.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        preferences.drawing.shadowRadius = 4
        preferences.drawing.shadowOpacity = 1
        
        ToolTipView.globalPreferences = preferences
        ToolTipView.show(forItem: item, contentView: tableViewTip, delegate: self)
    }
}

// MARK: - Private functions

private extension LoginViewController {
    
    private func setupViews() {
        self.view.addSubview(containerView)
        self.view.addSubview(tableView)
       
        containerView.backgroundColor = Style.Colors.defaultBackground
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableViewDidTap))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
        
    }
    
    @objc func tableViewDidTap() {
        view.endEditing(true)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(padding.top)
            $0.left.equalTo(padding.left)
            $0.right.equalTo(padding.right)
        }
    }
    

    private func setupBindings() {
        viewModel.onUpdate.delegate(to: self) { (view, update) in
           switch update {
           case .initialSetup(_): break
//                view.navigationItem.title = title
           case .updateData(let sections):
                view.tableView.update(sections: sections)
           }
       }
        viewModel.loginLoader.subscribe { [unowned self] event in
            guard let isShowLoader = event.element else { return }
            if isShowLoader {
                self.view.showActivityIndicator()
            } else {
                self.view.hideActivityIndicator()
            }
        }.disposed(by: disposeBag)
    }
}


// MARK: - UIPopoverPresentationControllerDelegate
extension LoginViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
           return .none
       }

       func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
           return .none
    }
}

// MARK: - ToolTipViewDelegate
extension LoginViewController: ToolTipViewDelegate {
    func easyTipViewDidDismiss(_ tipView : ToolTipView) {
        print(#function)
    }
    
    func easyTipViewDidTap(_ tipView: ToolTipView) {
        print(#function)
        
//        let view = UIView(frame: CGRect(x: UIScreen.main.bounds.x, y: UIScreen.main.bounds.y, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height()))
        
//        self.view.addSubview(view)
//        view.backgroundColor = .green
        
    }
}


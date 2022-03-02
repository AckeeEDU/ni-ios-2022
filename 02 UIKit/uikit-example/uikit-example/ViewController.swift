//
//  ViewController.swift
//  uikit-example
//
//  Created by Igor Rosocha on 23.02.2022.
//

import UIKit
import SnapKit

final class ViewController: UIViewController {
    
    override func loadView() {
        super.loadView()
        
        // Setup view background
        view.backgroundColor = .white
        
        // Basic button setup
        let luckyButton = UIButton(type: .system)
        luckyButton.setTitle("I'm feeling lucky!", for: .normal)
        // Adding handle of button tap gesture
        luckyButton.addTarget(self, action: #selector(luckyButtonTapped), for: .touchUpInside)
        // Adding button as a subview
        view.addSubview(luckyButton)
        // Setting up the constraints
        luckyButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation title
        navigationItem.title = "Homepage"
        
        // Adds right navigation bar button items
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .search,
                target: self,
                action: nil
            ),
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: nil
            )
        ]
    }
    
    /// Handles tapping the `luckyButton`
    @objc private func luckyButtonTapped() {
        let stonksVC = StonksViewController()
        navigationController?.pushViewController(stonksVC, animated: true)
    }
}


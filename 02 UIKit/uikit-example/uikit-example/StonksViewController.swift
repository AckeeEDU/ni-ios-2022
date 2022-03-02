//
//  StonksViewController.swift
//  uikit-example
//
//  Created by Igor Rosocha on 23.02.2022.
//

import UIKit

final class StonksViewController: UIViewController {
    
    override func loadView() {
        super.loadView()

        // Setup view background
        view.backgroundColor = .white
        
        // Image view setup
        let imageView = UIImageView(
            image: UIImage(named: "stonks")
        )
        // Adding image view as a subview
        view.addSubview(imageView)
        // Setting up the constraints
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up navigation title
        navigationItem.title = "Stonks"
    }
}

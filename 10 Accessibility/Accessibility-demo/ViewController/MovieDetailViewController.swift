//
//  MovieDetailViewController.swift
//  Accessibility-demo
//
//  Created by Igor Rosocha on 19.04.2022.
//

import CoreImage
import Kingfisher
import SnapKit
import UIKit

final class MovieDetailViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let movie: Movie
    
    // MARK: - Initialization

    init(movie: Movie) {
        self.movie = movie
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .systemBackground
        
        let imageView = UIImageView()
        let imageURL = URL(string: movie.cardImage)!
        let placeholderImage = UIImage(named: "mickey_placeholder")
        imageView.kf.setImage(with: imageURL, placeholder: placeholderImage)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = movie.title
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "Roboto-Bold", size: 30)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Play"
        configuration.image = UIImage(systemName: "play.fill")
        configuration.baseBackgroundColor = .black
        configuration.contentInsets = .init(top: 12.0, leading: 8.0, bottom: 12.0, trailing: 8.0)
        configuration.imagePadding = 12.0
        
        let playButton = UIButton(type: .system)
        playButton.configuration = configuration
        playButton.setTitleColor(.white, for: .normal)
        playButton.tintColor = .white
        playButton.layer.cornerRadius = 8.0
        playButton.layer.masksToBounds = true
        view.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = movie.description
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(playButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white
    }
}

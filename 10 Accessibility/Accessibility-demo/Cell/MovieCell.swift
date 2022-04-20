//
//  MovieCell.swift
//  Accessibility-demo
//
//  Created by Igor Rosocha on 19.04.2022.
//

import UIKit

final class MovieCell: UITableViewCell {
    
    // MARK: - Private properties
    
    private(set) weak var logoImageView: UIImageView!
    private(set) weak var titleLabel: UILabel!
    private(set) weak var subtitleLabel: UILabel!
    
    // MARK: - Initialization
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        isAccessibilityElement = true
        
        let logoImageView = UIImageView()
        logoImageView.layer.masksToBounds = true
        logoImageView.layer.cornerRadius = 4.0
        contentView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(100)
            make.width.equalTo(120)
            make.bottom.lessThanOrEqualToSuperview().inset(20)
        }
        self.logoImageView = logoImageView
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(logoImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
        }
        self.titleLabel = titleLabel
        
        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(20)
        }
        self.subtitleLabel = subtitleLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

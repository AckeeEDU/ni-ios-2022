//
//  MoviesListViewController.swift
//  Accessibility-demo
//
//  Created by Igor Rosocha on 19.04.2022.
//

import Kingfisher
import SnapKit
import UIKit

final class MoviesListViewController: UIViewController {
    
    // MARK: - Private properties
    
    private weak var tableView: UITableView!
    
    private let viewModel: MoviesListViewModel
    
    init(
        viewModel: MoviesListViewModel
    ) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
        
        title = "Disney Movies"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(MovieCell.self, forCellReuseIdentifier: "movieCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.tableView = tableView
    }
    
    // MARK: - Private helpers
    
    private func parseMovies() -> [Movie] {
        let url = Bundle.main.url(forResource: "disneyPlusMoviesData", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let movies = try! JSONDecoder().decode(Movies.self, from: data).values
        
        return Array(movies)
    }
}

// MARK: - UITableViewDataSource

extension MoviesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = viewModel.movies[indexPath.row]
        let title = movie.title
        let subtitle = movie.subtitle
        let imageURL = URL(string: movie.cardImage)!
        let placeholderImage = UIImage(named: "mickey_placeholder")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        cell.logoImageView.kf.setImage(with: imageURL, placeholder: placeholderImage)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MoviesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = viewModel.movies[indexPath.row]
        
        navigationController?.pushViewController(MovieDetailViewController(movie: movie), animated: true)
    }
}

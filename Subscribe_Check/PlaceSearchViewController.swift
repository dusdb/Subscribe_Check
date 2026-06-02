//
//  PlaceSearchViewController.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/06/02.
//

import UIKit
import MapKit

protocol PlaceSearchDelegate: AnyObject {
    func didSelectPlace(name: String, address: String, latitude: Double, longitude: Double)
}

class PlaceSearchViewController: UIViewController {

    weak var delegate: PlaceSearchDelegate?

    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var searchResults: [MKMapItem] = []
    private var searchTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "장소 검색"
        view.backgroundColor = AppColors.background

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소", style: .plain, target: self, action: #selector(cancelTapped)
        )

        setupSearchBar()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "업체명 또는 주소를 검색하세요"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    private func searchPlaces(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
            latitudinalMeters: 50000,
            longitudinalMeters: 50000
        )

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }

            if let error = error {
                print("검색 오류: \(error.localizedDescription)")
                return
            }

            self.searchResults = response?.mapItems ?? []
            self.tableView.reloadData()
        }
    }
}

// MARK: - UISearchBarDelegate
extension PlaceSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()

        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            tableView.reloadData()
            return
        }

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.searchPlaces(query: searchText)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text, !text.isEmpty {
            searchPlaces(query: text)
        }
    }
}

// MARK: - UITableViewDataSource
extension PlaceSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let item = searchResults[indexPath.row]

        cell.textLabel?.text = item.name ?? "이름 없음"
        cell.detailTextLabel?.text = item.placemark.title ?? ""
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        cell.textLabel?.textColor = AppColors.textPrimary

        // subtitle 스타일로 변경
        var content = cell.defaultContentConfiguration()
        content.text = item.name ?? "이름 없음"
        content.secondaryText = item.placemark.title ?? ""
        content.textProperties.font = .systemFont(ofSize: 15, weight: .semibold)
        content.textProperties.color = AppColors.textPrimary
        content.secondaryTextProperties.font = .systemFont(ofSize: 13, weight: .regular)
        content.secondaryTextProperties.color = AppColors.textSecondary
        cell.contentConfiguration = content

        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PlaceSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = searchResults[indexPath.row]

        let name = item.name ?? ""
        let address = item.placemark.title ?? ""
        let lat = item.placemark.coordinate.latitude
        let lon = item.placemark.coordinate.longitude

        delegate?.didSelectPlace(name: name, address: address, latitude: lat, longitude: lon)
        dismiss(animated: true)
    }
}

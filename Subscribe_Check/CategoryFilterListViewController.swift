//
//  CategoryFilterListViewController.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/27.
//

import UIKit

class CategoryFilterListViewController: UIViewController {

    private let category: SubscriptionCategory
    private let subscriptions: [Subscription]
    private let tableView = UITableView()

    init(category: SubscriptionCategory, subscriptions: [Subscription]) {
        self.category = category
        self.subscriptions = subscriptions
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(category.rawValue) 구독"
        view.backgroundColor = AppColors.background
        navigationItem.largeTitleDisplayMode = .never

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SubscriptionCell.self, forCellReuseIdentifier: "SubscriptionCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension CategoryFilterListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as? SubscriptionCell else {
            return UITableViewCell()
        }
        cell.configure(with: subscriptions[indexPath.row])
        return cell
    }
}

extension CategoryFilterListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = SubscriptionDetailViewController(subscription: subscriptions[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

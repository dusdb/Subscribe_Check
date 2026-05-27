//
//  CategoryViewController.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/18.
//

import UIKit

class CategoryViewController: UIViewController {

    private var collectionView: UICollectionView!
    private let emptyLabel = UILabel()
    private var categoryData: [(category: SubscriptionCategory, subs: [Subscription], total: Int)] = []
    private let store = SubscriptionStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "카테고리 분석"
        view.backgroundColor = AppColors.background
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        setupCollectionView()
        setupEmptyState()
        observeStore()
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func observeStore() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadData),
            name: SubscriptionStore.didUpdateNotification, object: nil
        )
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let itemWidth = (UIScreen.main.bounds.width - 16 * 2 - 12) / 2
        layout.itemSize = CGSize(width: itemWidth, height: 190)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCardCell.self, forCellWithReuseIdentifier: "CategoryCardCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupEmptyState() {
        emptyLabel.text = "등록된 구독이 없습니다\n구독을 추가하면 카테고리별 분석을 볼 수 있어요"
        emptyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        emptyLabel.textColor = AppColors.textSecondary
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func reloadData() {
        let grouped = store.subscriptionsByCategory()
        let totalMonthly = max(store.totalMonthlyPrice, 1)

        categoryData = SubscriptionCategory.allCases.compactMap { cat in
            guard let subs = grouped[cat], !subs.isEmpty else { return nil }
            let total = subs.reduce(0) { $0 + $1.normalizedMonthlyPrice }
            return (category: cat, subs: subs, total: total)
        }.sorted { $0.total > $1.total }

        let isEmpty = categoryData.isEmpty
        emptyLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCardCell", for: indexPath) as? CategoryCardCell else {
            return UICollectionViewCell()
        }
        let data = categoryData[indexPath.item]
        let totalMonthly = max(store.totalMonthlyPrice, 1)
        let ratio = Double(data.total) / Double(totalMonthly)
        cell.configure(category: data.category, monthlyTotal: data.total, count: data.subs.count, ratio: ratio)
        return cell
    }
}

extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = categoryData[indexPath.item]
        let filterVC = CategoryFilterListViewController(category: data.category, subscriptions: data.subs)
        navigationController?.pushViewController(filterVC, animated: true)
    }
}

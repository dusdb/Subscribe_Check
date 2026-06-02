//
//  DashboardViewController.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/18.
//

import UIKit

class DashboardViewController: UIViewController {

    // MARK: - UI 요소
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    private let summaryCardView = UIView()
    private let monthlyTotalLabel = UILabel()
    private let yearlyTotalLabel = UILabel()
    private let activeCountLabel = UILabel()
    private let warningCountLabel = UILabel()

    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    private var tableHeightConstraint: NSLayoutConstraint?

    // MARK: - 데이터
    private let store = SubscriptionStore.shared
    private var activeSubscriptions: [Subscription] = []
    
    private var currentSortMode: Int = 0  // 0: D-Day순, 1: 금액순, 2: 이름순

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tabBarItem = UITabBarItem(title: "대시보드", image: UIImage(systemName: "house.fill"), tag: 0)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tabBarItem = UITabBarItem(title: "대시보드", image: UIImage(systemName: "house.fill"), tag: 0)
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "대시보드"
        
        view.backgroundColor = AppColors.background
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        setupUI()
        setupTableView()
        setupAddButton()
        setupWelcomeCard()
        observeStore()

        //store.loadSampleData()
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
            self,
            selector: #selector(handleStoreUpdate),
            name: SubscriptionStore.didUpdateNotification,
            object: nil
        )
    }

    @objc private func handleStoreUpdate() {
        reloadData()
    }

    // MARK: - UI 구성
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        setupSummaryCard()
    }

    private func setupSummaryCard() {
        summaryCardView.backgroundColor = AppColors.primary
        summaryCardView.layer.cornerRadius = 16
        summaryCardView.layer.shadowColor = UIColor.black.cgColor
        summaryCardView.layer.shadowOpacity = 0.15
        summaryCardView.layer.shadowRadius = 10
        summaryCardView.layer.shadowOffset = CGSize(width: 0, height: 4)

        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.spacing = 12
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        summaryCardView.addSubview(cardStack)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: summaryCardView.topAnchor, constant: 24),
            cardStack.leadingAnchor.constraint(equalTo: summaryCardView.leadingAnchor, constant: 24),
            cardStack.trailingAnchor.constraint(equalTo: summaryCardView.trailingAnchor, constant: -24),
            cardStack.bottomAnchor.constraint(equalTo: summaryCardView.bottomAnchor, constant: -24)
        ])

        let titleLabel = UILabel()
        titleLabel.text = "이번 달 구독료"
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)

        monthlyTotalLabel.font = .systemFont(ofSize: 34, weight: .bold)
        monthlyTotalLabel.textColor = .white

        yearlyTotalLabel.font = .systemFont(ofSize: 13, weight: .regular)
        yearlyTotalLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        let infoRow = UIStackView()
        infoRow.axis = .horizontal
        infoRow.distribution = .fillEqually

        activeCountLabel.font = .systemFont(ofSize: 13, weight: .medium)
        activeCountLabel.textColor = UIColor.white.withAlphaComponent(0.9)

        warningCountLabel.font = .systemFont(ofSize: 13, weight: .medium)
        warningCountLabel.textColor = UIColor(red: 255/255, green: 214/255, blue: 10/255, alpha: 1.0)
        warningCountLabel.textAlignment = .right

        infoRow.addArrangedSubview(activeCountLabel)
        infoRow.addArrangedSubview(warningCountLabel)

        let separator = UIView()
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        cardStack.addArrangedSubview(titleLabel)
        cardStack.addArrangedSubview(monthlyTotalLabel)
        cardStack.addArrangedSubview(yearlyTotalLabel)
        cardStack.addArrangedSubview(separator)
        cardStack.addArrangedSubview(infoRow)

        contentStackView.addArrangedSubview(summaryCardView)
    }

    // MARK: - 테이블 뷰
    private func setupTableView() {
        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 12
        
        let sectionTitle = UILabel()
        sectionTitle.text = "내 구독 목록"
        sectionTitle.font = .systemFont(ofSize: 20, weight: .bold)
        sectionTitle.textColor = AppColors.textPrimary
        headerStack.addArrangedSubview(sectionTitle)

        let sortSegment = UISegmentedControl(items: ["D-day순", "금액순", "이름순"])
        sortSegment.selectedSegmentIndex = 0
        sortSegment.addTarget(self, action: #selector(sortChanged(_:)), for: .valueChanged)
        sortSegment.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13)], for: .normal)
        headerStack.addArrangedSubview(sortSegment)

        contentStackView.addArrangedSubview(headerStack)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SubscriptionCell.self, forCellReuseIdentifier: "SubscriptionCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        contentStackView.addArrangedSubview(tableView)

        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint?.isActive = true

        emptyStateLabel.text = "아직 등록된 구독이 없습니다\n아래 + 버튼을 눌러 구독을 추가해 보세요"
        emptyStateLabel.font = .systemFont(ofSize: 15, weight: .regular)
        emptyStateLabel.textColor = AppColors.textSecondary
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        contentStackView.addArrangedSubview(emptyStateLabel)
    }

    // MARK: - 추가 버튼
    private func setupAddButton() {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.backgroundColor = AppColors.primary
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 28
        addButton.layer.shadowColor = AppColors.primary.cgColor
        addButton.layer.shadowOpacity = 0.4
        addButton.layer.shadowRadius = 8
        addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupWelcomeCard() {
        let welcomeCard = UIView()
        welcomeCard.backgroundColor = AppColors.cardBackground
        welcomeCard.layer.cornerRadius = 16
        welcomeCard.layer.shadowColor = UIColor.black.cgColor
        welcomeCard.layer.shadowOpacity = 0.06
        welcomeCard.layer.shadowRadius = 6
        welcomeCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        welcomeCard.tag = 999

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        welcomeCard.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: welcomeCard.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: welcomeCard.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: welcomeCard.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: welcomeCard.bottomAnchor, constant: -24)
        ])

        let iconLabel = UILabel()
        iconLabel.text = "💰"
        iconLabel.font = .systemFont(ofSize: 48)

        let titleLabel = UILabel()
        titleLabel.text = "구독을 추가해 보세요"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = AppColors.textPrimary

        let descLabel = UILabel()
        descLabel.text = "아래 + 버튼을 눌러\n사용 중인 구독 서비스를 등록하세요"
        descLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descLabel.textColor = AppColors.textSecondary
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0

        stack.addArrangedSubview(iconLabel)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(descLabel)

        welcomeCard.isHidden = true
        contentStackView.addArrangedSubview(welcomeCard)
    }
    
    @objc private func sortChanged(_ sender: UISegmentedControl) {
        currentSortMode = sender.selectedSegmentIndex
        reloadData()
    }

    @objc private func addButtonTapped() {
        let addVC = AddSubscriptionViewController()
        addVC.delegate = self
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }

    // MARK: - 데이터 갱신
    private func reloadData() {
        switch currentSortMode {
        case 1: // 금액순
            activeSubscriptions = store.activeSubscriptions.sorted {
                $0.normalizedMonthlyPrice > $1.normalizedMonthlyPrice
            }
        case 2: // 이름순
            activeSubscriptions = store.activeSubscriptions.sorted {
                $0.serviceName < $1.serviceName
            }
        default: // D-day순
            activeSubscriptions = store.activeSubscriptions.sorted {
                $0.daysUntilNextBilling < $1.daysUntilNextBilling
            }
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let monthlyText = formatter.string(from: NSNumber(value: store.totalMonthlyPrice)) ?? "0"
        monthlyTotalLabel.text = "\(monthlyText)원"

        let yearlyText = formatter.string(from: NSNumber(value: store.totalYearlyPrice)) ?? "0"
        yearlyTotalLabel.text = "연간 환산 약 \(yearlyText)원"

        activeCountLabel.text = "구독 \(store.activeSubscriptions.count)개"

        let warningCount = store.warningSubscriptions.count
        if warningCount > 0 {
            warningCountLabel.text = "⚠️ 미사용 경고 \(warningCount)개"
            warningCountLabel.isHidden = false
        } else {
            warningCountLabel.isHidden = true
        }

        let isEmpty = activeSubscriptions.isEmpty
            emptyStateLabel.isHidden = true
            tableView.isHidden = isEmpty

        if let welcomeCard = contentStackView.viewWithTag(999) {
            welcomeCard.isHidden = !isEmpty
        }

        tableView.reloadData()

        let tableHeight = CGFloat(activeSubscriptions.count) * 80
        tableHeightConstraint?.constant = max(tableHeight, 0)
        
        NotificationManager.shared.schedulePaymentReminders()
    }
}

// MARK: - UITableViewDataSource
extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeSubscriptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as? SubscriptionCell else {
            return UITableViewCell()
        }
        let subscription = activeSubscriptions[indexPath.row]
        cell.configure(with: subscription)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let subscription = activeSubscriptions[indexPath.row]
        let detailVC = SubscriptionDetailViewController(subscription: subscription)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - AddSubscriptionDelegate
extension DashboardViewController: AddSubscriptionDelegate {
    func didAddSubscription() {
        reloadData()
    }
}

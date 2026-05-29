//
//  SubscriptionDetailViewController.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/24.
//

import UIKit

class SubscriptionDetailViewController: UIViewController {

    private var subscription: Subscription
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    init(subscription: Subscription) {
        self.subscription = subscription
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = subscription.serviceName
        view.backgroundColor = AppColors.background
        navigationItem.largeTitleDisplayMode = .never

        setupUI()
        populateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let updated = SubscriptionStore.shared.subscriptions.first(where: { $0.id == subscription.id }) {
            subscription = updated
            populateData()
        }
    }

    // MARK: - UI 구성
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    private func populateData() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateStyle = .medium

        // === 핵심 정보 카드 ===
        let mainCard = makeCard()
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainCard.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: mainCard.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: mainCard.bottomAnchor, constant: -20)
        ])

        let priceText = formatter.string(from: NSNumber(value: subscription.normalizedMonthlyPrice)) ?? "0"
        mainStack.addArrangedSubview(makeInfoRow(icon: "wonsign.circle.fill", title: "월 결제 금액", value: "\(priceText)원"))
        mainStack.addArrangedSubview(makeInfoRow(icon: "calendar", title: "결제일", value: "매월 \(subscription.billingDay)일"))
        mainStack.addArrangedSubview(makeInfoRow(icon: "arrow.clockwise", title: "결제 주기", value: subscription.billingCycle.rawValue))
        mainStack.addArrangedSubview(makeInfoRow(icon: "tag.fill", title: "카테고리", value: subscription.category.rawValue))

        let yearlyText = formatter.string(from: NSNumber(value: subscription.yearlyPrice)) ?? "0"
        mainStack.addArrangedSubview(makeInfoRow(icon: "chart.bar.fill", title: "연간 환산", value: "\(yearlyText)원"))

        if !subscription.memo.isEmpty {
            mainStack.addArrangedSubview(makeInfoRow(icon: "note.text", title: "메모", value: subscription.memo))
        }

        contentStack.addArrangedSubview(mainCard)

        // === D-day 카드 ===
        let dDayCard = makeCard()
        let dDayLabel = UILabel()
        dDayLabel.text = "다음 결제까지 D-\(subscription.daysUntilNextBilling)"
        dDayLabel.font = .systemFont(ofSize: 22, weight: .bold)
        dDayLabel.textColor = subscription.daysUntilNextBilling <= 3 ? AppColors.danger : AppColors.primary
        dDayLabel.textAlignment = .center
        dDayLabel.translatesAutoresizingMaskIntoConstraints = false
        dDayCard.addSubview(dDayLabel)

        NSLayoutConstraint.activate([
            dDayLabel.topAnchor.constraint(equalTo: dDayCard.topAnchor, constant: 20),
            dDayLabel.leadingAnchor.constraint(equalTo: dDayCard.leadingAnchor, constant: 20),
            dDayLabel.trailingAnchor.constraint(equalTo: dDayCard.trailingAnchor, constant: -20),
            dDayLabel.bottomAnchor.constraint(equalTo: dDayCard.bottomAnchor, constant: -20)
        ])
        contentStack.addArrangedSubview(dDayCard)

        // === 미사용 경고 카드 ===
        if subscription.unusedWarningLevel > 0 {
            let warningCard = makeCard()
            warningCard.backgroundColor = subscription.unusedWarningLevel == 2
                ? AppColors.danger.withAlphaComponent(0.1)
                : AppColors.warning.withAlphaComponent(0.1)

            let warningLabel = UILabel()
            warningLabel.numberOfLines = 0
            warningLabel.textAlignment = .center
            warningLabel.font = .systemFont(ofSize: 15, weight: .medium)

            let days = subscription.daysSinceLastUsed
            if subscription.unusedWarningLevel == 2 {
                warningLabel.text = "🔴 \(days)일째 미사용 중입니다\n정말 필요한 구독인지 확인해 보세요"
                warningLabel.textColor = AppColors.danger
            } else {
                warningLabel.text = "🟠 \(days)일째 미사용 중입니다\n최근에 이 서비스를 사용하셨나요?"
                warningLabel.textColor = AppColors.warning
            }

            warningLabel.translatesAutoresizingMaskIntoConstraints = false
            warningCard.addSubview(warningLabel)
            NSLayoutConstraint.activate([
                warningLabel.topAnchor.constraint(equalTo: warningCard.topAnchor, constant: 16),
                warningLabel.leadingAnchor.constraint(equalTo: warningCard.leadingAnchor, constant: 16),
                warningLabel.trailingAnchor.constraint(equalTo: warningCard.trailingAnchor, constant: -16),
                warningLabel.bottomAnchor.constraint(equalTo: warningCard.bottomAnchor, constant: -16)
            ])
            contentStack.addArrangedSubview(warningCard)
        }

        // === 무료체험 정보 ===
        if let trialDays = subscription.freeTrialDaysLeft {
            let trialCard = makeCard()
            trialCard.backgroundColor = AppColors.primary.withAlphaComponent(0.1)

            let trialLabel = UILabel()
            trialLabel.text = "무료체험 종료까지 \(trialDays)일 남았습니다"
            trialLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            trialLabel.textColor = AppColors.primary
            trialLabel.textAlignment = .center
            trialLabel.translatesAutoresizingMaskIntoConstraints = false
            trialCard.addSubview(trialLabel)
            NSLayoutConstraint.activate([
                trialLabel.topAnchor.constraint(equalTo: trialCard.topAnchor, constant: 16),
                trialLabel.leadingAnchor.constraint(equalTo: trialCard.leadingAnchor, constant: 16),
                trialLabel.trailingAnchor.constraint(equalTo: trialCard.trailingAnchor, constant: -16),
                trialLabel.bottomAnchor.constraint(equalTo: trialCard.bottomAnchor, constant: -16)
            ])
            contentStack.addArrangedSubview(trialCard)
        }

        // === 마지막 사용일 ===
        if let lastUsed = subscription.lastUsedDate {
            let infoCard = makeCard()
            let infoLabel = UILabel()
            infoLabel.text = "마지막 사용: \(dateFormatter.string(from: lastUsed))"
            infoLabel.font = .systemFont(ofSize: 14, weight: .regular)
            infoLabel.textColor = AppColors.textSecondary
            infoLabel.textAlignment = .center
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            infoCard.addSubview(infoLabel)
            NSLayoutConstraint.activate([
                infoLabel.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 16),
                infoLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
                infoLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
                infoLabel.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -16)
            ])
            contentStack.addArrangedSubview(infoCard)
        }

        // === 버튼 그룹 ===
        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.spacing = 12

        let useButton = makeActionButton(title: "사용했어요", color: AppColors.positive)
        useButton.addTarget(self, action: #selector(markAsUsedTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(useButton)

        let editButton = makeActionButton(title: "구독 정보 수정", color: AppColors.primary)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(editButton)

        let aiButton = makeActionButton(title: "AI 한줄 분석", color: UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0))
                aiButton.addTarget(self, action: #selector(aiAnalysisTapped), for: .touchUpInside)
                buttonStack.addArrangedSubview(aiButton)
        
        if subscription.status == .active {
            let cancelButton = makeActionButton(title: "구독 해지", color: AppColors.warning)
            cancelButton.addTarget(self, action: #selector(cancelSubscriptionTapped), for: .touchUpInside)
            buttonStack.addArrangedSubview(cancelButton)
        } else {
            let reactivateButton = makeActionButton(title: "구독 재활성화", color: AppColors.positive)
            reactivateButton.addTarget(self, action: #selector(reactivateTapped), for: .touchUpInside)
            buttonStack.addArrangedSubview(reactivateButton)
        }

        let deleteButton = makeActionButton(title: "구독 삭제", color: AppColors.danger)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(deleteButton)

        contentStack.addArrangedSubview(buttonStack)
    }

    // MARK: - 카드 헬퍼
    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = AppColors.cardBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        return card
    }

    private func makeInfoRow(icon: String, title: String, value: String) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = AppColors.primary
        iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = AppColors.textSecondary

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        valueLabel.textColor = AppColors.textPrimary
        valueLabel.textAlignment = .right

        row.addArrangedSubview(iconView)
        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(UIView())
        row.addArrangedSubview(valueLabel)

        return row
    }

    private func makeActionButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }

    // MARK: - 액션
    @objc private func markAsUsedTapped() {
        SubscriptionStore.shared.markAsUsed(id: subscription.id)
        if let updated = SubscriptionStore.shared.subscriptions.first(where: { $0.id == subscription.id }) {
            subscription = updated
        }
        populateData()

        let toast = UILabel()
        toast.text = "✅ 사용 기록이 업데이트되었습니다"
        toast.font = .systemFont(ofSize: 14, weight: .medium)
        toast.textColor = .white
        toast.backgroundColor = AppColors.positive
        toast.textAlignment = .center
        toast.layer.cornerRadius = 8
        toast.clipsToBounds = true
        toast.alpha = 0
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            toast.widthAnchor.constraint(equalToConstant: 280),
            toast.heightAnchor.constraint(equalToConstant: 40)
        ])

        UIView.animate(withDuration: 0.3, animations: { toast.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: { toast.alpha = 0 }) { _ in
                toast.removeFromSuperview()
            }
        }
    }

    @objc private func editTapped() {
        let editVC = AddSubscriptionViewController()
        editVC.subscriptionToEdit = subscription
        editVC.delegate = self
        let nav = UINavigationController(rootViewController: editVC)
        present(nav, animated: true)
    }
    
    @objc private func aiAnalysisTapped() {
        let loadingAlert = UIAlertController(title: "AI 분석 중", message: "잠시만 기다려주세요...", preferredStyle: .alert)
        present(loadingAlert, animated: true)

        GeminiService.shared.analyzeSubscriptions { [weak self] result in
            loadingAlert.dismiss(animated: true) {
                guard let self = self else { return }
                let message = result ?? "분석에 실패했습니다. 네트워크 연결을 확인해주세요."
                let resultAlert = UIAlertController(title: "AI 분석 결과", message: message, preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(resultAlert, animated: true)
            }
        }
    }

    @objc private func cancelSubscriptionTapped() {
        let alert = UIAlertController(
            title: "구독 해지",
            message: "\(subscription.serviceName) 구독을 해지하시겠습니까?\n목록에서 비활성 처리됩니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "해지", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            SubscriptionStore.shared.cancelSubscription(id: self.subscription.id)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func reactivateTapped() {
        SubscriptionStore.shared.reactivateSubscription(id: subscription.id)
        if let updated = SubscriptionStore.shared.subscriptions.first(where: { $0.id == subscription.id }) {
            subscription = updated
        }
        populateData()
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "구독 삭제",
            message: "'\(subscription.serviceName)' 구독을 완전히 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            SubscriptionStore.shared.deleteSubscription(id: self.subscription.id)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - AddSubscriptionDelegate
extension SubscriptionDetailViewController: AddSubscriptionDelegate {
    func didAddSubscription() {
        if let updated = SubscriptionStore.shared.subscriptions.first(where: { $0.id == subscription.id }) {
            subscription = updated
            populateData()
        }
    }
}

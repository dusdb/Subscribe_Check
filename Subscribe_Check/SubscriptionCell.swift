//
//  SubscriptionCell.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/19.
//

import UIKit

class SubscriptionCell: UITableViewCell {

    private let cardView = UIView()
    private let iconImageView = UIImageView()
    private let serviceNameLabel = UILabel()
    private let priceLabel = UILabel()
    private let dDayLabel = UILabel()
    private let warningDot = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        cardView.backgroundColor = AppColors.cardBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 6
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = AppColors.primary
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        serviceNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        serviceNameLabel.textColor = AppColors.textPrimary

        priceLabel.font = .systemFont(ofSize: 14, weight: .regular)
        priceLabel.textColor = AppColors.textSecondary

        dDayLabel.font = .systemFont(ofSize: 13, weight: .bold)
        dDayLabel.textAlignment = .right

        warningDot.layer.cornerRadius = 4
        warningDot.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [serviceNameLabel, priceLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let rightStack = UIStackView(arrangedSubviews: [dDayLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing

        let mainStack = UIStackView(arrangedSubviews: [iconImageView, textStack, rightStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(mainStack)
        cardView.addSubview(warningDot)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            warningDot.widthAnchor.constraint(equalToConstant: 8),
            warningDot.heightAnchor.constraint(equalToConstant: 8),
            warningDot.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            warningDot.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12)
        ])
    }

    func configure(with subscription: Subscription) {
        serviceNameLabel.text = subscription.serviceName

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let priceText = formatter.string(from: NSNumber(value: subscription.normalizedMonthlyPrice)) ?? "0"
        priceLabel.text = "월 \(priceText)원 · \(subscription.billingCycle.rawValue)"

        let dDays = subscription.daysUntilNextBilling
        if dDays == 0 {
            dDayLabel.text = "D-Day"
            dDayLabel.textColor = AppColors.danger
        } else if dDays <= 3 {
            dDayLabel.text = "D-\(dDays)"
            dDayLabel.textColor = AppColors.danger
        } else if dDays <= 7 {
            dDayLabel.text = "D-\(dDays)"
            dDayLabel.textColor = AppColors.warning
        } else {
            dDayLabel.text = "D-\(dDays)"
            dDayLabel.textColor = AppColors.textSecondary
        }

        iconImageView.image = UIImage(systemName: subscription.category.iconName)

        switch subscription.unusedWarningLevel {
        case 2:
            warningDot.backgroundColor = AppColors.danger
            warningDot.isHidden = false
        case 1:
            warningDot.backgroundColor = AppColors.warning
            warningDot.isHidden = false
        default:
            warningDot.isHidden = true
        }

        if let trialDays = subscription.freeTrialDaysLeft {
            priceLabel.text = "무료체험 D-\(trialDays) · 이후 월 \(priceText)원"
            priceLabel.textColor = AppColors.primary
        } else {
            priceLabel.textColor = AppColors.textSecondary
        }
    }
}

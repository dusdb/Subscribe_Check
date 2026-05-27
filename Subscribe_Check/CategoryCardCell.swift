//
//  CategoryCardCell.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/27.
//

import UIKit

class CategoryCardCell: UICollectionViewCell {

    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let totalLabel = UILabel()
    private let countLabel = UILabel()
    private let ratioBar = UIView()
    private let ratioFill = UIView()
    private let ratioLabel = UILabel()
    private var ratioWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.backgroundColor = AppColors.cardBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.06
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])

        iconView.contentMode = .scaleAspectFit
        iconView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 32).isActive = true

        let topRow = UIStackView(arrangedSubviews: [iconView, UIView()])
        topRow.axis = .horizontal
        stack.addArrangedSubview(topRow)

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = AppColors.textPrimary
        stack.addArrangedSubview(nameLabel)

        totalLabel.font = .systemFont(ofSize: 20, weight: .bold)
        totalLabel.textColor = AppColors.textPrimary
        stack.addArrangedSubview(totalLabel)

        countLabel.font = .systemFont(ofSize: 12, weight: .regular)
        countLabel.textColor = AppColors.textSecondary
        stack.addArrangedSubview(countLabel)

        ratioBar.backgroundColor = AppColors.background
        ratioBar.layer.cornerRadius = 3
        ratioBar.heightAnchor.constraint(equalToConstant: 6).isActive = true

        ratioFill.layer.cornerRadius = 3
        ratioFill.translatesAutoresizingMaskIntoConstraints = false
        ratioBar.addSubview(ratioFill)

        NSLayoutConstraint.activate([
            ratioFill.leadingAnchor.constraint(equalTo: ratioBar.leadingAnchor),
            ratioFill.topAnchor.constraint(equalTo: ratioBar.topAnchor),
            ratioFill.bottomAnchor.constraint(equalTo: ratioBar.bottomAnchor)
        ])

        stack.addArrangedSubview(ratioBar)

        ratioLabel.font = .systemFont(ofSize: 11, weight: .medium)
        ratioLabel.textColor = AppColors.textSecondary
        stack.addArrangedSubview(ratioLabel)
    }

    func configure(category: SubscriptionCategory, monthlyTotal: Int, count: Int, ratio: Double) {
        iconView.image = UIImage(systemName: category.iconName)
        iconView.tintColor = colorFromHex(category.colorHex)
        nameLabel.text = category.rawValue

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        totalLabel.text = "\(formatter.string(from: NSNumber(value: monthlyTotal)) ?? "0")원"

        countLabel.text = "구독 \(count)개"

        let percent = Int(ratio * 100)
        ratioLabel.text = "전체의 \(percent)%"

        ratioFill.backgroundColor = colorFromHex(category.colorHex)

        ratioWidthConstraint?.isActive = false
        ratioWidthConstraint = ratioFill.widthAnchor.constraint(
            equalTo: ratioBar.widthAnchor,
            multiplier: CGFloat(min(ratio, 1.0))
        )
        ratioWidthConstraint?.isActive = true
    }

    private func colorFromHex(_ hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

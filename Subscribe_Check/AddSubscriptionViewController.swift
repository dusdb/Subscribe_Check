//
//  AddSubscriptionViewController.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/19.
//

import UIKit
import MapKit

protocol AddSubscriptionDelegate: AnyObject {
    func didAddSubscription()
}

class AddSubscriptionViewController: UIViewController {

    weak var delegate: AddSubscriptionDelegate?
    var subscriptionToEdit: Subscription?

    // MARK: - UI 요소
    private let scrollView = UIScrollView()
    private let formStack = UIStackView()

    private let serviceNameField = UITextField()
    private let priceField = UITextField()
    private let billingDayField = UITextField()
    private let memoField = UITextField()

    private let billingCycleSegment = UISegmentedControl(items: ["월간", "연간"])
    private var categorySegment: UISegmentedControl!

    private let freeTrialSwitch = UISwitch()
    private let freeTrialDatePicker = UIDatePicker()
    private let freeTrialContainer = UIStackView()

    private let offlineSwitch = UISwitch()
    private let addressField = UITextField()
    private let offlineContainer = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background

        let isEditing = subscriptionToEdit != nil
        title = isEditing ? "구독 수정" : "구독 추가"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소", style: .plain, target: self, action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: isEditing ? "저장" : "추가", style: .done, target: self, action: #selector(saveTapped)
        )

        setupForm()

        if let sub = subscriptionToEdit {
            fillFormWith(sub)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - 폼 구성
    private func setupForm() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        formStack.axis = .vertical
        formStack.spacing = 24
        formStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(formStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            formStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            formStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            formStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            formStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            formStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48)
        ])

        // 서비스명
        formStack.addArrangedSubview(
            makeFieldGroup(label: "서비스 이름 *", field: serviceNameField, placeholder: "예: 넷플릭스")
        )
        serviceNameField.autocorrectionType = .no

        // 금액
        formStack.addArrangedSubview(
            makeFieldGroup(label: "결제 금액 (원) *", field: priceField, placeholder: "예: 17000")
        )
        priceField.keyboardType = .numberPad

        // 결제 주기
        billingCycleSegment.selectedSegmentIndex = 0
        formStack.addArrangedSubview(makeControlGroup(label: "결제 주기", control: billingCycleSegment))

        // 결제일
        formStack.addArrangedSubview(
            makeFieldGroup(label: "결제일 (1~31) *", field: billingDayField, placeholder: "예: 15")
        )
        billingDayField.keyboardType = .numberPad

        // 카테고리
        let categoryItems = SubscriptionCategory.allCases.map { $0.rawValue }
        categorySegment = UISegmentedControl(items: categoryItems)
        categorySegment.selectedSegmentIndex = 0
        categorySegment.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        formStack.addArrangedSubview(makeControlGroup(label: "카테고리", control: categorySegment))

        // 메모
        formStack.addArrangedSubview(
            makeFieldGroup(label: "메모 (선택)", field: memoField, placeholder: "예: 가족 공유 플랜")
        )

        // 무료체험 토글
        freeTrialSwitch.addTarget(self, action: #selector(freeTrialToggled), for: .valueChanged)
        formStack.addArrangedSubview(makeSwitchGroup(label: "무료체험 중", switchControl: freeTrialSwitch))

        // 무료체험 만료일
        freeTrialDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            freeTrialDatePicker.preferredDatePickerStyle = .compact
        }
        freeTrialDatePicker.minimumDate = Date()
        freeTrialContainer.axis = .vertical
        freeTrialContainer.spacing = 8
        let trialLabel = UILabel()
        trialLabel.text = "무료체험 만료일"
        trialLabel.font = .systemFont(ofSize: 14, weight: .medium)
        trialLabel.textColor = AppColors.textSecondary
        freeTrialContainer.addArrangedSubview(trialLabel)
        freeTrialContainer.addArrangedSubview(freeTrialDatePicker)
        freeTrialContainer.isHidden = true
        formStack.addArrangedSubview(freeTrialContainer)

        // 오프라인 토글
        offlineSwitch.addTarget(self, action: #selector(offlineToggled), for: .valueChanged)
        formStack.addArrangedSubview(
            makeSwitchGroup(label: "오프라인 구독 (헬스장 등)", switchControl: offlineSwitch)
        )

        // 오프라인 주소
        offlineContainer.axis = .vertical
        offlineContainer.spacing = 8
        offlineContainer.isHidden = true
        offlineContainer.addArrangedSubview(
            makeFieldGroup(label: "주소", field: addressField, placeholder: "예: 서울시 강남구 역삼동")
        )
        formStack.addArrangedSubview(offlineContainer)
    }

    // MARK: - 헬퍼: UI 그룹 생성
    private func makeFieldGroup(label: String, field: UITextField, placeholder: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8

        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = AppColors.textSecondary

        field.placeholder = placeholder
        field.borderStyle = .none
        field.backgroundColor = AppColors.cardBackground
        field.layer.cornerRadius = 12
        field.font = .systemFont(ofSize: 16)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.rightViewMode = .always
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
        field.layer.shadowColor = UIColor.black.cgColor
        field.layer.shadowOpacity = 0.04
        field.layer.shadowRadius = 4
        field.layer.shadowOffset = CGSize(width: 0, height: 2)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(field)
        return stack
    }

    private func makeControlGroup(label: String, control: UIView) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8

        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = AppColors.textSecondary

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(control)
        return stack
    }

    private func makeSwitchGroup(label: String, switchControl: UISwitch) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12

        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = AppColors.textPrimary

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(switchControl)
        return stack
    }

    // MARK: - 토글 액션
    @objc private func freeTrialToggled() {
        freeTrialContainer.isHidden = !freeTrialSwitch.isOn
    }

    @objc private func offlineToggled() {
        offlineContainer.isHidden = !offlineSwitch.isOn
    }

    // MARK: - 수정 모드: 기존 데이터 채우기
    private func fillFormWith(_ sub: Subscription) {
        serviceNameField.text = sub.serviceName
        priceField.text = "\(sub.monthlyPrice)"
        billingDayField.text = "\(sub.billingDay)"
        memoField.text = sub.memo
        billingCycleSegment.selectedSegmentIndex = sub.billingCycle == .monthly ? 0 : 1

        if let index = SubscriptionCategory.allCases.firstIndex(of: sub.category) {
            categorySegment.selectedSegmentIndex = index
        }

        freeTrialSwitch.isOn = sub.isFreeTrial
        if sub.isFreeTrial {
            freeTrialContainer.isHidden = false
            if let endDate = sub.freeTrialEndDate {
                freeTrialDatePicker.date = endDate
            }
        }

        offlineSwitch.isOn = sub.isOffline
        if sub.isOffline {
            offlineContainer.isHidden = false
            addressField.text = sub.address
        }
    }

    // MARK: - 액션
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        // 입력 검증
        guard let name = serviceNameField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(message: "서비스 이름을 입력해주세요")
            return
        }

        guard let priceText = priceField.text, let price = Int(priceText), price > 0 else {
            showAlert(message: "올바른 금액을 입력해주세요")
            return
        }

        guard let dayText = billingDayField.text, let day = Int(dayText), day >= 1, day <= 31 else {
            showAlert(message: "결제일은 1~31 사이의 숫자를 입력해주세요")
            return
        }

        let billingCycle: BillingCycle = billingCycleSegment.selectedSegmentIndex == 0 ? .monthly : .yearly
        let category = SubscriptionCategory.allCases[categorySegment.selectedSegmentIndex]

        if offlineSwitch.isOn, let address = addressField.text, !address.isEmpty {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
                guard let self = self else { return }
                let lat = placemarks?.first?.location?.coordinate.latitude
                let lon = placemarks?.first?.location?.coordinate.longitude
                self.saveSubscription(
                    name: name, price: price, cycle: billingCycle, day: day,
                    category: category, isOffline: true,
                    latitude: lat, longitude: lon, address: address
                )
            }
        } else {
            saveSubscription(
                name: name, price: price, cycle: billingCycle, day: day,
                category: category, isOffline: false,
                latitude: nil, longitude: nil, address: nil
            )
        }
    }

    private func saveSubscription(name: String, price: Int, cycle: BillingCycle, day: Int,
                                   category: SubscriptionCategory, isOffline: Bool,
                                   latitude: Double?, longitude: Double?, address: String?) {
        if var existing = subscriptionToEdit {
            existing.serviceName = name
            existing.monthlyPrice = price
            existing.billingCycle = cycle
            existing.billingDay = day
            existing.category = category
            existing.memo = memoField.text ?? ""
            existing.isFreeTrial = freeTrialSwitch.isOn
            existing.freeTrialEndDate = freeTrialSwitch.isOn ? freeTrialDatePicker.date : nil
            existing.isOffline = isOffline
            existing.latitude = latitude
            existing.longitude = longitude
            existing.address = address

            SubscriptionStore.shared.updateSubscription(existing)
        } else {
            let newSub = Subscription(
                serviceName: name,
                monthlyPrice: price,
                billingCycle: cycle,
                billingDay: day,
                category: category,
                isFreeTrial: freeTrialSwitch.isOn,
                freeTrialEndDate: freeTrialSwitch.isOn ? freeTrialDatePicker.date : nil,
                memo: memoField.text ?? "",
                isOffline: isOffline,
                latitude: latitude,
                longitude: longitude,
                address: address
            )
            SubscriptionStore.shared.addSubscription(newSub)
        }

        delegate?.didAddSubscription()
        dismiss(animated: true)
    }

    // MARK: - Alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "입력 확인", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

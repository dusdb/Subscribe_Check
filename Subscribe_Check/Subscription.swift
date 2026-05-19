//
//  Subscription.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/19.
//

import Foundation

// MARK: - 결제 주기
enum BillingCycle: String, Codable, CaseIterable {
    case monthly = "월간"
    case yearly = "연간"
}

// MARK: - 카테고리
enum SubscriptionCategory: String, Codable, CaseIterable {
    case video = "영상"
    case music = "음악"
    case cloud = "클라우드"
    case fitness = "운동"
    case delivery = "배송"
    case education = "학습"
    case other = "기타"

    var iconName: String {
        switch self {
        case .video: return "play.tv.fill"
        case .music: return "music.note"
        case .cloud: return "cloud.fill"
        case .fitness: return "figure.walk"
        case .delivery: return "shippingbox.fill"
        case .education: return "book.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .video: return "#FF6B6B"
        case .music: return "#4ECDC4"
        case .cloud: return "#45B7D1"
        case .fitness: return "#96CEB4"
        case .delivery: return "#FFEAA7"
        case .education: return "#DDA0DD"
        case .other: return "#95A5A6"
        }
    }
}

// MARK: - 구독 상태
enum SubscriptionStatus: String, Codable {
    case active = "구독 중"
    case cancelled = "해지됨"
}

// MARK: - 구독 모델
struct Subscription: Codable {
    let id: String
    var serviceName: String
    var monthlyPrice: Int
    var billingCycle: BillingCycle
    var billingDay: Int
    var category: SubscriptionCategory
    var status: SubscriptionStatus
    var isFreeTrial: Bool
    var freeTrialEndDate: Date?
    var lastUsedDate: Date?
    var createdAt: Date
    var memo: String

    // 오프라인 구독용
    var isOffline: Bool
    var latitude: Double?
    var longitude: Double?
    var address: String?

    // MARK: - 초기화
    init(
        serviceName: String,
        monthlyPrice: Int,
        billingCycle: BillingCycle,
        billingDay: Int,
        category: SubscriptionCategory,
        isFreeTrial: Bool = false,
        freeTrialEndDate: Date? = nil,
        memo: String = "",
        isOffline: Bool = false,
        latitude: Double? = nil,
        longitude: Double? = nil,
        address: String? = nil
    ) {
        self.id = UUID().uuidString
        self.serviceName = serviceName
        self.monthlyPrice = monthlyPrice
        self.billingCycle = billingCycle
        self.billingDay = billingDay
        self.category = category
        self.status = .active
        self.isFreeTrial = isFreeTrial
        self.freeTrialEndDate = freeTrialEndDate
        self.lastUsedDate = Date()
        self.createdAt = Date()
        self.memo = memo
        self.isOffline = isOffline
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }

    // MARK: - 계산 프로퍼티

    var yearlyPrice: Int {
        switch billingCycle {
        case .monthly: return monthlyPrice * 12
        case .yearly: return monthlyPrice
        }
    }

    var normalizedMonthlyPrice: Int {
        switch billingCycle {
        case .monthly: return monthlyPrice
        case .yearly: return monthlyPrice / 12
        }
    }

    var daysUntilNextBilling: Int {
        let calendar = Calendar.current
        let today = Date()
        let currentDay = calendar.component(.day, from: today)
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        var targetMonth = currentMonth
        var targetYear = currentYear

        if currentDay >= billingDay {
            targetMonth += 1
            if targetMonth > 12 {
                targetMonth = 1
                targetYear += 1
            }
        }

        var components = DateComponents()
        components.year = targetYear
        components.month = targetMonth

        let maxDay = calendar.range(
            of: .day, in: .month,
            for: calendar.date(from: DateComponents(year: targetYear, month: targetMonth)) ?? today
        )?.count ?? 28

        components.day = min(billingDay, maxDay)

        guard let nextBillingDate = calendar.date(from: components) else { return 0 }

        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: today),
            to: calendar.startOfDay(for: nextBillingDate)
        ).day ?? 0

        return max(0, days)
    }

    var daysSinceLastUsed: Int {
        guard let lastUsed = lastUsedDate else { return 999 }
        let calendar = Calendar.current
        return calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: lastUsed),
            to: calendar.startOfDay(for: Date())
        ).day ?? 0
    }

    var unusedWarningLevel: Int {
        if daysSinceLastUsed >= 60 { return 2 }
        if daysSinceLastUsed >= 30 { return 1 }
        return 0
    }

    var freeTrialDaysLeft: Int? {
        guard isFreeTrial, let endDate = freeTrialEndDate else { return nil }
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: endDate)
        ).day ?? 0
        return max(0, days)
    }
}

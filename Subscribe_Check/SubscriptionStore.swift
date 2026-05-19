//
//  SubscriptionStore.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/19.
//

import Foundation

class SubscriptionStore {

    // MARK: - 싱글톤
    static let shared = SubscriptionStore()

    private init() {
        loadSubscriptions()
    }

    // MARK: - 데이터
    private(set) var subscriptions: [Subscription] = []

    static let didUpdateNotification = Notification.Name("SubscriptionStoreDidUpdate")

    // MARK: - 파일 경로
    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return directory.appendingPathComponent("subscriptions.json")
    }

    // MARK: - 추가
    func addSubscription(_ subscription: Subscription) {
        subscriptions.append(subscription)
        saveSubscriptions()
        notifyUpdate()
    }

    // MARK: - 수정
    func updateSubscription(_ subscription: Subscription) {
        guard let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) else { return }
        subscriptions[index] = subscription
        saveSubscriptions()
        notifyUpdate()
    }

    // MARK: - 삭제
    func deleteSubscription(id: String) {
        subscriptions.removeAll(where: { $0.id == id })
        saveSubscriptions()
        notifyUpdate()
    }

    // MARK: - 사용 기록
    func markAsUsed(id: String) {
        guard let index = subscriptions.firstIndex(where: { $0.id == id }) else { return }
        subscriptions[index].lastUsedDate = Date()
        saveSubscriptions()
        notifyUpdate()
    }

    // MARK: - 해지
    func cancelSubscription(id: String) {
        guard let index = subscriptions.firstIndex(where: { $0.id == id }) else { return }
        subscriptions[index].status = .cancelled
        saveSubscriptions()
        notifyUpdate()
    }

    // MARK: - 재활성화
    func reactivateSubscription(id: String) {
        guard let index = subscriptions.firstIndex(where: { $0.id == id }) else { return }
        subscriptions[index].status = .active
        saveSubscriptions()
        notifyUpdate()
    }

    // MARK: - 조회 헬퍼

    var activeSubscriptions: [Subscription] {
        return subscriptions.filter { $0.status == .active }
    }

    var totalMonthlyPrice: Int {
        return activeSubscriptions.reduce(0) { $0 + $1.normalizedMonthlyPrice }
    }

    var totalYearlyPrice: Int {
        return activeSubscriptions.reduce(0) { $0 + $1.yearlyPrice }
    }

    var warningSubscriptions: [Subscription] {
        return activeSubscriptions.filter { $0.unusedWarningLevel > 0 }
    }

    func subscriptionsByCategory() -> [SubscriptionCategory: [Subscription]] {
        var result: [SubscriptionCategory: [Subscription]] = [:]
        for sub in activeSubscriptions {
            result[sub.category, default: []].append(sub)
        }
        return result
    }

    var offlineSubscriptions: [Subscription] {
        return activeSubscriptions.filter { $0.isOffline }
    }

    // MARK: - 저장
    private func saveSubscriptions() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(subscriptions)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("구독 데이터 저장 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 불러오기
    private func loadSubscriptions() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            subscriptions = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            subscriptions = try decoder.decode([Subscription].self, from: data)
        } catch {
            print("구독 데이터 불러오기 실패: \(error.localizedDescription)")
            subscriptions = []
        }
    }

    // MARK: - 알림
    private func notifyUpdate() {
        NotificationCenter.default.post(name: SubscriptionStore.didUpdateNotification, object: nil)
    }

    // MARK: - 샘플 데이터 (테스트용)
    func loadSampleData() {
        guard subscriptions.isEmpty else { return }

        let samples = [
            Subscription(serviceName: "넷플릭스", monthlyPrice: 17000, billingCycle: .monthly, billingDay: 15, category: .video),
            Subscription(serviceName: "유튜브 프리미엄", monthlyPrice: 14900, billingCycle: .monthly, billingDay: 1, category: .video),
            Subscription(serviceName: "스포티파이", monthlyPrice: 10900, billingCycle: .monthly, billingDay: 20, category: .music),
            Subscription(serviceName: "iCloud+ 200GB", monthlyPrice: 3900, billingCycle: .monthly, billingDay: 5, category: .cloud),
            Subscription(serviceName: "쿠팡 로켓와우", monthlyPrice: 7890, billingCycle: .monthly, billingDay: 10, category: .delivery),
            Subscription(serviceName: "헬스장", monthlyPrice: 50000, billingCycle: .monthly, billingDay: 1, category: .fitness, isOffline: true, latitude: 37.5665, longitude: 126.9780, address: "서울시 중구")
        ]

        for sample in samples {
            addSubscription(sample)
        }
    }
}

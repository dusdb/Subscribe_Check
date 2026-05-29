//
//  NotificationManager.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/29.
//

import Foundation
import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()
    private init() {}

    // 알림 권한 요청
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("알림 권한 요청 실패: \(error.localizedDescription)")
            }
        }
    }

    // 결제일 D-3 알림 예약
    func schedulePaymentReminders() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let subscriptions = SubscriptionStore.shared.activeSubscriptions

        for sub in subscriptions {
            let daysLeft = sub.daysUntilNextBilling

            // D-3일 때 알림
            if daysLeft > 3 {
                scheduleNotification(
                    id: "payment_\(sub.id)",
                    title: "결제일 알림",
                    body: "\(sub.serviceName) 결제일이 3일 남았습니다",
                    daysFromNow: daysLeft - 3
                )
            }

            // D-Day 알림
            if daysLeft > 0 {
                scheduleNotification(
                    id: "payday_\(sub.id)",
                    title: "오늘 결제일",
                    body: "\(sub.serviceName) 결제일입니다",
                    daysFromNow: daysLeft
                )
            }

            // 무료체험 만료 D-1
            if let trialDays = sub.freeTrialDaysLeft, trialDays > 1 {
                scheduleNotification(
                    id: "trial_\(sub.id)",
                    title: "무료체험 만료 임박",
                    body: "\(sub.serviceName) 무료체험이 내일 종료됩니다. 해지하려면 지금 확인하세요!",
                    daysFromNow: trialDays - 1
                )
            }
        }
    }

    private func scheduleNotification(id: String, title: String, body: String, daysFromNow: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(daysFromNow * 86400),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

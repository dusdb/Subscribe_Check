//
//  GeminiService.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/29.
//

import Foundation

class GeminiService {

    static let shared = GeminiService()
    private init() {}

    
    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
                let dict = NSDictionary(contentsOfFile: path),
                let key = dict["GEMINI_API_KEY"] as? String else {
            return ""
        }
        return key
    }

    func analyzeSubscriptions(completion: @escaping (String?) -> Void) {
        let subscriptions = SubscriptionStore.shared.activeSubscriptions

        guard !subscriptions.isEmpty else {
            completion("등록된 구독이 없습니다. 구독을 추가해주세요.")
            return
        }

        // 구독 데이터를 텍스트로 변환
        var prompt = "다음은 사용자의 구독 서비스 목록입니다. 한국어로 간단하게 2~3줄로 분석해주세요. "
        prompt += "총 지출, 미사용 구독, 절약 팁을 포함해주세요.\n\n"

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        for sub in subscriptions {
            let priceText = formatter.string(from: NSNumber(value: sub.normalizedMonthlyPrice)) ?? "0"
            let unusedDays = sub.daysSinceLastUsed
            prompt += "- \(sub.serviceName): 월 \(priceText)원, "
            prompt += "카테고리: \(sub.category.rawValue), "
            prompt += "미사용 \(unusedDays)일\n"
        }

        let totalText = formatter.string(from: NSNumber(value: SubscriptionStore.shared.totalMonthlyPrice)) ?? "0"
        prompt += "\n총 월간 구독료: \(totalText)원"

        // Gemini API 호출
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=\(apiKey)") else {
            completion("API 연결에 실패했습니다.")
            return
        }

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion("데이터 변환에 실패했습니다.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion("네트워크 오류: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    completion("응답 데이터가 없습니다.")
                    return
                }
                print("API 응답: \(String(data: data, encoding: .utf8) ?? "없음")")
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let content = candidates.first?["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let text = parts.first?["text"] as? String {
                        completion(text)
                    } else {
                        completion("AI 분석 결과를 해석할 수 없습니다.")
                    }
                } catch {
                    completion("응답 처리 오류: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

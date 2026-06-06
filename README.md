# 구독 잡는 날 (Subscribe Check)

> 흩어진 구독을 한 곳에서 관리하고, **무료체험 자동결제가 시작되기 전에 미리 잡아주는** 스마트 구독 관리 앱

새는 돈의 대부분은 "해지하는 걸 깜빡한 무료체험"과 "쓰지도 않는데 매달 빠져나가는 구독"에서 나옵니다. 구독 잡는 날은 이 두 가지를 자동으로 추적해, 돈이 빠져나가기 **전에** 알려줍니다.

---

## 핵심 기능

- **무료체험 만료 알림** — 무료체험 종료 하루 전 로컬 알림으로 미리 경고해 자동결제를 막습니다. (이 앱의 차별점)
- **결제일 알림** — 결제 3일 전 / 당일 알림으로 갑작스러운 결제를 방지합니다.
- **월간/연간 지출 한눈에** — 모든 구독의 월 합계와 연간 환산 금액을 대시보드에서 즉시 확인합니다.
- **미사용 구독 경고** — 일정 기간 사용 기록이 없는 구독을 자동으로 감지해 표시합니다.
- **카테고리별 분석** — 영상·음악·클라우드·운동·배송·학습·기타 카테고리별 지출 분포를 카드로 시각화합니다.
- **오프라인 구독 지도** — 헬스장·독서실 등 오프라인 구독의 위치를 지도 핀으로 관리합니다.
- **AI 한줄 분석** (보조) — 구독 데이터를 분석해 절약 포인트를 한국어로 요약합니다.

---

## 시연

📹 시연 영상: _(여기에 영상 링크 추가)_

---

## 기술 스택

| 분류 | 사용 기술 |
|---|---|
| 언어 | Swift 5 |
| UI | UIKit + Storyboard, Auto Layout, StackView |
| 화면 구조 | TabBarController (3탭) + NavigationController |
| 리스트 | TableView (구독 목록), CollectionView (카테고리 카드) |
| 지도 | MapKit |
| 데이터 전달 | Delegate 패턴, 화면 전환 |
| 로컬 저장 | 파일 기반 JSON 저장 (FileManager + Codable) |
| 알림 | UserNotifications (로컬 알림) |
| AI (보조) | Google Gemini API |

---

## 화면 구조

```
TabBarController
├── Tab 1. 대시보드 (TableView)        → 구독 상세 (Push)
├── Tab 2. 카테고리 분석 (CollectionView)
└── Tab 3. 오프라인 지도 (MapKit, NavigationController) → 구독 상세 (Push)

구독 추가 / 수정 화면 (Modal) — 대시보드·상세에서 진입
```

총 5개 화면: 대시보드 · 카테고리 분석 · 오프라인 지도 · 구독 추가/수정 · 구독 상세

---

## 핵심 구현 포인트

**로컬 저장 (앱을 꺼도 데이터 유지)**
`SubscriptionStore`가 구독 데이터를 JSON 파일로 저장하고 불러옵니다. `Codable` + `FileManager`를 사용하며, 모든 입출력은 `do-catch`로 안전하게 처리됩니다.

**로컬 알림**
`NotificationManager`가 결제일(D-3, 당일)과 무료체험 만료(D-1) 시점에 로컬 알림을 예약합니다. 구독이 추가·수정·삭제될 때마다 예약을 다시 계산합니다.

**안전한 데이터 처리**
강제 언래핑 없이 `guard let` / `if let`만 사용했고, 삭제·해지 등 되돌릴 수 없는 동작에는 확인 Alert을 적용했습니다. 빈 화면에는 안내 메시지를, 잘못된 입력에는 오류 안내를 표시합니다.

---

## 실행 방법

**요구 사항**
- Xcode 15 이상
- iOS 시뮬레이터 (실기기 불필요)

**설치**
1. 저장소를 클론합니다.
   ```bash
   git clone https://github.com/dusdb/Subscribe_Check.git
   ```
2. `Subscribe_Check.xcodeproj`를 Xcode로 엽니다.
3. **AI 분석 기능을 쓰려면** 아래 "API 키 설정"을 따라 `Secrets.plist`를 만듭니다. (이 단계를 건너뛰어도 AI를 제외한 모든 기능은 정상 동작합니다.)
4. 시뮬레이터를 선택하고 실행(▶︎)합니다.

**API 키 설정 (AI 분석 기능용)**
1. [Google AI Studio](https://aistudio.google.com/app/apikey)에서 Gemini API 키를 발급받습니다.
2. 프로젝트에 `Secrets.plist` 파일을 새로 만듭니다.
3. 아래 키-값을 추가합니다.

   | Key | Type | Value |
   |---|---|---|
   | `GEMINI_API_KEY` | String | 발급받은 키 |

> ⚠️ `Secrets.plist`는 개인 API 키를 담고 있으므로 저장소에 올리지 않습니다. (`.gitignore`에 등록되어 있습니다.)

---

## 폴더 구조

```
Subscribe_Check/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Main.storyboard
├── Subscription.swift                  # 데이터 모델
├── SubscriptionStore.swift             # 로컬 저장소 (싱글톤)
├── NotificationManager.swift           # 로컬 알림 관리
├── GeminiService.swift                 # AI 분석 (보조)
├── DashboardViewController.swift       # Tab 1
├── CategoryViewController.swift        # Tab 2
├── CategoryCardCell.swift
├── CategoryFilterListViewController.swift
├── MapViewController.swift             # Tab 3
├── AddSubscriptionViewController.swift  # 구독 추가/수정
├── SubscriptionDetailViewController.swift
├── SubscriptionCell.swift
├── PlaceSearchViewController.swift
└── AppColors.swift                     # 색상 상수
```

---

## 기대 효과

- **낭비 방지** — 무료체험 자동결제와 미사용 구독으로 새는 돈을 미리 발견합니다.
- **지출 인식** — 월·연 총 구독료를 한눈에 파악해 소비를 돌아보게 합니다.
- **사각지대 제거** — 앱 구독뿐 아니라 헬스장 등 오프라인 구독까지 함께 관리합니다.

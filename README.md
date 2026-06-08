# 구독 잡는 날 (Subscribe Check)

> 흩어진 구독을 한 곳에서 관리하고, **무료체험 자동결제가 시작되기 전에 미리 잡아주는** 스마트 구독 관리 앱

새는 돈의 대부분은 "해지하는 걸 깜빡한 무료체험"과 "쓰지도 않는데 매달 빠져나가는 구독"에서 나옵니다. 구독 잡는 날은 이 두 가지를 자동으로 추적해, 돈이 빠져나가기 **전에** 알려줍니다.

---

## 1. 프로젝트 수행 목적

### 1.1 프로젝트 정의

로컬 알림과 미사용 감지를 이용한 스마트 구독 관리 어플리케이션

### 1.2 프로젝트 배경

OTT, 클라우드, 배달, 피트니스 등 구독 서비스가 늘어나면서 자신이 매달 얼마를 구독료로 쓰는지 파악하지 못하는 경우가 많아졌다. 특히 무료체험 후 자동으로 결제가 시작되는 구조는 사용자가 미처 해지하지 못해 원치 않는 결제로 이어지는 경우가 빈번하다. 또한 헬스장처럼 앱이 아닌 오프라인 구독도 관리가 어려워 실질적인 지출 파악이 되지 않는다.

이러한 문제를 해소하기 위해 구독 지출을 한 곳에서 파악하고, 무료체험 만료 전 자동으로 알림을 보내 자동결제를 막아주는 방법을 제공하고자 한다.

### 1.3 프로젝트 목표

- **무료체험 만료 알림** — 무료체험 종료 하루 전 로컬 알림을 발송해 자동결제를 미리 차단
- **결제일 알림** — 결제 3일 전 및 당일 알림으로 갑작스러운 지출 방지
- **지출 현황 파악** — 모든 구독의 월간·연간 합계를 대시보드에서 즉시 확인
- **미사용 구독 감지** — 일정 기간 사용 기록이 없는 구독을 자동으로 감지해 경고 표시
- **카테고리별 분석** — 영상·음악·클라우드 등 카테고리별 지출 분포 시각화
- **오프라인 구독 지도** — 헬스장·독서실 등 오프라인 구독 위치를 지도에 표시

---

## 2. 프로젝트 개요

### 2.1 프로젝트 설명

구독을 추가하면 서비스명·금액·카테고리·결제일·결제 주기를 저장하고, FileManager와 Codable을 이용해 앱을 꺼도 데이터가 유지된다.

무료체험 만료일을 설정하면 만료 하루 전에 UserNotifications로 로컬 알림을 예약하며, 결제일 3일 전과 당일에도 알림이 발송된다. 구독이 추가·수정·삭제될 때마다 알림 예약이 자동으로 재계산된다.

대시보드에서는 D-day순·금액순·이름순 정렬이 가능하고, 30일 이상 사용 기록이 없는 구독은 경고 점으로 표시된다. 카테고리 분석 탭에서는 CollectionView로 카테고리별 지출 카드를 보여주며, 지도 탭에서는 MapKit으로 오프라인 구독 위치를 핀으로 표시하고 상세 화면으로 이동할 수 있다.

보조 기능으로 Google Gemini API를 연동해 전체 구독 데이터를 분석하고 절약 포인트를 한 줄로 요약해 준다.

모든 Optional 처리는 `guard let` / `if let`으로만 처리하고, 삭제·해지 등 되돌릴 수 없는 동작에는 확인 Alert을 적용해 안전성을 확보했다.

### 2.2 프로젝트 구조

```
TabBarController
├── Tab 1. 대시보드 (TableView)              → 구독 상세 화면 (Push)
├── Tab 2. 카테고리 분석 (CollectionView)
└── Tab 3. 오프라인 지도 (MapKit)            → 구독 상세 화면 (Push)

구독 추가 / 수정 화면 (Modal Present)        ← 대시보드·상세에서 진입
```

```
Subscribe_Check/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Main.storyboard
├── Subscription.swift                       # 데이터 모델
├── SubscriptionStore.swift                  # 로컬 저장소 (싱글톤)
├── NotificationManager.swift                # 로컬 알림 관리
├── GeminiService.swift                      # AI 분석 (보조)
├── DashboardViewController.swift            # Tab 1
├── CategoryViewController.swift             # Tab 2
├── CategoryCardCell.swift
├── CategoryFilterListViewController.swift
├── MapViewController.swift                  # Tab 3
├── AddSubscriptionViewController.swift      # 구독 추가/수정
├── SubscriptionDetailViewController.swift   # 구독 상세
├── SubscriptionCell.swift
├── PlaceSearchViewController.swift
└── AppColors.swift                          # 색상 상수
```

### 2.3 결과물

| 대시보드 | 카테고리 분석 | 오프라인 지도 |
|:---:|:---:|:---:|
| <img width="200" src="https://github.com/user-attachments/assets/a8b4b2d2-3278-4905-b8a3-45ba5e89c544" /> | <img width="200" src="https://github.com/user-attachments/assets/829e45b8-318d-4e66-8032-f51961738ec3" /> | <img width="200" src="https://github.com/user-attachments/assets/e2d09f82-96ba-4482-9170-c0a7d346e83b" /> |
 
| 구독 추가 | 구독 상세 | 무료체험 만료 알림 |
|:---:|:---:|:---:|
| <img width="200"  src="https://github.com/user-attachments/assets/dd475fca-4962-4b4e-8ac8-e0a34eb7376e" /> |<img width="200"  src="https://github.com/user-attachments/assets/8f0254c0-bb68-492b-8564-000f09780b59" /> | <img width="200"  src="https://github.com/user-attachments/assets/08f70e86-1153-418c-a434-e5d98b124273" /> |


### 2.4 기대 효과

- 무료체험 자동결제와 미사용 구독으로 새는 돈을 미리 발견해 불필요한 지출을 줄일 수 있다.
- 월·연간 총 구독료를 한눈에 파악해 자신의 구독 소비 패턴을 돌아볼 수 있다.
- 앱 구독뿐 아니라 헬스장 등 오프라인 구독까지 한 곳에서 관리해 사각지대를 없앤다.

### 2.5 관련 기술

| 구분 | 설명 |
|---|---|
| UserNotifications | Apple이 제공하는 로컬 알림 프레임워크로, 특정 시간에 알림을 예약하고 앱이 실행 중이 아닐 때도 사용자에게 알림을 발송한다. 이 앱에서는 무료체험 만료 D-1, 결제일 D-3·당일 알림 예약에 사용했다. |
| Codable + FileManager | Swift의 Codable 프로토콜로 구독 데이터를 JSON으로 인코딩·디코딩하고, FileManager로 앱의 Documents 디렉토리에 파일로 저장한다. 앱을 완전히 종료해도 데이터가 유지된다. |
| MapKit | Apple의 지도 프레임워크로, 위치 좌표를 기반으로 지도에 핀(Annotation)을 표시하고 Callout으로 정보를 보여준다. 오프라인 구독의 위치를 시각화하는 데 사용했다. |
| Google Gemini API | Google의 생성형 AI API로, 구독 데이터를 프롬프트로 전달하면 절약 포인트를 한국어로 분석해 반환한다. 보조 기능으로 사용했으며 API 키는 Secrets.plist로 분리해 관리한다. |

### 2.6 개발 도구

| 구분 | 설명 |
|---|---|
| Xcode 12.5 | Apple의 공식 iOS 개발 통합 개발 환경(IDE)으로, Swift 코드 작성·빌드·시뮬레이터 실행을 담당한다. |
| Swift 5 | Apple이 개발한 정적 타입 언어로, 안전한 메모리 관리와 Optional 타입을 통해 런타임 오류를 줄인다. |
| UIKit + Storyboard | iOS UI를 구성하는 프레임워크로, Storyboard에서 화면 구조를 설계하고 Auto Layout·StackView로 다양한 화면 크기에 대응한다. TabBarController·NavigationController·TableView·CollectionView를 활용했다. |
| VMware (macOS) | Windows 환경에서 macOS를 가상 머신으로 실행해 Xcode와 iOS 시뮬레이터를 구동했다. 실기기 없이 시뮬레이터만으로 개발·테스트했다. |

### 2.7 발표 영상

📹 [YouTube 시연 영상](https://youtu.be/Tiso-uFLuxQ)

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
3. **AI 분석 기능을 쓰려면** 아래 "API 키 설정"을 따라 `Secrets.plist`를 만듭니다. (건너뛰어도 AI를 제외한 모든 기능은 정상 동작합니다.)
4. 시뮬레이터를 선택하고 실행(▶︎)합니다.

**API 키 설정 (AI 분석 기능용)**

1. [Google AI Studio](https://aistudio.google.com/app/apikey)에서 Gemini API 키를 발급받습니다.
2. 프로젝트 내에 `Secrets.plist` 파일을 새로 만듭니다.
3. 아래 키-값을 추가합니다.

| Key | Type | Value |
|---|---|---|
| `GEMINI_API_KEY` | String | 발급받은 API 키 |

> ⚠️ `Secrets.plist`는 개인 API 키를 포함하므로 저장소에 올리지 않습니다. (`.gitignore`에 등록되어 있습니다.)

//
//  MapViewController.swift
//  Subscribe_Check
//
//  Created by yeonwoo on 2026/05/18.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    private let mapView = MKMapView()
    private let emptyLabel = UILabel()
    private let store = SubscriptionStore.shared

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 2)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "오프라인 지도"
        
        view.backgroundColor = AppColors.background
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        setupMapView()
        setupEmptyState()
        observeStore()
        reloadPins()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPins()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func observeStore() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadPins),
            name: SubscriptionStore.didUpdateNotification, object: nil
        )
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // 서울 기본 중심
        let seoulCenter = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        let region = MKCoordinateRegion(center: seoulCenter, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: false)
    }

    private func setupEmptyState() {
        emptyLabel.text = "등록된 오프라인 구독이 없습니다\n구독 추가 시 '오프라인 구독'을 켜고\n주소를 입력하면 지도에 표시됩니다"
        emptyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        emptyLabel.textColor = AppColors.textSecondary
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.backgroundColor = AppColors.background.withAlphaComponent(0.9)
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func reloadPins() {
        mapView.removeAnnotations(mapView.annotations)

        let offlineSubs = store.offlineSubscriptions

        let isEmpty = offlineSubs.isEmpty
        emptyLabel.isHidden = !isEmpty

        for sub in offlineSubs {
            guard let lat = sub.latitude, let lon = sub.longitude else { continue }

            let annotation = SubscriptionAnnotation(subscription: sub)
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.title = sub.serviceName

            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let priceText = formatter.string(from: NSNumber(value: sub.normalizedMonthlyPrice)) ?? "0"
            annotation.subtitle = "월 \(priceText)원"

            mapView.addAnnotation(annotation)
        }

        if !offlineSubs.isEmpty {
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
}

// MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let subAnnotation = annotation as? SubscriptionAnnotation else { return nil }

        let identifier = "SubscriptionPin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if view == nil {
            view = MKMarkerAnnotationView(annotation: subAnnotation, reuseIdentifier: identifier)
            view?.canShowCallout = true

            let detailButton = UIButton(type: .detailDisclosure)
            view?.rightCalloutAccessoryView = detailButton
        } else {
            view?.annotation = subAnnotation
        }

        view?.markerTintColor = AppColors.primary
        view?.glyphImage = UIImage(systemName: subAnnotation.subscription.category.iconName)

        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let subAnnotation = view.annotation as? SubscriptionAnnotation else { return }
        let detailVC = SubscriptionDetailViewController(subscription: subAnnotation.subscription)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// 커스텀 Annotation
class SubscriptionAnnotation: MKPointAnnotation {
    let subscription: Subscription

    init(subscription: Subscription) {
        self.subscription = subscription
        super.init()
    }
}

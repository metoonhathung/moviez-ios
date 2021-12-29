//
//  MapViewVC.swift
//  Moviez
//
//  Created by Trần Ngô Nhật Hưng on 12/11/22.
//

import UIKit
import MapKit
import CoreLocation

class MapViewVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var constGoBtn: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "primary")
        
        localized()
        NotificationCenter.default.addObserver(forName: Notifications.languageChanged, object: nil, queue: nil) { _ in
            self.localized()
        }
        
        searchField?.text = "movie theaters"
        
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.distanceFilter = 10
        locationManager?.delegate = self
        
        mapView?.delegate = self
        mapView?.mapType = .standard
        mapView?.isZoomEnabled = true
        mapView?.isScrollEnabled = true
        mapView?.removeAnnotations(mapView.annotations)

        // Do any additional setup after loading the view.
    }
    
    func localized() {
        navigationItem.title = "str_mapview".localized()
        constGoBtn?.setTitle("str_go".localized(), for: .normal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func onGoBtn(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
            case .denied:
                showAlert()
            case .restricted:
                showAlert()
            default:
                locationManager?.requestWhenInUseAuthorization()
                locationManager?.startUpdatingLocation()
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "str_warning".localized(), message: "str_no_location_msg".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "str_go".localized(), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func annotate(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView?.addAnnotation(annotation)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - CoreLocation
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: " + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            mapView?.removeAnnotations(mapView.annotations)
            let deltas = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: deltas)
            mapView?.setRegion(region, animated: true)
            annotate(coordinate: location.coordinate, title: "str_here_msg".localized())
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = searchField?.text ?? ""
            searchRequest.region = region
            let search = MKLocalSearch(request: searchRequest)
            search.start { response, error in
                guard let response = response else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }

                for item in response.mapItems {
                    self.annotate(coordinate: item.placemark.coordinate, title: item.name ?? "")
                }
            }
            locationManager?.stopUpdatingLocation()
        }
    }

}

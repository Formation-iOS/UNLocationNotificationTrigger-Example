//
//  ViewController.swift
//  MapsTutorial
//
//  Created by Claire Reynaud on 23/03/2018.
//  Copyright © 2018 Claire Reynaud EIRL. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let userNotificationManager = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
     
        mapView.mapType = .satellite
        mapView.delegate = self
        for mapPoint in FunMapPoint.allMapPoints {
            mapView.addAnnotation(FunAnnotation(mapPoint: mapPoint))
        }
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func createLocationNotifications() {
        userNotificationManager.delegate = self
        userNotificationManager.requestAuthorization(options: [.alert, .sound]) { (authorized, error) in
            if let error = error {
                print("L'utilisateur n'a pas autorisé: \(error)")
            } else {
                self.userNotificationManager.removeAllDeliveredNotifications()
                self.userNotificationManager.removeAllPendingNotificationRequests()
                for mapPoint in FunMapPoint.allMapPoints {
                    self.configureNofitication(mapPoint: mapPoint)
                }
            }
        }
    }
    
    func configureNofitication(mapPoint: FunMapPoint) {
        let content = UNMutableNotificationContent()
        content.title = mapPoint.title
        content.sound = UNNotificationSound.default()
        let region = CLCircularRegion(center: mapPoint.coordinate, radius: 500000, identifier: mapPoint.title)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        let request = UNNotificationRequest(identifier: mapPoint.title, content: content, trigger: trigger)
        self.userNotificationManager.add(request) { (error) in
            if let error = error {
                print("Erreur add request: \(error)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            createLocationNotifications()
        } else {
            print("User did not authorize always for geoloc")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? FunAnnotation else {
            return nil
        }
        
        let identifier = "FunAnnotationView"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let newAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            newAnnotationView.canShowCallout = true
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(UIImage(named: "Zoom"), for: .normal)
            newAnnotationView.rightCalloutAccessoryView = button
            return newAnnotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let funAnnotation = view.annotation as? FunAnnotation {
            let region = MKCoordinateRegionMakeWithDistance(funAnnotation.coordinate, 200, 200)
            mapView.setRegion(region, animated: true)
        }
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}


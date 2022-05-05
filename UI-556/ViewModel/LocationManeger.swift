//
//  LocationManeger.swift
//  UI-556
//
//  Created by nyannyan0328 on 2022/05/05.
//

import SwiftUI
import MapKit
import Combine

class LocationManeger:NSObject, ObservableObject,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @Published var mapkit : MKMapView = .init()
    @Published var manager : CLLocationManager = .init()
    
    @Published var searchText : String = ""
    
    @Published var mapType : MKMapType = .standard
    
    
    @Published var region : MKCoordinateRegion!
    
    @Published var fetchPlaces : [CLPlacemark]?
    
    @Published var userLocation : CLLocation?
    
    @Published var pickedLocation : CLLocation?
    @Published var pickedPlaceMark : CLPlacemark?
    
    var caseble : AnyCancellable?
    
    func changeMapType(){
        
   
       
        
        
        if mapType == .standard{

            mapType = .hybrid
            mapkit.mapType = mapType
        }
        else{

            mapType = .standard
            mapkit.mapType = mapType
        }
    }
    
    func forcusLocation(){
        
        
        guard let _ = region else{return}
        
        mapkit.setRegion(region, animated: true)
        mapkit.setVisibleMapRect(mapkit.visibleMapRect, animated: true)
        
        
    }
    
    
    
    override init() {
        
        super.init()
        mapkit.delegate = self
        manager.delegate = self
        
        manager.requestWhenInUseAuthorization()
        
        caseble = $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: {[self] value in
                
                if value != ""{
                    
                    fetchPlaces(value: value)
                    
                }
                else{
                    
                    fetchPlaces = nil
                    
                }
                
            })
    }
    
    func fetchPlaces(value : String){
        
        
        Task{
            do{
                
                
                let request = MKLocalSearch.Request()
                
                request.naturalLanguageQuery = value.lowercased()
                
                let responce = try await MKLocalSearch(request: request).start()
                
                await MainActor.run(body: {
                    
                    self.fetchPlaces = responce.mapItems.compactMap { item -> CLPlacemark? in
                        
                        return item.placemark
                    }
                })
                
            }
            catch{}
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else{return}
        
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapkit.setRegion(self.region, animated: true)
        self.mapkit.setVisibleMapRect(self.mapkit.visibleMapRect, animated: true)
    
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus{
            
            
        case .authorizedAlways : manager.requestLocation()
        case.authorizedWhenInUse : manager.requestLocation()
        case .denied : handleError()
        case .notDetermined : manager.requestWhenInUseAuthorization()
        default : ()
        }
        
        
        
    }
    func handleError(){}
   
    
    func addDraggingPin(cordinate : CLLocationCoordinate2D){
        
        let annotaiton = MKPointAnnotation()
        annotaiton.coordinate = cordinate
        
        
        mapkit.addAnnotation(annotaiton)
    }
    
      
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "FINAL")
        
        marker.isDraggable = true
        marker.canShowCallout = true
        
        return marker
        
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        
        guard let newLocation = view.annotation?.coordinate else{return}
        
        self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        
    }
}

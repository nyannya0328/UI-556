//
//  Home.swift
//  UI-556
//
//  Created by nyannyan0328 on 2022/05/05.
//

import SwiftUI
import MapKit

struct Home: View {
    @StateObject var model : LocationManeger = .init()
    var body: some View {
        ZStack{
            
            mapHelper()
                .environmentObject(model)
                .ignoresSafeArea()
            
            
            VStack{
                
                HStack{
                    
                    Image(systemName: "magnifyingglass")
                    
                    TextField("Serach Location", text: $model.searchText)
                    
                }
              
                .padding(.vertical,10)
                .padding(.horizontal)
                .background{
                    
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                }
                .padding()
                
                
                if let places = model.fetchPlaces,!places.isEmpty{
                    
                    List{
                        
                        ForEach(places,id:\.self){place in
                            
                            
                            Button {
                                
                                if let cordinate = place.location?.coordinate{
                                    
                                    model.pickedLocation = .init(latitude: cordinate.latitude, longitude: cordinate.longitude)
                                    
                                    model.mapkit.region = .init(center: cordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                    model.addDraggingPin(cordinate: cordinate)
                                    
                                }
                                model.searchText = ""
                                
                                
                            } label: {
                                
                                HStack(spacing:13){
                                    
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.gray)
                                    
                                    VStack(alignment: .leading, spacing: 15) {
                                        
                                        Text(place.name ?? "")
                                       .font(.caption.weight(.semibold))
                                        
                                        Text(place.locality ?? "")
                                            .font(.callout.weight(.ultraLight))
                                    }
                                }
                            }

                            
                            
                        }
                        
                    }
                    .listStyle(.plain)
                    
                }
                
                
                Spacer()
                
                
                VStack{
                    
                    Button {
                        
                        model.forcusLocation()
                        
                    } label: {
                        
                        Image(systemName: "location.fill")
                            .font(.title.weight(.semibold))
                            .foregroundColor(.blue)
                            .padding(5)
                            .background(.black,in: Capsule())
                         
                    }

                    Button {
                        
                        model.changeMapType()
                        
                    } label: {
                        
                        Image(systemName: model.mapType == .standard ?  "network" : "map")
                            .font(.title.weight(.semibold))
                            .foregroundColor(.blue)
                            .padding(5)
                            .background(.black,in: Capsule())
                         
                    }
                    
                    
                }
                .padding(.trailing,10)
                .lTreading()
                
                
                
               
                   
            
            }
            .maxTop()
            
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct mapHelper : UIViewRepresentable{
    
    @EnvironmentObject var model : LocationManeger
    func makeUIView(context: Context) -> MKMapView {
        
        return model.mapkit
        
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
}

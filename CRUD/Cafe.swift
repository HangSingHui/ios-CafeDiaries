//
//  Cafe.swift
//  CRUD
//
//  Created by Sing Hui Hang on 10/10/25.
//

import Foundation
import CoreLocation

enum Specialty: String, CaseIterable {
    case drinks
    case food
    case music
    case ambience
}

class Cafe {
    var name: String
    var dateVisited: Date
    var rating: Int
    var specialty: Specialty
    var notes: String
    var favourite: Bool
    var location: String
    var coordinate: CLLocationCoordinate2D?
    
    init(name: String,
         dateVisited: Date,
         rating: Int,
         specialty: Specialty,
         notes: String,
         favourite: Bool,
         location: String,
         coordinate: CLLocationCoordinate2D? = nil) {
        self.name = name
        self.dateVisited = dateVisited
        self.rating = rating
        self.specialty = specialty
        self.notes = notes
        self.favourite = favourite
        self.location = location
        self.coordinate = coordinate
    }
}

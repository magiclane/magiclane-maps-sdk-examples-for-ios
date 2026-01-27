// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import Foundation

class PositionData: NSObject, Encodable, Decodable {
    
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var course: Double
    var speed: Double
    var speedAccuracy: Double
    var horizontalAccuracy: Double
    var verticalAccuracy: Double
    var courseAccuracy: Double
    
    public init(latitude: Double, longitude: Double, altitude: Double, course: Double, speed: Double, speedAccuracy: Double, horizontalAccuracy: Double, verticalAccuracy: Double, courseAccuracy: Double) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.course = course
        self.speed = speed
        self.speedAccuracy = speedAccuracy
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.courseAccuracy = courseAccuracy
    }
}

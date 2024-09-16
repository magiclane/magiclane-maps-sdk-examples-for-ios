// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import UIKit
import GEMKit
import SwiftUI

class ViewController: UIViewController, MapViewControllerDelegate  {
    
    var mapViewController: MapViewController?
    
    var label = UILabel.init()
    var imageView = UIImageView()
    var currentWeatherButton = UIButton(type: .system)
    var hourlyWeatherButton = UIButton(type: .system)
    var dailyWeatherButton = UIButton(type: .system)
    
    var currentLandmark: LandmarkObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let navigationController = self.navigationController {
            
            let appearance = navigationController.navigationBar.standardAppearance
            
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.title = "Weather Forecast"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.createMapView()

        self.mapViewController!.startRender()
        
        self.addLabelText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Paris
        let location = CoordinatesObject.coordinates(withLatitude: 48.840827, longitude: 2.381899)
        
        self.mapViewController!.center(onCoordinates: location, zoomLevel: 70, animationDuration: 1200)
    }
    
    // MARK: - Map View
    
    func createMapView() {

        self.mapViewController = MapViewController.init()
        self.mapViewController!.delegate = self
        self.mapViewController!.view.backgroundColor = UIColor.systemBackground

        self.addChild(self.mapViewController!)
        self.view.addSubview(self.mapViewController!.view)
        self.mapViewController!.didMove(toParent: self)

        self.mapViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        let constraintTop = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.view, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: 0)

        let constraintLeft = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 0)

        let constraintBottom = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -0)

        let constraintRight = NSLayoutConstraint( item: self.mapViewController!.view!, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -0)

        NSLayoutConstraint.activate([constraintTop, constraintLeft, constraintBottom, constraintRight])
    }
        
    // MARK: - Label
    
    func addLabelText() {
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isHidden = true
        self.imageView.layer.shadowColor = UIColor.lightGray.cgColor
        self.imageView.layer.shadowOpacity = 0.8
        
        self.label.font = UIFont.boldSystemFont(ofSize: 14)
        self.label.numberOfLines = 0
        self.label.backgroundColor = UIColor.systemBackground
        self.label.isHidden = true
        
        self.label.layer.shadowColor = UIColor.lightGray.cgColor
        self.label.layer.shadowOpacity = 0.8

        // Example buttons for each type of possible forecast requests: current, hourly and daily
        
        self.currentWeatherButton.setTitle("Current Weather", for: .normal)
        self.currentWeatherButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.currentWeatherButton.titleLabel?.numberOfLines = 2
        self.currentWeatherButton.titleLabel?.textAlignment = .center
        self.currentWeatherButton.addTarget(self, action: #selector(currentWeatherButtonPressed), for: .touchUpInside)
        self.currentWeatherButton.backgroundColor = .systemBackground
        self.currentWeatherButton.isHidden = true
        self.currentWeatherButton.layer.cornerRadius = 8
        self.currentWeatherButton.layer.shadowColor = UIColor.lightGray.cgColor
        self.currentWeatherButton.layer.shadowOpacity = 0.8
        
        self.hourlyWeatherButton.setTitle("Hourly Weather", for: .normal)
        self.hourlyWeatherButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.hourlyWeatherButton.titleLabel?.numberOfLines = 2
        self.hourlyWeatherButton.titleLabel?.textAlignment = .center
        self.hourlyWeatherButton.addTarget(self, action: #selector(hourlyWeatherButtonPressed), for: .touchUpInside)
        self.hourlyWeatherButton.backgroundColor = .systemBackground
        self.hourlyWeatherButton.isHidden = true
        self.hourlyWeatherButton.layer.cornerRadius = 8
        self.hourlyWeatherButton.layer.shadowColor = UIColor.lightGray.cgColor
        self.hourlyWeatherButton.layer.shadowOpacity = 0.8
        
        self.dailyWeatherButton.setTitle("Daily Weather", for: .normal)
        self.dailyWeatherButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.dailyWeatherButton.titleLabel?.numberOfLines = 2
        self.dailyWeatherButton.titleLabel?.textAlignment = .center
        self.dailyWeatherButton.addTarget(self, action: #selector(dailyWeatherButtonPressed), for: .touchUpInside)
        self.dailyWeatherButton.backgroundColor = .systemBackground
        self.dailyWeatherButton.isHidden = true
        self.dailyWeatherButton.layer.cornerRadius = 8
        self.dailyWeatherButton.layer.shadowColor = UIColor.lightGray.cgColor
        self.dailyWeatherButton.layer.shadowOpacity = 0.8
        
        self.view.addSubview(self.label)
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.currentWeatherButton)
        self.view.addSubview(self.hourlyWeatherButton)
        self.view.addSubview(self.dailyWeatherButton)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        var constraintLeft = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.leading,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading,
                                                 multiplier: 1.0, constant: 10.0)
        
        let constraintBottom = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1.0, constant: -10.0)
        
        let constraintRight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                  multiplier: 1.0, constant: -10.0)

        var constraintHeight = NSLayoutConstraint( item: self.label, attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: 70.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintBottom, constraintRight, constraintHeight])
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        constraintLeft = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.leading,
                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                             toItem: self.label, attribute: NSLayoutConstraint.Attribute.leading,
                                             multiplier: 1.0, constant: 0.0)
        
        let constraintTop = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.top,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self.label, attribute: NSLayoutConstraint.Attribute.top,
                                                multiplier: 1.0, constant: -20.0)
        
        let constraintWidth = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1.0, constant: 40.0)
        
        constraintHeight = NSLayoutConstraint( item: self.imageView, attribute: NSLayoutConstraint.Attribute.height,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                               multiplier: 1.0, constant: 40.0)
        
        NSLayoutConstraint.activate([constraintLeft, constraintTop, constraintWidth, constraintHeight])
        
        self.currentWeatherButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.currentWeatherButton.bottomAnchor.constraint(equalTo: self.label.topAnchor, constant: -10),
            self.currentWeatherButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.currentWeatherButton.heightAnchor.constraint(equalToConstant: 60),
            self.currentWeatherButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        self.hourlyWeatherButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.hourlyWeatherButton.bottomAnchor.constraint(equalTo: self.currentWeatherButton.topAnchor, constant: -10),
            self.hourlyWeatherButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.hourlyWeatherButton.heightAnchor.constraint(equalToConstant: 60),
            self.hourlyWeatherButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        self.dailyWeatherButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.dailyWeatherButton.bottomAnchor.constraint(equalTo: self.hourlyWeatherButton.topAnchor, constant: -10),
            self.dailyWeatherButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.dailyWeatherButton.heightAnchor.constraint(equalToConstant: 60),
            self.dailyWeatherButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // Asynchronous current weather forecast request
    
    @objc func currentWeatherButtonPressed() {
        
        guard let coordinates = self.currentLandmark?.getCoordinates() else { return }
        
        self.currentWeatherButton.isEnabled = false
        self.hourlyWeatherButton.isEnabled = false
        self.dailyWeatherButton.isEnabled = false
        
        _ = WeatherContext.shared().requestCurrentForecast([coordinates]) { [weak self] error, results in
            
            guard let strongSelf = self else { return }
            
            strongSelf.currentWeatherButton.isEnabled = true
            strongSelf.hourlyWeatherButton.isEnabled = true
            strongSelf.dailyWeatherButton.isEnabled = true
            
            if error == .kNoError {
                
                if let forecast = results.first {
                    
                    strongSelf.createCurrentWeatherView(forecast)
                }
            }
        }
    }
    
    func createCurrentWeatherView(_ forecast: WeatherContextForecast) {
        
        let model = WeatherCurrentModel()
        
        let scale = UIScreen.main.scale
        
        model.description = forecast.conditions.details
        
        let size = CGSize(width: 100 * scale, height: 100 * scale)
        
        if let image = forecast.conditions.imageObject?.renderImage(with: size) {
            
            //let id = forecast.conditions.imageObject?.getUid()
            
            model.image = image
        }
        
        for parameter in forecast.conditions.parameters {
            
            if parameter.type == "Temperature" {
                
                model.temperature = String(Int(parameter.value)) + parameter.unit
            }
            
            if parameter.type == "FeelsLike" {
                
                model.feelsLikeTemp = parameter.name + " " + String(format: "%1.f", roundl(parameter.value)) + parameter.unit
            }
            
            if parameter.type == "AirQuality" {
                
                let item = WeatherCurrentParameterItem(name: parameter.name, value: String(format: "%1.f", roundl(parameter.value)))
                
                model.parameters.append(item)
            }
            
            if parameter.type == "DewPoint" {
                
                let item = WeatherCurrentParameterItem(name: parameter.name, value: String(format: "%1.f", roundl(parameter.value)) + parameter.unit)
                
                model.parameters.append(item)
            }
            
            if parameter.type == "Humidity" {
                
                let item = WeatherCurrentParameterItem(name: parameter.name, value: String(format: "%1.f", roundl(parameter.value)) + parameter.unit)
                
                model.parameters.append(item)
            }
            
            if parameter.type == "Pressure" {
                
                let item = WeatherCurrentParameterItem(name: parameter.name, value: String(format: "%1.f", roundl(parameter.value)) + parameter.unit)
                
                model.parameters.append(item)
            }
            
            if parameter.type == "Sunrise" {
                
                let item = WeatherCurrentParameterItem(name: parameter.name, value: getLocalShortTimeFor(time: parameter.value))
                
                model.parameters.append(item)
            }
            
            if parameter.type == "Sunset" {
                
                let item = WeatherCurrentParameterItem(name: parameter.name, value: getLocalShortTimeFor(time: parameter.value))
                
                model.parameters.append(item)
            }
            
            if parameter.type == "UV" {
                
                let item = WeatherCurrentParameterItem(name: parameter.name, value: String(format: "%1.f", roundl(parameter.value)))
                
                model.parameters.append(item)
            }
            
            if parameter.type == "Visibility" {
                
                let item = WeatherCurrentParameterItem(name: parameter.name, value: String(format: "%.2f", parameter.value) + " " + parameter.unit)
                
                model.parameters.append(item)
            }
            
            if parameter.type == "WindDirection" {
                
                let item = WeatherCurrentParameterItem(name: parameter.name, value: String(format: "%1.f", roundl(parameter.value)) + parameter.unit)
                
                model.parameters.append(item)
            }
            
            if parameter.type == "WindSpeed" {
                
                let item = WeatherCurrentParameterItem(name: parameter.name, value: String(format: "%1.f", roundl(parameter.value)) + " " + parameter.unit)
                
                model.parameters.append(item)
            }
        }
        
        if let time = forecast.conditions.stamp {
            
            model.localTime = self.getLocalShortTimeFor(timeObject: time)
        }
        
        if let timeObject = forecast.updateTimestamp {
            
            model.updatedAtTime = getLocalShortTimeFor(timeObject: timeObject)
        }
        
        let view = WeatherCurrentView(model: model)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Current Weather"
        
        if let navigationController = self.navigationController {
            
            navigationController.pushViewController(hostingController, animated: true)
        }
    }
    
    // Asynchronous hourly weather forecast request
    
    @objc func hourlyWeatherButtonPressed() {
        
        guard let coordinates = self.currentLandmark?.getCoordinates() else { return }
        
        self.currentWeatherButton.isEnabled = false
        self.hourlyWeatherButton.isEnabled = false
        self.dailyWeatherButton.isEnabled = false
        
        // Hourly weather request with parameters: the array of coordinates for the forecast and the number of hours
        
        _ = WeatherContext.shared().requestHourlyForecast([coordinates], hours: 24) { [weak self] error, results in
            
            guard let strongSelf = self else { return }
            
            strongSelf.currentWeatherButton.isEnabled = true
            strongSelf.hourlyWeatherButton.isEnabled = true
            strongSelf.dailyWeatherButton.isEnabled = true
            
            if error == .kNoError {
                
                // For the daily forecast every result item from the completed request is an array of forecasts, one for every hour requested starting from the current time.
                
                if let forecast = results.first {
                    
                    strongSelf.createHourlyWeatherView(forecast)
                }
            }
        }
    }
    
    func createHourlyWeatherView(_ forecast: [WeatherContextForecast]) {
        
        guard forecast.isEmpty == false else { return }
        
        let model = WeatherHourlyModel()
        
        let scale = UIScreen.main.scale
        
        let size = CGSize(width: 100 * scale, height: 100 * scale)
        
        for hourForecast in forecast {
            
            var item = WeatherHourlyItem()
            
            if let image = hourForecast.conditions.imageObject?.renderImage(with: size) {
                
                item.image = image
            }
            
            for parameter in hourForecast.conditions.parameters {
                
                if parameter.type == "Temperature" {
                    
                    item.temperature = String(Int(parameter.value)) + parameter.unit
                }
            }
            
            if let time = hourForecast.conditions.stamp {
                
                item.time = getLocalShortTimeFor(timeObject: time)
            }
            
            model.items.append(item)
        }
        
        let view = WeatherHourlyView(model: model)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Hourly Weather"
        
        if let navigationController = self.navigationController {
            
            navigationController.pushViewController(hostingController, animated: true)
        }
    }
    
    // Asynchronous daily weather forecast request
    
    @objc func dailyWeatherButtonPressed() {
        
        guard let coordinates = self.currentLandmark?.getCoordinates() else { return }
        
        self.currentWeatherButton.isEnabled = false
        self.hourlyWeatherButton.isEnabled = false
        self.dailyWeatherButton.isEnabled = false
        
        // Daily weather request with parameters: the array of coordinates for the forecast and the number of days
        
        _ = WeatherContext.shared().requestDailyForecast([coordinates], days: 10) { [weak self] error, results in
            
            // On completion returns error code and the array of results for every coordinate

            guard let strongSelf = self else { return }
            
            strongSelf.currentWeatherButton.isEnabled = true
            strongSelf.hourlyWeatherButton.isEnabled = true
            strongSelf.dailyWeatherButton.isEnabled = true
            
            if error == .kNoError {
                
                // For the daily forecast every result item from the completed request is an array of forecasts, one for every day requested.
                
                if let forecast = results.first {
                    
                    strongSelf.createDailyWeatherVew(forecast)
                }
            }
        }
    }
    
    func createDailyWeatherVew(_ forecast: [WeatherContextForecast]) {
        
        guard forecast.isEmpty == false else { return }
        
        let model = WeatherDailyModel()
        
        let scale = UIScreen.main.scale
        
        let size = CGSize(width: 100 * scale, height: 100 * scale)
        
        for dayForecast in forecast {
            
            var item = WeatherDailyItem()
            
            if let image = dayForecast.conditions.imageObject?.renderImage(with: size) {
                
                //let id = forecast.conditions.imageObject?.getUid()
                
                item.image = image
            }
            
            for parameter in dayForecast.conditions.parameters {
                
                if parameter.type == "TemperatureHigh" {
                    
                    item.temperatureHigh = String(Int(parameter.value)) + parameter.unit
                }
                
                if parameter.type == "TemperatureLow" {
                    
                    item.temperatureLow = String(Int(parameter.value)) + parameter.unit
                }
            }
            
            if let time = dayForecast.conditions.stamp {
                
                item.date = getLocalDateStringFor(timeObject: time)
            }
            
            model.items.append(item)
        }
        
        let view = WeatherDailyView(model: model)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Daily Weather"
        
        if let navigationController = self.navigationController {
            
            navigationController.pushViewController(hostingController, animated: true)
        }
    }
    
    // MARK: - MapViewControllerDelegate
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onTouch point: CGPoint) {
        
        self.currentLandmark = landmark
        
        let text = "  " + landmark.getLandmarkName() + "\n" + "  " + landmark.getLandmarkDescription()
        
        self.label.text = text
        self.label.isHidden = false
        
        let scale = UIScreen.main.scale
        self.imageView.image = landmark.getLandmarkImage(CGSize.init(width: 40*scale, height: 40*scale))
        self.imageView.isHidden = false
        
        self.currentWeatherButton.isHidden = false
        self.hourlyWeatherButton.isHidden = false
        self.dailyWeatherButton.isHidden = false
        
        self.highlight(landmark: landmark)
    }
    
    func mapViewController(_ mapViewController: MapViewController, didSelectLandmark landmark: LandmarkObject, onLongTouch point: CGPoint) {
        
        self.currentLandmark = landmark
        
        let text = "  " + landmark.getLandmarkName() + "\n" + "  " + landmark.getLandmarkDescription()
        
        self.label.text = text
        self.label.isHidden = false
        
        let scale = UIScreen.main.scale
        self.imageView.image = landmark.getLandmarkImage(CGSize.init(width: 40*scale, height: 40*scale))
        self.imageView.isHidden = false
        
        self.currentWeatherButton.isHidden = false
        self.hourlyWeatherButton.isHidden = false
        self.dailyWeatherButton.isHidden = false
        
        self.highlight(landmark: landmark)
    }
    
    func highlight(landmark: LandmarkObject) {
        
        let settings = HighlightRenderSettings.init()
        settings.showPin = true
        settings.imageSize = 7
        
        if landmark.isContourGeograficAreaEmpty() == false {
            
            settings.options = Int32( HighlightOption.showLandmark.rawValue | HighlightOption.overlap.rawValue | HighlightOption.showContour.rawValue )
            settings.contourInnerColor = UIColor.white
            settings.contourOuterColor = UIColor.systemBlue
        }
        
        self.mapViewController!.presentHighlights([landmark], settings: settings, highlightId: 0)
        
        self.mapViewController!.center(onCoordinates: landmark.getCoordinates(), zoomLevel: -1, animationDuration: 900)
    }
    
    // MARK: - Utils
    
    func getTimeZoneFor(coordinates: CoordinatesObject) -> TimeZone {
        
        let time = TimeObject.init()
        time.setUniversalTime()
        
        let result = TimezoneContext.sharedInstance().getOfflineTimezoneInfo(coordinates, time: time)
        
        let status = result.getStatus()
        
        if status == .success {
            
            let timeZoneId = result.getTimezoneId()
            
            if timeZoneId.count > 0, let value = TimeZone(identifier: timeZoneId) {
                
                return value
            }
        }
        
        return TimeZone.current
    }
    
    func getLocalShortTimeFor(timeObject: TimeObject) -> String {
        
        guard let coordinates = self.currentLandmark?.getCoordinates() else { return "" }
        
        let timeZone = self.getTimeZoneFor(coordinates: coordinates)
        
        let timeSeconds: Double = Double(timeObject.asInt()) / 1000
        
        return self.getFormattedShortTimeSince1970(time: timeSeconds, timeZone: timeZone)
    }
    
    func getLocalShortTimeFor(time: Double) -> String {
        
        guard let coordinates = self.currentLandmark?.getCoordinates() else { return "" }
        
        let timeZone = self.getTimeZoneFor(coordinates: coordinates)
        
        return self.getFormattedShortTimeSince1970(time: time, timeZone: timeZone)
    }
    
    func getFormattedShortTimeSince1970(time: Double, timeZone: TimeZone) -> String {
        
        let date = Date.init(timeIntervalSince1970: time)
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = timeZone
        
        let text = dateFormatter.string(from: date)
        
        return text
    }
    
    func getLocalDateStringFor(timeObject: TimeObject) -> String {
        
        guard let coordinates = self.currentLandmark?.getCoordinates() else { return "" }
        
        let timeZone = self.getTimeZoneFor(coordinates: coordinates)
        
        let timeSeconds: Double = Double(timeObject.asInt()) / 1000
        
        let date = Date.init(timeIntervalSince1970: timeSeconds)
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = timeZone
        
        let text = dateFormatter.string(from: date)
        
        return text
    }
}

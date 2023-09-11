// Copyright (C) 2019-2023, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import Foundation
import Charts
import GEMKit
import SwiftUI

let METERS_TO_YARDS: Double = 1.0936
let YARDS_TO_METERS: Double = 0.9144

let METERS_TO_FEET:  Double = 3.2808
let FEET_TO_METERS: Double  = 0.3048

let KM_TO_MILES: Double = 0.6214
let MILES_TO_KM: Double = 1.6093

let MPS_TO_KMH: Double = 3.6
let MPS_TO_MPH: Double = 2.237

let chartHighlightColor = UIColor(red: 239/255, green: 38/255, blue: 81/255, alpha: 1.0)

let chartUnhighlightColor = UIColor.lightGray

let defaultLandmarksHighlightId: Int32 = 1001

class ElevationChartViewController: UIViewController, ChartViewDelegate, AxisValueFormatter {
    
    var route: RouteObject?
    
    var mapViewController: MapViewController?
    
    var lineChartView: LineChartView?
    
    var elevationButtonsViewController: UIHostingController<RouteElevationButtonsView>?
    var climbSectionsViewController: UIHostingController<ClimbSectionsView>?
    
    var climbTitleLabel: UILabel = UILabel.init()
    
    var balloonMarker: BalloonMarker?
    
    var didSelectValue: (() -> Void) = {}
    
    let sampleSize = 500
    
    public init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NSLog("ElevationChartViewController: deinit")
        
        elevationButtonsViewController = nil
        climbSectionsViewController = nil
    }
    
    func clearDelegates() {
        
        if self.lineChartView != nil {
            
            self.lineChartView!.delegate = nil
            self.lineChartView!.xAxis.valueFormatter = nil
            self.lineChartView!.leftAxis.valueFormatter = nil
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemGroupedBackground
        
        self.climbTitleLabel.text = "Climb Details"
        
        self.prepareChart()
        
        if let route = self.route {
            
            self.refreshWithRoute(route)
        }
        
        self.prepareLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    // MARK: - Preparing
    
    func prepareChart() {
        
        self.lineChartView = LineChartView.init()
        
        guard let lineChartView = self.lineChartView else { return }
        
        lineChartView.backgroundColor = .clear
        lineChartView.xAxis.labelPosition = .bottom
        
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.gridBackgroundColor = .clear
        lineChartView.borderLineWidth = 5.0
        
        lineChartView.extraRightOffset = 30.0
        lineChartView.extraTopOffset = 30.0
        
        lineChartView.drawMarkers = true

        self.balloonMarker = BalloonMarker(color: .darkGray, font: .systemFont(ofSize: 13, weight: .semibold), textColor: .white, insets: .zero)

        let arrowSize = CGSize.init(width: 15, height: 5)
        let minimumSize = CGSize.init(width: 45, height: 28)
        let insets = UIEdgeInsets.init(top: 3, left: 6, bottom: 0, right: 6)

        let type = GEMSdk.shared().getUnitSystem()

        self.balloonMarker?.arrowSize = arrowSize
        self.balloonMarker?.insets = insets
        self.balloonMarker?.labelSufix = type == .imperialUS ? "ft" : "m"
        self.balloonMarker?.integerValue = true
        self.balloonMarker?.minimumSize = minimumSize

        self.balloonMarker?.chartView = lineChartView
        lineChartView.marker = self.balloonMarker

        lineChartView.pinchZoomEnabled = false
        lineChartView.dragYEnabled = false
        lineChartView.dragEnabled = false
        lineChartView.dragXEnabled = true
        lineChartView.scaleXEnabled = true
        lineChartView.scaleYEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.legend.enabled = false

        lineChartView.xAxis.valueFormatter = self
        lineChartView.leftAxis.valueFormatter = self

        lineChartView.delegate = self
    }
    
    func prepareLayout() {
        
        guard let lineChartView = lineChartView else { return }
        
        guard let elevationButtonsViewController = self.elevationButtonsViewController else { return }
        
        guard let climbSectionsViewController = self.climbSectionsViewController else { return }
        
        self.climbTitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        self.climbTitleLabel.textColor = .secondaryLabel
        
        self.view.addSubview(lineChartView)
        self.view.addSubview(self.climbTitleLabel)
        
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            lineChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            lineChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            lineChartView.heightAnchor.constraint(equalToConstant: 190)
        ])
        
        elevationButtonsViewController.view.backgroundColor = .clear
        self.view.addSubview(elevationButtonsViewController.view)
        
        elevationButtonsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            elevationButtonsViewController.view.topAnchor.constraint(equalTo: lineChartView.bottomAnchor, constant: 10),
            elevationButtonsViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            elevationButtonsViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            elevationButtonsViewController.view.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        self.climbTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            climbTitleLabel.topAnchor.constraint(equalTo: elevationButtonsViewController.view.bottomAnchor, constant: 15),
            climbTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            climbTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            climbTitleLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        climbSectionsViewController.view.backgroundColor = .clear
        climbSectionsViewController.view.layer.shadowColor = UIColor.lightGray.cgColor
        climbSectionsViewController.view.layer.shadowOpacity = 0.5
        climbSectionsViewController.view.layer.shadowOffset = CGSize(width: 0.3, height: 0.8)
        climbSectionsViewController.view.layer.shadowRadius = 1.4
        self.view.addSubview(climbSectionsViewController.view)
        
        climbSectionsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            climbSectionsViewController.view.topAnchor.constraint(equalTo: climbTitleLabel.bottomAnchor, constant: 10),
            climbSectionsViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            climbSectionsViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            climbSectionsViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            climbSectionsViewController.view.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    func refreshWithRoute(_ route: RouteObject) {
        
        guard let lineChartView = self.lineChartView else { return }
        
        self.route = route
        
        self.refreshChartData()
        self.refreshChartButtons()
        self.refreshChartClimbData()
        
        lineChartView.highlightValue(nil)
        lineChartView.fitScreen()
        
        lineChartView.animate(yAxisDuration: 1.0, easingOption: .easeOutBack)
    }
    
    func refreshChartData(minX: Double = 0.0, maxX: Double = 0.0) {
        
        guard let lineChartView = self.lineChartView else { return }
        
        guard let route = self.route else { return }
        
        guard let profile = route.getTerrainProfile() else { return }
        
        let minElevationLocal = self.localElevation(Double(profile.getMinElevation()))
        let maxElevationLocal = self.localElevation(Double(profile.getMaxElevation()))
        
        lineChartView.leftAxis.axisMinimum = Double((Int(minElevationLocal / 100) - 1) * 100)
        lineChartView.leftAxis.axisMaximum = Double((Int(maxElevationLocal / 100) + 2) * 100)
        lineChartView.leftAxis.granularity = 1.0
        lineChartView.leftAxis.setLabelCount(3, force: true)
        
        let timeDist = route.getTimeDistance()
        
        if let timeDist = timeDist {
            
            let minXValue = minX > 0 ? minX : 0
            let maxXValue = maxX > 0 ? maxX : self.localDistance(Double(timeDist.getTotalDistance()))
            
            let xAxis = lineChartView.xAxis
            
            xAxis.axisMinimum = 0
            xAxis.axisMaximum = self.localDistance(Double(timeDist.getTotalDistance()))
            xAxis.granularity = 0.1
            xAxis.setLabelCount(4, force: true)
            
            let distBegin = Int32(self.localDistanceToMeters(minXValue))
            let distEnd = Int32(self.localDistanceToMeters(maxXValue))
            
            let samples = profile.getElevationSamples(Int32(self.sampleSize), distBegin: distBegin, distEnd: distEnd)
            
            var chartDataEntries: [ChartDataEntry] = []
            
            var x = minXValue
            
            var y = 0.0
            
            let step: Double = Double((maxXValue - minXValue) / (Double(self.sampleSize - 1)))
            
            if self.sampleSize <= samples.count {
                
                for index in 0..<self.sampleSize {
                    
                    y = samples[index].doubleValue
                    
                    if index > 0 {
                        
                        x += step
                    }
                    
                    x = min(x, maxXValue)
                    
                    if index == self.sampleSize - 1 {
                        
                        x = maxXValue
                    }
                    
                    let entryX = x
                    let entryY = self.localElevation(y)
                    
                    chartDataEntries.append(ChartDataEntry(x: entryX, y: entryY))
                }
            }
            
            var count = 0
            
            let data = lineChartView.data
            
            if data != nil { count = data!.dataSetCount }
            
            if count > 0 {
                
                if let data = data {
                    
                    let set1: LineChartDataSet? = data.dataSets[0] as? LineChartDataSet
                    
                    if let set1 = set1 { set1.replaceEntries(chartDataEntries) }
                }
                
                lineChartView.notifyDataSetChanged()
                lineChartView.data?.notifyDataChanged()
                
            } else {
                
                let set1 = LineChartDataSet(entries: chartDataEntries, label: "DataSet 1")
                
                set1.axisDependency = .left
                set1.setColor(.systemBlue)
                set1.drawCirclesEnabled = false
                set1.lineWidth = 4
                set1.lineCapType = .round
                set1.circleRadius = 10
                set1.fillAlpha = 0.35
                set1.drawFilledEnabled = true
                
                set1.fillColor = .systemBlue
                set1.highlightColor = .clear
                set1.drawCircleHoleEnabled = false
                set1.fillFormatter = DefaultFillFormatter { _,_  -> CGFloat in
                    return CGFloat(lineChartView.leftAxis.axisMinimum)
                }
                
                let data: LineChartData = [set1]
                data.setDrawValues(false)
                
                lineChartView.data = data
            }
        }
    }
    
    func refreshOnMapZoomed() {
        
        let routeInterval = self.getRouteInterval()
        
        guard routeInterval.count == 2 else { return }
        
        self.updateChartInterval(minX: routeInterval[0], maxX: routeInterval[1])
    }
    
    func refreshChartButtons() {
        
        guard let route = self.route else { return }
        
        guard let profile = route.getTerrainProfile() else { return }
        
        let imgDatabase = ImageDatabaseObject.init()
        
        let pinIconId: UInt32 = 6034
        
        let scale = UIScreen.main.scale
        
        let imgSize = CGSize(width: 32 * scale, height: 32 * scale)
        
        var items: [RouteElevationButtonItem] = []
        
        if let timeDist = route.getTimeDistance() {
            
            if let imgObject = imgDatabase.getImageById(pinIconId) {
                
                if let img = imgObject.renderImage(with: imgSize) {
                    
                    let startElevation = profile.getElevation(0)
                    
                    items.append(RouteElevationButtonItem(type: .startElevation , image: img, value: self.localElevation(Double(startElevation))))
                    
                    let endElevation = profile.getElevation(Int32(timeDist.getTotalDistance()))
                    
                    items.append(RouteElevationButtonItem(type: .endElevation , image: img, value: self.localElevation(Double(endElevation))))
                }
            }
        }
        
        if let imgMax = UIImage(systemName: "arrow.down.to.line") {
            
            items.append(RouteElevationButtonItem(type:.minElevation , image: imgMax, value: self.localElevation(Double(profile.getMinElevation()))))
        }
        
        if let imgMin = UIImage(systemName: "arrow.up.to.line") {
            
            items.append(RouteElevationButtonItem(type:.maxElevation , image: imgMin, value: self.localElevation( Double(profile.getMaxElevation()))))
        }
        
        let model = RouteElevationButtonsModel(items: items)
        
        if self.elevationButtonsViewController == nil {
            
            let elevationButtonsView = RouteElevationButtonsView(model: model) { [weak self] item in
                
                guard let strongSelf = self else { return }
                
                strongSelf.onElevationButtonPressed(item)
            }
            
            self.elevationButtonsViewController = UIHostingController(rootView: elevationButtonsView)
            
        } else {
            
            self.elevationButtonsViewController!.rootView.model.items = model.items
            self.elevationButtonsViewController!.rootView.model.refresh()
        }
    }
    
    func refreshChartClimbData() {
        
        guard let route = self.route else { return }
        
        guard let profile = route.getTerrainProfile() else { return }
        
        let climbSections = profile.getClimbSections()
        
        var items: [ClimbSectionItem] = []
        
        for section in climbSections {
            
            let startDistance = Double(section.startDistanceM)
            let endDistance = Double(section.endDistanceM)
            let startElevation = Double(profile.getElevation(section.startDistanceM))
            let endElevation = Double(profile.getElevation(section.endDistanceM))
            
            let grade = section.grade
            let slope = section.slope
            let startDistanceString = String(format: "%.2f %@", self.localDistance(startDistance), self.distanceUnit())
            let endDistanceString = String(format: "%.2f %@", self.localDistance(endDistance), self.distanceUnit())
            let startElevationString = String(format: "%.2f %@",self.localElevation(startElevation), self.elevationUnit())
            let endElevationString = String(format: "%.2f %@",self.localElevation(endElevation), self.elevationUnit())
            let length = String(format: "%.2f %@", self.localDistance(abs(endDistance - startDistance)), self.distanceUnit())
            
            let item = ClimbSectionItem(climbSectionObject: section, grade: grade, slope: slope, startDistance: startDistanceString, endDistance: endDistanceString, startElevation: startElevationString, endElevation: endElevationString, length: length)
            
            items.append(item)
        }
        
        let model = ClimbSectionsModel(items: items)
        
        if self.climbSectionsViewController == nil {
            
            let climbSectionsView = ClimbSectionsView(model: model) { [weak self] item in
                
                guard let strongSelf = self else { return }
                
                strongSelf.updateIntervalWithClimbSection(item: item)
            }
            
            self.climbSectionsViewController = UIHostingController(rootView: climbSectionsView)
            
        } else {
            
            self.climbSectionsViewController!.rootView.model.items = model.items
            self.climbSectionsViewController!.rootView.model.refresh()
        }
        
        self.updateChartDataWithClimbSets()
    }
    
    func updateChartDataWithClimbSets() {
        
        guard let lineChartView = self.lineChartView else { return }
        
        guard let count = lineChartView.data?.dataSetCount, count > 0 else { return }
        
        guard let mainSet = lineChartView.data?.dataSets[0] as? LineChartDataSet else { return }
        
        guard let climbSectionsViewController = self.climbSectionsViewController else { return }
        
        let model = climbSectionsViewController.rootView.model
        
        var climbSets: [LineChartDataSet] = []
        
        for climbItem in model.items {
            
            let minX = self.localDistance(Double(climbItem.climbSectionObject.startDistanceM))
            let maxX = self.localDistance(Double(climbItem.climbSectionObject.endDistanceM))
            
            var values: [ChartDataEntry] = []
            
            for entry in mainSet.entries {
                
                if entry.x >= minX && entry.x <= maxX {
                    
                    values.append(entry)
                }
            }
            
            let color: UIColor = climbItem.getColor()
            
            let climbSet = LineChartDataSet(entries: values)
            
            climbSet.axisDependency = .left
            climbSet.drawIconsEnabled = false
            climbSet.drawValuesEnabled = false
            //climbSet.valueFormatter = self
            climbSet.valueTextColor = .label
            
            climbSet.setColor(color)
            climbSet.lineWidth = 5.0
            climbSet.lineCapType = .round
            climbSet.valueFont = .systemFont(ofSize: 9)
            
            climbSet.highlightEnabled = false
            climbSet.drawCirclesEnabled = false
            climbSet.drawCircleHoleEnabled = false
            
            climbSet.drawFilledEnabled = true
            climbSet.fillAlpha = 0.8
            climbSet.fillColor = .systemBlue
            climbSet.fill = mainSet.fill
            
            climbSets.append(climbSet)
        }
            
        if count > 1 {
            
            lineChartView.data?.dataSets.removeSubrange(1..<count)
        }
        
        lineChartView.data?.dataSets.append(contentsOf: climbSets)
        
        lineChartView.notifyDataSetChanged()
        lineChartView.data?.notifyDataChanged()
    }
    
    func updateIntervalWithClimbSection(item: ClimbSectionItem) {
    
        let minVisibleX = self.localDistance(Double(item.climbSectionObject.startDistanceM))
        let maxVisibleX = self.localDistance(Double(item.climbSectionObject.endDistanceM))
        
        self.updateChartInterval(minX: minVisibleX, maxX: maxVisibleX)
        
        self.zoomMapBasedOnChart()
    }
    
    func updateChartInterval(minX: Double, maxX: Double) {
        
        guard let lineChartView = self.lineChartView else { return }
        
        let factor1 = lineChartView.highestVisibleX - lineChartView.lowestVisibleX
        let factor2 = maxX - minX
        
        guard factor1 > 0 && factor2 > 0 else { return }
        
        let scaleX = factor1 / factor2
        
        lineChartView.zoomToCenter(scaleX: scaleX, scaleY: 1.0)
        
        self.updateChartData(minX: minX, maxX: maxX)
        
        lineChartView.moveViewToX(minX)
    }
    
    func zoomMapBasedOnChart() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        guard let route = self.route else { return }
        
        guard let lineChartView = self.lineChartView else { return }
        
        let minX = lineChartView.lowestVisibleX
        let maxX = lineChartView.highestVisibleX
        
        let startDist = Int32(self.localDistanceToMeters(minX))
        let endDist = Int32(self.localDistanceToMeters(maxX))
        
        if startDist < endDist {
            
            mapViewController.center(onRoute: route, startDist: startDist, endDist: endDist, rectangle: self.getRouteRectangle(), animationDuration: 0.0)
        }
    }
    
    func updateHighlight(minX: Double, maxX: Double) {
        
        guard let lineChartView = self.lineChartView else { return }
        
        if let highlight = lineChartView.highlighted.first {
            
            if highlight.x <= minX {
                
                lineChartView.highlightValue(x: minX, dataSetIndex: 0)
                
            } else if highlight.x >= maxX {
                
                lineChartView.highlightValue(x: maxX, dataSetIndex: 0)
            }
        }
    }
    
    func updateChartData(minX: Double? = nil, maxX: Double? = nil) {
        
        guard let lineChartView = self.lineChartView else { return }
        
        let newMinX = minX != nil ? minX! : lineChartView.lowestVisibleX
        let newMaxX = maxX != nil ? maxX! : lineChartView.highestVisibleX
        
        self.refreshChartData(minX: newMinX, maxX: newMaxX)
        self.updateChartDataWithClimbSets()
        
        self.updateHighlight(minX: newMinX, maxX: newMaxX)
    }
    
    func resetChartData() {
        
        guard let lineChartView = self.lineChartView else { return }
        
        lineChartView.highlightValue(nil)
        
        guard lineChartView.xAxis.axisMinimum < lineChartView.lowestVisibleX else { return }
        
        guard lineChartView.xAxis.axisMaximum > lineChartView.highestVisibleX else { return }
        
        self.refreshChartData()
        self.updateChartDataWithClimbSets()
        
        lineChartView.fitScreen()
        
        self.zoomMapBasedOnChart()
    }
    
    // MARK: - ChartViewDelegate
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
        self.updateChartData()
        self.zoomMapBasedOnChart()
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
        self.updateChartData()
        self.zoomMapBasedOnChart()
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        
        
        guard let mapViewController = self.mapViewController else { return }
        
        guard let route = self.route else { return }
        
        if let coordinates = route.getCoordinateOnRoute(Int32(self.localDistanceToMeters(entry.x))) {
            
            let landmark = LandmarkObject()
            landmark.setCoordinates(coordinates)
            
            let highlightSettings = HighlightRenderSettings()
            
            highlightSettings.showPin = true
            highlightSettings.options = Int32(HighlightOptionsShowLandmark | HighlightOptionsNoFading | HighlightOptionsOverlap)
            
            mapViewController.presentHighlights([landmark], settings: highlightSettings, highlightId: defaultLandmarksHighlightId)
            
            let routeInterval = self.getRouteInterval()
            
            if routeInterval.count == 2 {
                
                if entry.x < routeInterval[0] || entry.x > routeInterval[1] {
                    
                    self.zoomMapBasedOnChart()
                }
                
            } else {
                
                self.zoomMapBasedOnChart()
            }
        }
        
        self.didSelectValue()
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
        self.mapViewController!.removeHighlight(defaultLandmarksHighlightId)
    }
    
    func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String {
        
        var lastEntry = false
        
        if let entries = axis?.entries, entries.count > 0 {
            
            if let last = entries.last {
                
                if last == value {
                    
                    lastEntry = true
                }
            }
        }
        
        let valueFormatter = NumberFormatter()
        valueFormatter.minimumFractionDigits = 0
        valueFormatter.maximumFractionDigits = 0
        
        var unit = String.init(format: " %@", self.elevationUnit())
        
        if let axis = axis, axis.isKind(of: XAxis.classForCoder()) {
            
            valueFormatter.maximumFractionDigits = 1
            unit = String.init(format: " %@", self.distanceUnit())
        }
        
        if lastEntry {
            
            valueFormatter.negativeSuffix = unit
            valueFormatter.positiveSuffix = unit
        }
        
        if let string = valueFormatter.string(from: NSNumber.init(floatLiteral: value)) {
            
            return string
        }
        
        return String(value)
    }
    
    // MARK: - Utils
    
    func areaEdge(margin: CGFloat) -> UIEdgeInsets {
        
        guard let mapViewController = self.mapViewController else { return .zero }
        
        let scale = UIScreen.main.scale
        
        let insets = UIEdgeInsets.init(top: (mapViewController.view.safeAreaInsets.top + margin) * scale,
                                       left: margin * scale,
                                       bottom: (mapViewController.view.safeAreaInsets.bottom + bottomViewHeight) * scale,
                                       right: margin * scale)
        
        return insets
    }
    
    func onElevationButtonPressed(_ item: RouteElevationButtonItem) {
        
        guard let lineChartView = self.lineChartView else { return }
        guard let route = self.route else { return }
        guard let profile = route.getTerrainProfile() else { return }
        
        self.resetChartData()
        
        if let timeDist = route.getTimeDistance() {
            
            switch item.type {
                
            case .startElevation:
                
                let elevation = profile.getElevation(0)
                lineChartView.highlightValue(x: 0, y: self.localElevation(Double(elevation)), dataSetIndex: 0)
                
            case .endElevation:
                
                let elevation = profile.getElevation(Int32(timeDist.getTotalDistance()))
                
                lineChartView.highlightValue(x: self.localDistance(Double(timeDist.getTotalDistance())), y: self.localElevation(Double(elevation)), dataSetIndex: 0)
                
            case .minElevation:
                
                let elevation = self.localElevation(Double(profile.getMinElevation()))
                
                if let entry = self.searchClosestEntry(elevation) {
                    lineChartView.highlightValue(x: entry.x, y: entry.y, dataSetIndex: 0)
                }
                
            case .maxElevation:
                
                let elevation = self.localElevation(Double(profile.getMaxElevation()))
                
                if let entry = self.searchClosestEntry(elevation) {
                    lineChartView.highlightValue(x: entry.x, y: entry.y, dataSetIndex: 0)
                }
            }
        }
    }
    
    func searchClosestEntry(_ y: Double) -> ChartDataEntry? {
        
        guard let lineChartView = self.lineChartView else { return nil }
        
        var foundDataEntry: ChartDataEntry? = nil
        
        if let count = lineChartView.data?.dataSetCount, count > 0 {
            
            var offsetValue = Double.infinity
            
            if let set: LineChartDataSet = lineChartView.data?.dataSets[0] as? LineChartDataSet {
                
                for entry in set.entries {
                    
                    if abs(entry.y - y) < offsetValue {
                        
                        foundDataEntry = entry
                        offsetValue = abs(entry.y - y)
                        
                    }  else if entry.y == y {
                        
                        foundDataEntry = entry
                        break
                    }
                }
            }
        }
        
        return foundDataEntry
    }
    
    func localDistance(_ distance: Double) -> Double {
        
        guard let timeDistance = route?.getTimeDistance() else { return distance / 1000.0 }
        
        let totalDistance = Double(timeDistance.getTotalDistance())
        
        let type = GEMSdk.shared().getUnitSystem()
        
        if type == .imperialUK {
            
            if totalDistance > 1000.0 * MILES_TO_KM {
             
                return (distance / 1000.0) * KM_TO_MILES
                
            } else {
                
                return distance * METERS_TO_YARDS
            }
            
            
        } else if type == .imperialUS {
            
            if totalDistance > 1000.0 * MILES_TO_KM {
             
                return (distance / 1000.0) * KM_TO_MILES
                
            } else {
                
                return distance * METERS_TO_FEET
            }
            
        } else {
            
            if totalDistance > 1000.0 {
             
                return distance / 1000.0
                
            } else {
                
                return distance
            }
        }
    }
    
    func localDistanceToMeters(_ distance: Double) -> Double {
        
        guard let timeDistance = route?.getTimeDistance() else { return distance / 1000.0 }
        
        let totalDistance = Double(timeDistance.getTotalDistance())
        
        let type = GEMSdk.shared().getUnitSystem()
        
        if type == .imperialUK {
            
            if totalDistance > 1000.0 * MILES_TO_KM {
             
                return (distance * 1000.0) / KM_TO_MILES
                
            } else {
                
                return distance / METERS_TO_YARDS
            }
            
            
        } else if type == .imperialUS {
            
            if totalDistance > 1000.0 * MILES_TO_KM {
             
                return (distance * 1000.0) / KM_TO_MILES
                
            } else {
                
                return distance / METERS_TO_FEET
            }
            
        } else {
            
            if totalDistance > 1000.0 {
             
                return distance * 1000.0
                
            } else {
                
                return distance
            }
        }
    }
    
    func localElevation(_ elevation: Double) -> Double {
        
        let type = GEMSdk.shared().getUnitSystem()
        
        if type == .imperialUK || type == .metric {
            
            return elevation
            
        } else if type == .imperialUS {
            
            return elevation * METERS_TO_FEET
        }
        
        return elevation
    }
    
    func elevationUnit() -> String {
        
        let type = GEMSdk.shared().getUnitSystem()
        
        var unit = ""
        
        if type == .imperialUK || type == .metric {
            
            unit = "m"
            
        } else if type == .imperialUS {
            
            unit = "ft"
        }
        
        return unit
    }
    
    func distanceUnit() -> String {
        
        guard let timeDistance = route?.getTimeDistance() else { return "" }
        
        let totalDistance = Double(timeDistance.getTotalDistance())
        
        var unit = ""
        
        let type = GEMSdk.shared().getUnitSystem()
        
        if type == .imperialUK {
            
            if totalDistance > 1000.0 * MILES_TO_KM {
             
                unit = "mi"
                
            } else {
                
                unit = "yd"
            }
            
            
        } else if type == .imperialUS {
            
            if totalDistance > 1000.0 * MILES_TO_KM {
             
                unit = "mi"
                
            } else {
                
                unit = "ft"
            }
            
        } else {
            
            if totalDistance > 1000.0 {
             
                unit = "km"
                
            } else {
                
                unit = "m"
            }
        }
        
        return unit
    }
    
    func getRouteRectangle() -> CGRect {
        
        guard let mapViewController = self.mapViewController else { return CGRect() }
        
        let scale = UIScreen.main.scale
        
        let insets = self.areaEdge(margin: 70)
        
        let width = mapViewController.view.frame.size.width * scale - insets.left - insets.right
        let height = mapViewController.view.frame.size.height * scale - insets.top - insets.bottom
        
        return CGRect(x: insets.left, y: insets.top, width: width, height: height)
    }
    
    func getRouteInterval() -> [Double] {
        
        return []
        
        /* next sdk release
         *
        guard let route = self.route else { return [] }
        
        guard let mapViewController = self.mapViewController else { return [] }
        
        let pair = mapViewController.getVisibleRouteInterval(route, rect: self.getRouteRectangle())
        
        guard pair.count == 2 else { return [] }
        
        let startDist = pair[0].intValue
        let endDist = pair[1].intValue
        
        let minX = self.localDistance(Double(startDist))
        let maxX = self.localDistance(Double(endDist))
        
        return [minX, maxX]*/
    }
    
    func clean() {
        
        self.lineChartView!.delegate = nil
        self.lineChartView!.xAxis.valueFormatter = nil
        self.lineChartView!.leftAxis.valueFormatter = nil
        
        self.lineChartView?.removeFromSuperview()
        
        self.elevationButtonsViewController?.view.removeFromSuperview()
        self.climbSectionsViewController?.view.removeFromSuperview()
        
        self.mapViewController = nil
        self.route = nil
        
        self.lineChartView = nil
        self.balloonMarker = nil
    }
}

// MARK: - Route Elevation Detail Buttons

class RouteElevationButtonsModel: ObservableObject {
    
    @Published var items: [RouteElevationButtonItem] = []
    
    init(items: [RouteElevationButtonItem]) {
        
        self.items = items
    }
    
    func refresh() {
        
        objectWillChange.send()
    }
    
    deinit {
        
        NSLog("RouteElevationButtonsModel: deinit")
    }
}

enum RouteElevationItemType: Int {
    
    case startElevation, endElevation, minElevation, maxElevation
}

struct RouteElevationButtonItem: Identifiable {
    
    let id = UUID().uuidString
    
    var type: RouteElevationItemType = .startElevation
    var image: UIImage
    var value: Double
}

struct RouteElevationButtonsView: View {
    
    @ObservedObject var model: RouteElevationButtonsModel
    
    var onItemPressed: (_ item: RouteElevationButtonItem) -> Void = { _ in }
    
    var body: some View {
        
        HStack(spacing: 25) {
            
            Spacer()
            
            ForEach(Array(model.items.enumerated()), id: \.1.id) { index, item in
                
                Button {
                    
                    onItemPressed(item)
                    
                } label: {
                    
                    VStack(alignment: .center) {
                        
                        Image(uiImage: item.image)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(getTintColorForType(item.type))
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .padding(20)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Circle())
                            .shadow(color: Color(.lightGray).opacity(0.5), radius: 1.3, x: 0.5, y: 0.8)
                        
                        Text(getElevationValueString(item.value))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    func getTintColorForType(_ type: RouteElevationItemType) -> Color {
        
        switch type {
            
        case .startElevation:
            return .green
            
        case .endElevation:
            return .red
            
        case .minElevation, .maxElevation:
            return .primary
        }
    }
    
    func getElevationValueString(_ value: Double) -> String {
        
        let type = GEMSdk.shared().getUnitSystem()
        
        return String(Int(value)) + " " + (type == .imperialUS ? "ft" : "m")
    }
}

// MARK: - Route Climb Details

class ClimbSectionsModel: ObservableObject {
    
    @Published var items: [ClimbSectionItem] = []
    
    @Published var id = UUID()
    
    init(items: [ClimbSectionItem]) {
        
        self.items = items
    }
    
    func refresh() {
        
        objectWillChange.send()
    }
    
    deinit {
        
        NSLog("ClimbSectionsModel: deinit")
    }
}

struct ClimbSectionItem: Identifiable {
    
    let id = UUID().uuidString
    
    var climbSectionObject: ClimbSectionObject
    
    var grade: ClimbGrade
    var slope: Float
    
    var startDistance: String
    var endDistance: String
    var startElevation: String
    var endElevation: String
    
    var length: String
    var isSelected = false
    
    func getColor() -> UIColor {
        
        switch self.grade {
            
        case .gradeHC: return UIColor.init(red:255/255.0, green:100/255.0, blue:40.0/255.0, alpha:1.0)
        case .grade1:  return UIColor.init(red:255/255.0, green:140/255.0, blue:40.0/255.0, alpha:1.0)
        case .grade2:  return UIColor.init(red:255/255.0, green:180/255.0, blue:40.0/255.0, alpha:1.0)
        case .grade3:  return UIColor.init(red:255/255.0, green:220/255.0, blue:40.0/255.0, alpha:1.0)
        case .grade4:  return UIColor.init(red:255/255.0, green:240/255.0, blue:40.0/255.0, alpha:1.0)
        default:       return UIColor.init(red:255/255.0, green:240/255.0, blue:40.0/255.0, alpha:1.0)
        }
    }
}

struct ClimbSectionsView: View {
    
    @ObservedObject var model: ClimbSectionsModel
    
    var onItemSelected: (_ item: ClimbSectionItem) -> Void = { _ in }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                
                Text("Rating")
                    .font(.system(size: 11, weight: .medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(7)
                    .frame(width: 55)
                
                Divider()
                
                Spacer()
                
                Text("Start/End Points" + "\n" + "Start/End Elevation")
                    .font(.system(size: 11, weight: .medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(7)
                
                Spacer()
                
                Divider()
                
                Text("Length")
                    .font(.system(size: 11, weight: .medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(7)
                    .frame(width: 70)
                
                Divider()
                
                Text("Avg Grade")
                    .font(.system(size: 11, weight: .medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(7)
                    .frame(width: 75)
                
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 40)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 5)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    if model.items.count > 0 {
                        
                        ForEach(Array(model.items.enumerated()), id: \.1.id) { index, item in
                            
                            Button {
                                
                                model.items[index].isSelected.toggle()
                                
                                onItemSelected(item)
                                
                            } label: {
                                
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        
                                        Text(String(item.grade.rawValue))
                                            .font(.system(size: 11, weight: .medium))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .padding(7)
                                            .frame(width: 55)
                                        
                                        Divider()
                                        
                                        Spacer()
                                        
                                        Text(getStartEndString(item))
                                            .font(.system(size: 10, weight: .medium))
                                            .multilineTextAlignment(.center)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .frame(maxWidth: .infinity)
                                            .padding(7)
                                        
                                        Spacer()
                                        
                                        Divider()
                                        
                                        Text(item.length)
                                            .font(.system(size: 11, weight: .medium))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .padding(7)
                                            .frame(width: 70)
                                        
                                        Divider()
                                        
                                        Text(String(format: "%.2f%%", item.slope))
                                            .font(.system(size: 11, weight: .medium))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .padding(7)
                                            .frame(width: 75)
                                    }
                                    .frame(minHeight: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(item.getColor().withAlphaComponent(0.45))))
                                    .padding(.vertical, 5)
                                    .contentShape(Rectangle())
                                    
                                    if index != model.items.count - 1 {
                                        
                                        Divider()
                                    }
                                }
                                .fixedSize(horizontal: false, vertical: true)
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        
                        Text("-")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: 55)
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 20)
            .fill(Color(.secondarySystemGroupedBackground)))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(5)
    }
    
    func getStartEndString(_ item: ClimbSectionItem) -> String {
        
        return item.startDistance + " / " + item.endDistance + "\n" + item.startElevation + " / " + item.endElevation
    }
}

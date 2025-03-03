// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

import Foundation
import Charts
import GEMKit
import SwiftUI

class RoadsChartViewController: UIViewController, ChartViewDelegate {

    var route: RouteObject?

    var mapViewController: MapViewController?
    
    var roadTypes: [RoadType : [ProfileSectionItem]] = [ : ]

    var lineChartView: LineChartView?
    var selectedValueLabel: UILabel = UILabel.init()
    
    var viewTitleLabel: UILabel = UILabel.init()

    var balloonMarker: ChartTypeBalloonMarker?

    var lastSelectedEntry: ChartDataEntry?
    var lastHighlightedRoadType: RoadType?
        
    var pathCollection: [PathObject] = []

    let sampleSize = 300
    var entryValues: [ChartDataEntry] = []
    
    var didSelectValue: (() -> Void) = {}

    public init() {

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    deinit {

        removeHighlightedPaths()
        
        NSLog("RoadsChartViewController: deinit")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {

        super.viewDidLoad()

        self.view.backgroundColor = .secondarySystemGroupedBackground
        self.view.layer.cornerRadius = 20
        self.view.layer.shadowColor = UIColor.lightGray.cgColor
        self.view.layer.shadowOpacity = 0.5
        self.view.layer.shadowOffset = CGSize(width: 0.3, height: 0.8)
        self.view.layer.shadowRadius = 1.4
        
        self.viewTitleLabel.text = "Ways"
        
        self.refreshRoads()

        self.prepareChart()

        self.refreshChartEntries()

        self.prepareLayout()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
    }

    // MARK: - Preparing

    func prepareChart() {

        self.lineChartView = LineChartView.init()

        guard let lineChartView = self.lineChartView else { return }

        let minX: Double = 0.0
        let maxX: Double = 50.0

        let minY: Double = 0
        let maxY: Double = 50

        lineChartView.backgroundColor = .clear
        lineChartView.gridBackgroundColor = .clear

        lineChartView.drawMarkers = true

        lineChartView.extraTopOffset = 0.0
        lineChartView.extraBottomOffset = 10.0
        lineChartView.extraRightOffset = 0.0
        lineChartView.extraLeftOffset = 0.0

        lineChartView.minOffset = 0.0
        lineChartView.keepPositionOnRotation = true

        lineChartView.dragDecelerationFrictionCoef  = 0.5

        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.dragEnabled = false
        lineChartView.dragXEnabled = true
        lineChartView.dragYEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.drawBordersEnabled = false
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.highlightPerDragEnabled = true
        lineChartView.chartDescription.enabled = false

        let leftAxis = lineChartView.leftAxis

        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.axisMaximum = maxY
        leftAxis.axisMinimum = minY
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.gridColor = .lightGray.withAlphaComponent(0.4)
        leftAxis.gridLineDashLengths = [5.0, 5.0]
        leftAxis.drawZeroLineEnabled = false
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelTextColor = .label

        lineChartView.rightAxis.enabled = false

        let xAxis = lineChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.axisMaximum = maxX
        xAxis.axisMinimum = minX
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.drawLabelsEnabled = false
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .label

        lineChartView.legend.enabled = false
        lineChartView.legend.horizontalAlignment = .left
        lineChartView.legend.verticalAlignment = .bottom
        lineChartView.legend.orientation = .horizontal
        lineChartView.legend.xOffset = 0.0

        lineChartView.legend.font = .systemFont(ofSize: 9)
        lineChartView.legend.textColor = .label

        self.balloonMarker = ChartTypeBalloonMarker(color: chartUnhighlightColor, font: .systemFont(ofSize: 9, weight: .semibold), textColor: .label, insets: .zero)

        let arrowSize = CGSize.init(width: 25, height: 21)
        let minimumSize = CGSize.zero
        let insets = UIEdgeInsets.zero

        self.balloonMarker?.arrowSize = arrowSize
        self.balloonMarker?.insets = insets
        self.balloonMarker?.minimumSize = minimumSize
        self.balloonMarker?.drawArrowOnly = true

        self.balloonMarker?.chartView = lineChartView
        lineChartView.marker = self.balloonMarker

        lineChartView.delegate = self
    }

    func prepareLayout() {

        guard let lineChartView = lineChartView else { return }
        
        self.selectedValueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        self.viewTitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        self.viewTitleLabel.textColor = .secondaryLabel
        
        self.view.addSubview(lineChartView)
        self.view.addSubview(self.selectedValueLabel)
        self.view.addSubview(self.viewTitleLabel)
        
        self.selectedValueLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedValueLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            selectedValueLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            selectedValueLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            selectedValueLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: self.viewTitleLabel.bottomAnchor, constant: 5),
            lineChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            lineChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            lineChartView.bottomAnchor.constraint(equalTo: self.selectedValueLabel.topAnchor, constant: 0)
        ])
        
        self.viewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewTitleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            viewTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            viewTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            viewTitleLabel.heightAnchor.constraint(equalToConstant: 25)
        ]) 
    }

    func refreshChartEntries() {

        guard let lineChartView = self.lineChartView else { return }

        if self.entryValues.isEmpty {
            
            var x: Double = 0
            let y: Double = lineChartView.leftAxis.axisMaximum - 11
            
            let maxX = lineChartView.xAxis.axisMaximum
            let minX = lineChartView.xAxis.axisMinimum
            
            let step: Double = (maxX - minX) / Double(self.sampleSize - 1)
            
            for index in 0..<self.sampleSize {
                
                if index > 0 { x += step }
                
                x = min(x, maxX)
                
                if index == self.sampleSize - 1 {
                    
                    x = maxX
                }
                
                let entry = ChartDataEntry(x: x, y: y)
                
                self.entryValues.append(entry)
            }
        }
        
        let arraySets = self.createDataSetsWith(values: self.entryValues)

        let chartData = LineChartData(dataSets: arraySets)

        lineChartView.data = chartData

        if arraySets.count > 0 {

            lineChartView.highlightValue(x: 0.0, dataSetIndex: 0, callDelegate: false)
            
            if let highlight = lineChartView.highlighted.first {
                
                let entry = ChartDataEntry(x: highlight.x, y: highlight.y)
                
                if let roadType = self.getRoadTypeFromEntry(entry) {
                    
                    self.updateTitleLabel(roadType)
                }
            }
        }

        lineChartView.animate(xAxisDuration: 1.5, easingOption: .easeOutBack)
    }

    func createDataSetsWith(values: [ChartDataEntry]) -> [LineChartDataSet] {

        guard let lineChartView = self.lineChartView else { return [] }

        var sets: [LineChartDataSet] = []

        if values.isEmpty { return sets }

        let maxX = lineChartView.xAxis.axisMaximum

        var deltaX: Double = 0.0

        let keys = self.roadTypes.keys.sorted(by: { $0.rawValue < $1.rawValue })
        
        for key in keys {

            var roadsValues: [ChartDataEntry] = []

            let percent: Double = self.getRoadTypePercent(key)

            if percent == 1.0 {

                roadsValues = values

            } else {

                let maxValue = percent * maxX

                for entry in values {

                    if entry.x >= deltaX && entry.x <= maxValue + deltaX {

                        roadsValues.append(entry)
                    }
                }

                deltaX += maxValue
            }

            let setTitle = self.getRoadTypeName(key)
            let setColor = self.getRoadColor(key)
            let colorLabels: UIColor = .label

            let set: LineChartDataSet = LineChartDataSet.init(entries: roadsValues, label: setTitle)

            set.axisDependency = .left
            set.drawIconsEnabled = false
            set.drawValuesEnabled = false
            set.valueTextColor = colorLabels

            set.setColor(setColor)
            set.lineWidth = 5.0
            set.valueFont = .systemFont(ofSize: 9)

            set.formLineWidth = 3.0
            set.formSize = 5.0
            set.drawFilledEnabled = true
            set.fillAlpha = 1.0
            set.fillColor = setColor
            set.fillFormatter = DefaultFillFormatter { _,_  -> CGFloat in
                return CGFloat(lineChartView.leftAxis.axisMinimum)
            }

            set.highlightEnabled = true
            set.highlightColor = chartUnhighlightColor
            set.highlightLineWidth = 2.5
            set.drawHorizontalHighlightIndicatorEnabled = false

            set.drawCirclesEnabled = false
            set.drawCircleHoleEnabled = false

            sets.append(set)

            if percent == 1 { break }
        }

        return sets
    }
    
    func refreshChartHighlightColor(_ color: UIColor) {
        
        guard let lineChartView = self.lineChartView else { return }
        
        guard let balloonMarker = self.balloonMarker else { return }
        
        var count = 0
        
        if let dataSetCount = lineChartView.data?.dataSetCount {
            
            count = dataSetCount
        }
        
        guard count > 0 else { return }
        
        if let dataSets = lineChartView.data?.dataSets {
            
            for dataSet in dataSets {
                
                if let set = dataSet as? LineChartDataSet {
                    
                    set.highlightColor = color
                }
            }
        }
        
        balloonMarker.color = color
        
        lineChartView.setNeedsDisplay()
    }
    
    func refreshWithRoute(_ route: RouteObject) {
        
        self.route = route
        
        self.refreshRoads()
        self.refreshChartEntries()
        
        self.removeHighlightedPaths()
    }

    // MARK: - ChartViewDelegate

    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {

    }

    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {

    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        self.lastSelectedEntry = entry
        
        if let surfaceType = self.getRoadTypeFromEntry(entry) {
            
            self.updateTitleLabel(surfaceType)
            self.handleHighlightRoadTypes(surfaceType)
        }
        
        self.refreshChartHighlightColor(chartHighlightColor)
        
        self.didSelectValue()
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
    }
    
    // MARK: - Utils
    
    func getRoadTypeFromEntry(_ entry: ChartDataEntry) -> RoadType? {
        
        guard let lineChartView = self.lineChartView else { return nil }
        guard let data = lineChartView.data else { return nil }

        let keys = self.roadTypes.keys.sorted(by: { $0.rawValue < $1.rawValue })
        
        for (index, set) in data.dataSets.enumerated() {

            if let lineSet = set as? LineChartDataSet {

                if lineSet.count > 0 {

                    if let lastEntry = lineSet.entries.last {

                        if entry.x <= lastEntry.x {
                            
                            for (roadIndex, key) in keys.enumerated() {

                                if roadIndex == index {

                                    return key
                                }
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func updateTitleLabel(_ roadType: RoadType) {
        
        self.selectedValueLabel.text = self.getRoadTypeName(roadType)
    }
    
    func handleHighlightRoadTypes(_ roadType: RoadType) {
        
        guard let mapViewController = self.mapViewController else { return }
        
        guard let route = self.route else { return }
        
        if let lastHighlightedRoadType = self.lastHighlightedRoadType {
            
            if lastHighlightedRoadType == roadType {
                
                return
                
            } else {
                
                self.removeHighlightedPaths()
            }
        }
        
        let pathsCollection = mapViewController.getPaths()
        
        let color = UIColor(red: 239/255, green: 38/255, blue: 81/255, alpha: 1.0)
        
        if let pathCollections = pathsCollection {
            
            if let items = self.roadTypes[roadType] {
                
                for item in items {
                    
                    if let pathObject = route.getPath(Int32(item.startDistance), end: Int32(item.startDistance + item.length)) {
                        
                        let success = pathCollections.add(pathObject, colorBorder: color, colorInner: color, szBorder: 0.5, szInner: 1.0)
                        
                        if success {
                            
                            self.pathCollection.append(pathObject)
                        }
                    }
                }
            }
            
            self.mapViewController!.removeHighlight(defaultLandmarksHighlightId)
        }
        
        self.lastHighlightedRoadType = roadType
    }
    
    func removeHighlightedPaths() {
        
        guard let mapViewController = self.mapViewController else { return }
        
        guard self.pathCollection.count > 0 else { return }
        
        if let pathsCollections = mapViewController.getPaths() {
            
            for path in self.pathCollection {
                
                pathsCollections.remove(path)
            }
        }
        
        self.pathCollection.removeAll()
        
        self.lastHighlightedRoadType = nil
        
        self.refreshChartHighlightColor(chartUnhighlightColor)
    }

    func refreshRoads() {

        guard let route = self.route else { return }

        guard let profile = route.getTerrainProfile() else { return  }

        guard let timeDistance = route.getTimeDistance() else { return }
        
        self.roadTypes = [ : ]

        let roads = profile.getRoadTypeSections()

        let count = roads.count

        var length = 0

        for (index, item) in roads.enumerated() {

            if index < count - 1 {

                length = Int(roads[index + 1].startDistanceM - item.startDistanceM)

            } else {

                length = Int(timeDistance.getTotalDistance()) - Int(item.startDistanceM)
            }

            if self.roadTypes[item.type] != nil {

                self.roadTypes[item.type]!.append(ProfileSectionItem(startDistance: Int(item.startDistanceM), length: length))

            } else {

                self.roadTypes[item.type] = [ProfileSectionItem(startDistance: Int(item.startDistanceM), length: length)]
            }
        }
    }

    func roadTypesCount() -> Int {

        return self.roadTypes.keys.count
    }

    func getRoadTypePercent(_ type: RoadType) -> Double {

        guard let timeDistance = self.route?.getTimeDistance() else { return 0.0 }

        let totalDistance = timeDistance.getTotalDistance()

        if let items = self.roadTypes[type] {

            var length: Double = 0.0

            for item in items {

                length += Double(item.length)
            }

            return length / Double(totalDistance)
        }

        return 0.0
    }
    
    func getRoadTypeLengthString(_ type: RoadType) -> String {
        
        if let items = self.roadTypes[type] {

            var length: Int = 0

            for item in items {

                length += item.length
            }

            return getMeterLocalized(value: length)
        }

        return ""
    }
    
    func getMeterLocalized(value: Int) -> String {
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        formatter.numberFormatter.roundingMode = .down
        
        let string = formatter.string(from: Measurement(value: Double(value), unit: UnitLength.meters))
        
        return string
    }

    func getRoadTypeName(_ type: RoadType) -> String {

        let percent = self.getRoadTypePercent(type)
        let lengthString = self.getRoadTypeLengthString(type)
        
        var roadString = ""

        switch type {

        case .motorways:   roadString = "Motorways"

        case .stateRoad:   roadString = "State Road"

        case .road:        roadString = "Road"

        case .street:      roadString = "Street"

        case .cycleway:    roadString = "Cycleway"

        case .path:        roadString = "Path"

        case .singleTrack: roadString = "Single Track"

        default:           roadString = "Unknown"
        }

        return String.init(format: "%@: %@ (%.2f%%)", roadString, lengthString, percent * 100)
    }

    func getRoadColor(_ type: RoadType) -> UIColor {

        switch type {

        case .motorways:   return UIColor(red: 242/255, green: 144/255, blue: 99/255, alpha: 1)

        case .stateRoad:   return UIColor(red: 242/255, green: 216/255, blue: 99/255, alpha: 1)

        case .road:        return UIColor(red: 153/255, green: 163/255, blue: 175/255, alpha: 1)

        case .street:      return UIColor(red: 175/255, green: 185/255, blue: 193/255, alpha: 1)

        case .cycleway:    return UIColor(red: 15/255, green: 175/255, blue: 135/255, alpha: 1)

        case .path:        return UIColor(red: 196/255, green: 200/255, blue: 211/255, alpha: 1)

        case .singleTrack: return UIColor(red: 166/255, green: 133/255, blue: 96/255, alpha: 1)

        default:           return UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)

        }
    }
}

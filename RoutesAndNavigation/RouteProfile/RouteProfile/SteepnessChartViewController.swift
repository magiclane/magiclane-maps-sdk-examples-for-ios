// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import Foundation
import Charts
import GEMKit
import SwiftUI

class SteepnessChartViewController: UIViewController, ChartViewDelegate {
    
    var route: RouteObject?
    
    var mapViewController: MapViewController?
    
    var steepnessTypes: [Int : [ProfileSectionItem]] = [ : ]
    
    var lineChartView: LineChartView?
    var selectedValueImage: UIImageView = UIImageView()
    var selectedValueLabel: UILabel = UILabel.init()
    
    var viewTitleLabel: UILabel = UILabel.init()
    
    var balloonMarker: ChartTypeBalloonMarker?
    
    var lastSelectedEntry: ChartDataEntry?
    var lastHighlightedSteepness: Int?
        
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
        
        NSLog("SteepnessChartViewController: deinit")
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
        
        self.viewTitleLabel.text = "Steepness"
        
        self.refreshSteepnessSections()
        
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
        self.view.addSubview(self.selectedValueImage)
        self.view.addSubview(self.selectedValueLabel)
        self.view.addSubview(self.viewTitleLabel)
        
        self.selectedValueLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedValueLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            selectedValueLabel.leadingAnchor.constraint(equalTo: self.selectedValueImage.trailingAnchor, constant: 8),
            selectedValueLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            selectedValueLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        self.selectedValueImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedValueImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            selectedValueImage.widthAnchor.constraint(equalToConstant: 25),
            selectedValueImage.heightAnchor.constraint(equalToConstant: 25),
            selectedValueImage.centerYAnchor.constraint(equalTo: self.selectedValueLabel.centerYAnchor)
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
                
                if let category = self.getSteepnessFromEntry(entry) {
                    
                    self.updateTitleLabel(category)
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
        
        let keys = self.steepnessTypes.keys.sorted(by: { $0 < $1 })
        
        for key in keys {
            
            var steepnessValues: [ChartDataEntry] = []
            
            let percent: Double = self.getSteepnessTypePercent(key)
            
            if percent == 1.0 {
                
                steepnessValues = values
                
            } else {
                
                let maxValue = percent * maxX
                
                for entry in values {
                    
                    if entry.x >= deltaX && entry.x <= maxValue + deltaX {
                        
                        steepnessValues.append(entry)
                    }
                }
                
                deltaX += maxValue
            }
            
            let setTitle = self.getSteepnessTypeName(key)
            let setColor = self.getSteepnessTypeColor(key)
            let colorLabels: UIColor = .label
            
            let set: LineChartDataSet = LineChartDataSet.init(entries: steepnessValues, label: setTitle)
            
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
        
        self.refreshSteepnessSections()
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
        
        if let category = self.getSteepnessFromEntry(entry) {
            
            self.updateTitleLabel(category)
            self.handleHighlightSteepness(category)
        }
        
        self.refreshChartHighlightColor(chartHighlightColor)
        
        self.didSelectValue()
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
    }
    
    // MARK: - Utils
    
    func getSteepnessFromEntry(_ entry: ChartDataEntry) -> Int? {
        
        guard let lineChartView = self.lineChartView else { return nil }
        guard let data = lineChartView.data else { return nil }
        
        let keys = self.steepnessTypes.keys.sorted(by: { $0 < $1 })
        
        for (index, set) in data.dataSets.enumerated() {
            
            if let lineSet = set as? LineChartDataSet {
                
                if lineSet.count > 0 {
                    
                    if let lastEntry = lineSet.entries.last {
                        
                        if entry.x <= lastEntry.x {
                            
                            for (steepnessIndex, key) in keys.enumerated() {
                                
                                if steepnessIndex == index {
                                    
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
    
    func updateTitleLabel(_ category: Int) {
        
        self.selectedValueLabel.text = self.getSteepnessTypeName(category)
        self.selectedValueImage.image = self.getSteepnessTypeImage(category)
        self.selectedValueImage.tintColor = self.getSteepnessTypeImageTint(category)
    }
    
    func handleHighlightSteepness(_ category: Int) {
        
        
        
        guard let mapViewController = self.mapViewController else { return }
        
        guard let route = self.route else { return }
        
        if let lastHighlightedSteepness = self.lastHighlightedSteepness {
            
            if lastHighlightedSteepness == category {
                
                return
                
            } else {
                
                self.removeHighlightedPaths()
            }
        }
        
        let pathsCollection = mapViewController.getPaths()
        
        let color = UIColor(red: 239/255, green: 38/255, blue: 81/255, alpha: 1.0)
        
        if let pathCollections = pathsCollection {
            
            if let items = self.steepnessTypes[category] {
                
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
        
        self.lastHighlightedSteepness = category
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
        
        self.lastHighlightedSteepness = nil
        
        self.refreshChartHighlightColor(chartUnhighlightColor)
    }
    
    func refreshSteepnessSections() {
        
        guard let route = self.route else { return }
        
        guard let profile = route.getTerrainProfile() else { return  }
        
        guard let timeDistance = route.getTimeDistance() else { return }
        
        self.steepnessTypes = [ : ]
        
        let steepnessSections = profile.getSteepSections([-16.0, -10.0, -7.0, -4.0, -1.0, 1.0, 4.0, 7.0, 10.0, 16.0])
        
        let count = steepnessSections.count
        
        var length = 0
        
        for (index, item) in steepnessSections.enumerated() {
            
            if index < count - 1 {
                
                length = Int(steepnessSections[index + 1].startDistanceM - item.startDistanceM)
                
            } else {
                
                length = Int(timeDistance.getTotalDistance()) - Int(item.startDistanceM)
            }
            
            if self.steepnessTypes[Int(item.categ)] != nil {
                
                self.steepnessTypes[Int(item.categ)]!.append(ProfileSectionItem(startDistance: Int(item.startDistanceM), length: length))
                
            } else {
                
                self.steepnessTypes[Int(item.categ)] = [ProfileSectionItem(startDistance: Int(item.startDistanceM), length: length)]
            }
        }
    }
    
    func steepnessTypesCount() -> Int {
        
        return self.steepnessTypes.keys.count
    }
    
    func getSteepnessTypePercent(_ category: Int) -> Double {
        
        guard let timeDistance = self.route?.getTimeDistance() else { return 0.0 }
        
        let totalDistance = timeDistance.getTotalDistance()
        
        if let items = self.steepnessTypes[category] {
            
            var length: Double = 0.0
            
            for item in items {
                
                length += Double(item.length)
            }
            
            return length / Double(totalDistance)
        }
        
        return 0.0
    }
    
    func getSteepnessTypeLengthString(_ category: Int) -> String {
        
        if let items = self.steepnessTypes[category] {

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

    func getSteepnessTypeName(_ category: Int) -> String {

        let percent = self.getSteepnessTypePercent(category)
        let lengthString = self.getSteepnessTypeLengthString(category)
        
        var steepnessString = ""

        switch category {

        case 0:  steepnessString = "16%+"

        case 1:  steepnessString = "10-15%"

        case 2:  steepnessString = "7-9%"

        case 3:  steepnessString = "4-6%"

        case 4:  steepnessString = "1-3%"

        case 5:  steepnessString = "0%"

        case 6:  steepnessString = "1-3%"
            
        case 7:  steepnessString = "4-6%"
            
        case 8:  steepnessString = "7-9%"
            
        case 9:  steepnessString = "10-15%"
            
        case 10: steepnessString = "16%+"

        default: steepnessString = "0%"
        }

        return String.init(format: "%@: %@ (%.2f%%)", steepnessString, lengthString, percent * 100)
    }

    func getSteepnessTypeColor(_ category: Int) -> UIColor {

        switch category {

        case 0:  return UIColor(red: 4/255, green: 120/255, blue: 8/255, alpha: 1)

        case 1:  return UIColor(red: 38/255, green: 151/255, blue: 41/255, alpha: 1)

        case 2:  return UIColor(red: 73/255, green: 183/255, blue: 76/255, alpha: 1)

        case 3:  return UIColor(red: 112/255, green: 216/255, blue: 115/255, alpha: 1)

        case 4:  return UIColor(red: 154/255, green: 250/255, blue: 156/255, alpha: 1)

        case 5:  return UIColor(red: 255/255, green: 197/255, blue: 142/255, alpha: 1)

        case 6:  return UIColor(red: 240/255, green: 141/255, blue: 141/255, alpha: 1)
            
        case 7:  return UIColor(red: 220/255, green: 105/255, blue: 105/255, alpha: 1)
            
        case 8:  return UIColor(red: 201/255, green: 73/255, blue: 73/255, alpha: 1)
            
        case 9:  return UIColor(red: 182/255, green: 42/255, blue: 42/255, alpha: 1)
            
        case 10: return UIColor(red: 164/255, green: 16/255, blue: 16/255, alpha: 1)

        default: return UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)

        }
    }
    
    func getSteepnessTypeImage(_ category: Int) -> UIImage? {
        
        var name = ""
        
        if category >= 0 && category < 5 {
            
            name = "arrow.down.right.circle.fill"
            
        } else if category == 5 {
            
            name = "arrow.right.circle.fill"
            
        } else if category > 5 {
            
            name = "arrow.up.right.circle.fill"
        }
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 12)
        
        return UIImage(systemName: name, withConfiguration: configuration)
    }
    
    func getSteepnessTypeImageTint(_ category: Int) -> UIColor {
        
        var color = UIColor.label
        
        if category >= 0 && category < 5 {
            
            color = .systemGreen
        }
        
        if category > 5 {
            
            color = .systemPink
        }
        
        return color
    }
}

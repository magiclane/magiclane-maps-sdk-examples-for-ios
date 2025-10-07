// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

enum RangeTransportMode: Int {
    
    case car, pedestrian, bicycle, truck
}

enum NavigationCarSettingsKey: String {
    
    case travelModeKey        = "travelModeKey"
    case avoidTrafficKey      = "avoidTrafficKey"
    case northUpKey           = "northUpKey"
    
    case avoidMotorwaysKey    = "avoidMotorwaysKey"
    case avoidTollRoadsKey    = "avoidTollRoads"
    case avoidFerriesKey      = "avoidFerriesKey"
    case avoidUnpavedRoadsKey = "avoidUnpavedRoadsKey"
    
    case trafficDelaysKey     = "trafficDelaysKey"
}

enum NavigationBikeSettingsKey: String {
    
    case travelModeKey        = "travelModeKey"
    case bikeTypeKey          = "bikeTypeKey"
    case avoidHillsKey        = "avoidHillsKey"
    case avoidFerriesKey      = "avoidFerriesKey"
    case avoidUnpavedRoadsKey = "avoidUnpavedRoadsKey"
    case ignoreRestrictions   = "ignoreRestrictionsKey"
    case bikeWeight           = "bikeWeight"
    case bikerWeight          = "bikerWeight"
}

enum NavigationPedestrianSettingsKey: String {

    case avoidFerriesKey      = "avoidFerriesKey"
    case avoidUnpavedRoadsKey = "avoidUnpavedRoadsKey"
}

enum NavigationTruckSettingsKey: String {
    
    case travelModeKey        = "travelModeKey"
    case avoidTrafficKey      = "avoidTrafficKey"
    case northUpKey           = "northUpKey"
    
    case avoidMotorwaysKey    = "avoidMotorwaysKey"
    case avoidTollRoadsKey    = "avoidTollRoads"
    case avoidFerriesKey      = "avoidFerriesKey"
    case avoidUnpavedRoadsKey = "avoidUnpavedRoadsKey"
    
    case trafficDelaysKey     = "trafficDelaysKey"
    
    case widthKey      = "widthKey"
    case heightKey     = "heightKey"
    case lengthKey     = "lengthKey"
    case weightKey     = "weightKey"
    case axleWeightKey = "axleWeightKey"
    case maxSpeedKey   = "maxSpeedKey"
}

struct RangeSettingsItem: Identifiable, Equatable {
    
    let id = UUID().uuidString
    
    var title: String = ""
    var description: String = ""
    var itemKey: String
    var itemType: RangeModeItemType
    
    var isSlider = false
    var sliderValue: Double = 5.0
    var sliderMinValue: Double = 0.0
    var sliderMaxValue: Double = 30.0
    
    var isToggle = false
    var toggleState: Bool = false
    
    var isOption = false
    var options: [String] = []
    var chosenOption: Int = 0
}

enum RangeModeItemType: Int, CaseIterable {
    
    case travelMode, avoidTraffic, avoidMotorways, avoidTollRoads, avoidFerries, avoidUnpavedRoads, trafficDelays, bikeType, avoidHills
}

enum RangeValueType: Int {
    
    case distance, watts, time
}

class RangeValueRoutesItem: Identifiable, ObservableObject {

    let id = UUID().uuidString
    
    var rangeValue: Double = 0.0
    var rangeType: RangeValueType = .time
    var routes: [RouteObject] = []
    var transportMode: RangeTransportMode = .car
    @Published var routeColor: UIColor = .systemBlue
    @Published var isSelected: Bool = false
    
    init(rangeType: RangeValueType, rangeValue: Double, routes: [RouteObject], transportMode: RangeTransportMode) {
        
        self.rangeType = rangeType
        self.rangeValue = rangeValue
        self.routes = routes
        self.transportMode = transportMode
    }
}

class RangeSettingsModel: ObservableObject {
    
    @Published var items: [RangeSettingsItem] = []
    
    var mode: RangeTransportMode = .car
    
    @Published var rangeValue: Double = 0.0
    var minRangeValue: Double = 0.0
    var maxRangeValue: Double = 0.0
    var rangeStep: Double = 1.0
    var rangeLeftLabel: String = ""
    var rangeRightLabel: String = ""
    var rangeType: RangeValueType = .time
    
    var iOS16available = false
    
    @Published var presentedRoutes: [RangeValueRoutesItem] = []
    
    var settings: [String : NSNumber] = [:]
    
    @Published var isCalculating: Bool = false
    
    init(modeType: RangeTransportMode) {
        
        self.mode = modeType
        
        if #available(iOS 16.0, *) {
            
            self.iOS16available = true
        }
        
        self.refresh(mode: mode)
    }
    
    func getNavigationPedestrianDefaultSettings() ->  [String : NSNumber]  {
        
        let dictionary: [String : NSNumber] = [
            
            NavigationPedestrianSettingsKey.avoidFerriesKey.rawValue      : NSNumber.init(value: false),
            NavigationPedestrianSettingsKey.avoidUnpavedRoadsKey.rawValue : NSNumber.init(value: false)
        ]
        
        return dictionary
    }
    
    func getNavigationBikeDefaultSettings() ->  [String : NSNumber]  {
        
        let dictionary: [String : NSNumber] = [
            
            NavigationBikeSettingsKey.travelModeKey.rawValue        : NSNumber.init(value: Int(0)), // Fastest
            NavigationBikeSettingsKey.bikeTypeKey.rawValue          : NSNumber.init(value: Int(2)),
            NavigationBikeSettingsKey.avoidHillsKey.rawValue        : NSNumber.init(value: Int(5)),
            
            NavigationBikeSettingsKey.avoidFerriesKey.rawValue      : NSNumber.init(value: false),
            NavigationBikeSettingsKey.avoidUnpavedRoadsKey.rawValue : NSNumber.init(value: false),
            NavigationBikeSettingsKey.ignoreRestrictions.rawValue   : NSNumber.init(value: false),
            
            NavigationBikeSettingsKey.bikeWeight.rawValue           : NSNumber.init(value: Double(20.0)),
            NavigationBikeSettingsKey.bikerWeight.rawValue          : NSNumber.init(value: Double(70.0)),
        ]
        
        return dictionary
    }
    
    func getNavigationCarDefaultSettings() ->  [String : NSNumber]  {
        
        let dictionary: [String : NSNumber] = [
            
            NavigationCarSettingsKey.travelModeKey.rawValue        : NSNumber.init(value: Int(0)), // Fastest
            NavigationCarSettingsKey.avoidTrafficKey.rawValue      : NSNumber.init(value: Int(1)), // Prefer Current Route
            NavigationCarSettingsKey.northUpKey.rawValue           : NSNumber.init(value: false),  // North Up
            
            NavigationCarSettingsKey.avoidMotorwaysKey.rawValue    : NSNumber.init(value: false),
            NavigationCarSettingsKey.avoidTollRoadsKey.rawValue    : NSNumber.init(value: false),
            NavigationCarSettingsKey.avoidFerriesKey.rawValue      : NSNumber.init(value: false),
            NavigationCarSettingsKey.avoidUnpavedRoadsKey.rawValue : NSNumber.init(value: true),
            
            NavigationCarSettingsKey.trafficDelaysKey.rawValue     : NSNumber.init(value: Int(5)), // Delay 5 min
        ]
        
        return dictionary
    }
    
    func getNavigationTruckDefaultSettings() ->  [String : NSNumber]  {
        
        let dictionary: [String : NSNumber] = [
            
            NavigationTruckSettingsKey.travelModeKey.rawValue        : NSNumber.init(value: Int(0)), // Fastest
            NavigationTruckSettingsKey.avoidTrafficKey.rawValue      : NSNumber.init(value: Int(1)), // Prefer Current Route
            NavigationTruckSettingsKey.northUpKey.rawValue           : NSNumber.init(value: false),  // North Up
            
            NavigationTruckSettingsKey.avoidMotorwaysKey.rawValue    : NSNumber.init(value: false),
            NavigationTruckSettingsKey.avoidTollRoadsKey.rawValue    : NSNumber.init(value: false),
            NavigationTruckSettingsKey.avoidFerriesKey.rawValue      : NSNumber.init(value: false),
            NavigationTruckSettingsKey.avoidUnpavedRoadsKey.rawValue : NSNumber.init(value: true),
            
            NavigationTruckSettingsKey.trafficDelaysKey.rawValue     : NSNumber.init(value: Int(5)), // Delay 5 min
            
            NavigationTruckSettingsKey.widthKey.rawValue      : NSNumber.init(value: Double(2.5)), // 2.5m
            NavigationTruckSettingsKey.heightKey.rawValue     : NSNumber.init(value: Double(3)),   // 3m
            NavigationTruckSettingsKey.lengthKey.rawValue     : NSNumber.init(value: Double(10)),  // 10m
            NavigationTruckSettingsKey.weightKey.rawValue     : NSNumber.init(value: Double(10)),  // 10t
            NavigationTruckSettingsKey.axleWeightKey.rawValue : NSNumber.init(value: Double(5)),   // 5t
            NavigationTruckSettingsKey.maxSpeedKey.rawValue   : NSNumber.init(value: Double(90)),  // 90km/h
        ]
        
        return dictionary
    }
    
    func refresh(mode: RangeTransportMode) {
        
        switch mode {
            
        case .pedestrian:
            self.settings = self.getNavigationPedestrianDefaultSettings()
            
        case .bicycle:
            self.settings = self.getNavigationBikeDefaultSettings()
            
        case .car:
            self.settings = self.getNavigationCarDefaultSettings()
            
        case .truck:
            self.settings = self.getNavigationTruckDefaultSettings()
            
        }
        
        if mode == .truck {
            
            self.items = [
                
                RangeSettingsItem(title: "Travel Mode", description: "",
                                  itemKey: NavigationTruckSettingsKey.travelModeKey.rawValue, itemType: .travelMode, isOption: true,
                                  options: [ "Fastest",
                                             "Shortest"]),
                
                RangeSettingsItem(title: "Avoid Traffic", description: "",
                                  itemKey: NavigationTruckSettingsKey.avoidTrafficKey.rawValue, itemType: .avoidTraffic, isOption: true,
                                  options: [ "Prefer Faster Route",
                                             "Prefer Current Route",
                                             "off"]),
                
                RangeSettingsItem(title: "Avoid Motorways",
                                  itemKey: NavigationTruckSettingsKey.avoidMotorwaysKey.rawValue, itemType: .avoidMotorways, isToggle: true),
                
                RangeSettingsItem(title: "Avoid Toll Roads",
                                  itemKey: NavigationTruckSettingsKey.avoidTollRoadsKey.rawValue, itemType: .avoidTollRoads, isToggle: true),
                
                RangeSettingsItem(title: "Avoid Ferries",
                                  itemKey: NavigationTruckSettingsKey.avoidFerriesKey.rawValue, itemType: .avoidFerries, isToggle: true),
                
                RangeSettingsItem(title: "Avoid Unpaved Roads",
                                  itemKey: NavigationTruckSettingsKey.avoidUnpavedRoadsKey.rawValue, itemType: .avoidUnpavedRoads, isToggle: true),
            ]
            
        } else if mode == .pedestrian {
            
            self.items = [
                
                RangeSettingsItem(title: "Avoid Ferries",
                                  itemKey: NavigationPedestrianSettingsKey.avoidFerriesKey.rawValue, itemType: .avoidFerries, isToggle: true),
                
                RangeSettingsItem(title: "Avoid Unpaved Roads",
                                  itemKey: NavigationPedestrianSettingsKey.avoidUnpavedRoadsKey.rawValue, itemType: .avoidUnpavedRoads, isToggle: true)
            ]
            
        } else if mode == .bicycle {
            
            self.items = [
                
                RangeSettingsItem(title: "Travel Mode", description: "",
                                  itemKey: NavigationBikeSettingsKey.travelModeKey.rawValue, itemType: .travelMode, isOption: true,
                                  options: [ "Fastest",
                                             "Economic"]),
                
                RangeSettingsItem(title: "Bike Type", description: "",
                                  itemKey: NavigationBikeSettingsKey.bikeTypeKey.rawValue, itemType: .bikeType, isOption: true,
                                  options: [ "road",
                                             "cross",
                                             "city",
                                             "mountain"]),
                
                RangeSettingsItem(title: "Avoid Ferries",
                                  itemKey: NavigationBikeSettingsKey.avoidFerriesKey.rawValue, itemType: .avoidFerries, isToggle: true),
                
                RangeSettingsItem(title: "Avoid Unpaved Roads",
                                  itemKey: NavigationBikeSettingsKey.avoidUnpavedRoadsKey.rawValue, itemType: .avoidUnpavedRoads, isToggle: true),
                
                RangeSettingsItem(title: "Hhills", description: "",
                                  itemKey: NavigationBikeSettingsKey.avoidHillsKey.rawValue, itemType: .avoidHills, isSlider: true, sliderMaxValue: 10)
            ]
            
        } else if mode == .car {
            
            self.items = [
                
                RangeSettingsItem(title: "Range Type", description: "",
                                  itemKey: NavigationCarSettingsKey.travelModeKey.rawValue, itemType: .travelMode, isOption: true,
                                  options: [ "Fastest",
                                             "Shortest"]),
                
                RangeSettingsItem(title: "Avoid Motorways",
                                  itemKey: NavigationCarSettingsKey.avoidMotorwaysKey.rawValue, itemType: .avoidMotorways, isToggle: true),
                
                RangeSettingsItem(title: "Avoid Toll Roads",
                                  itemKey: NavigationCarSettingsKey.avoidTollRoadsKey.rawValue, itemType: .avoidTollRoads, isToggle: true),
                
                RangeSettingsItem(title: "Avoid Ferries",
                                  itemKey: NavigationCarSettingsKey.avoidFerriesKey.rawValue, itemType: .avoidFerries, isToggle: true),
                
                RangeSettingsItem(title: "Avoid Unpaved Roads",
                                  itemKey: NavigationCarSettingsKey.avoidUnpavedRoadsKey.rawValue, itemType: .avoidUnpavedRoads, isToggle: true),
            ]
        }
        
        for (index, item) in self.items.enumerated() {
            
            if item.isToggle {
                
                if let value = settings[item.itemKey] {
                    
                    self.items[index].toggleState = value.boolValue
                }
                
            } else if item.isOption {
                
                if let value = settings[item.itemKey] {
                    
                    self.items[index].chosenOption = value.intValue
                }
                
            } else if item.isSlider {
                
                if let value = settings[item.itemKey] {
                    
                    self.items[index].sliderValue = value.doubleValue
                }
            }
        }
        
        self.mode = mode
        self.refreshRangeSlider()
    }
    
    func refreshRangeType() {
        
        if self.mode == .pedestrian {
            
            self.rangeType = .time
            
        } else {
            
            for item in self.items {
                
                if item.itemType == .travelMode {
                    
                    if item.chosenOption == 0 { //Fastest
                        
                        self.rangeType = .time
                        
                    } else {
                        
                        if self.mode == .bicycle { //Economic
                            
                            self.rangeType = .watts
                            
                        } else { //Shortest
                            
                            self.rangeType = .distance
                        }
                    }
                }
            }
        }
    }
    
    func refreshRangeSlider() {
        
        self.refreshRangeType()
        
        switch self.rangeType {
            
        case .time:
            
            let dateComponentsFormatter = DateComponentsFormatter()
            dateComponentsFormatter.allowedUnits = [.minute, .hour]
            dateComponentsFormatter.unitsStyle = .short
            
            self.minRangeValue = 1.0
            self.maxRangeValue = 180.0
            self.rangeValue = 10.0
            self.rangeStep = 1.0
            self.rangeLeftLabel = dateComponentsFormatter.string(from: self.minRangeValue * 60.0) ?? String(1.0)
            self.rangeRightLabel = dateComponentsFormatter.string(from: self.maxRangeValue * 60.0) ?? String(60.0)
            
        case .watts:
            
            self.minRangeValue = 10.0
            self.maxRangeValue = 2000.0
            self.rangeValue = 100.0
            self.rangeStep = 10.0
            self.rangeLeftLabel = String(minRangeValue) + " " + "wh"
            self.rangeRightLabel = String(maxRangeValue) + " " + "wh"
            
        case .distance:
            
            self.minRangeValue = 100
            self.maxRangeValue = 200000.0
            self.rangeValue = 1000.0
            self.rangeStep = 100.0
            self.rangeLeftLabel = self.getMeterLocalized(value: self.minRangeValue)
            self.rangeRightLabel = self.getMeterLocalized(value: self.maxRangeValue)
        }
    }
    
    func getValueStringWithUnit(value: Double, unitType: RangeValueType) -> String {
        
        var string = ""
        
        switch unitType {
            
        case .time:
            
            let dateComponentsFormatter = DateComponentsFormatter()
            dateComponentsFormatter.allowedUnits = [.minute, .hour]
            dateComponentsFormatter.unitsStyle = .short
            
            string = dateComponentsFormatter.string(from: value * 60.0) ?? String(1.0)
            
        case .distance:
            
            string = self.getMeterLocalized(value: value)
            
        case .watts:
            
            string = String(Int(value)) + " " + "wh"
        }

        return string
    }
    
    func itemIndexFromKey(_ key: String) -> Int {
        
        if let index = self.items.firstIndex(where: { $0.itemKey == key }) {
            
            return index
        }
        
        return -1
    }
    
    func getMeterLocalized(value: Double) -> String {
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        formatter.numberFormatter.roundingMode = .down
        
        let string = formatter.string(from: Measurement(value: value, unit: UnitLength.meters))
        
        return string
    }
    
    func getPresentedRangeRoutes() -> [RouteObject] {
        
        var routes: [RouteObject] = []
        
        for rangeRoute in presentedRoutes {
            
            routes.append(contentsOf: rangeRoute.routes)
        }
        
        return routes
    }
    
    func addPresentedRoutes(_ item: RangeValueRoutesItem) {
        
        self.presentedRoutes.append(item)
            
        item.isSelected = true
    }
    
    func removePresentedRoutes(index: Int) {
        
        withAnimation(.linear(duration: 0.15)) {
            
        _ = self.presentedRoutes.remove(at: index)
        }
    }
    
    func isRangeValueUsed(value: Double, transportMode: RangeTransportMode) -> Bool {
        
        if let _ = self.presentedRoutes.first(where: { $0.rangeValue == value && $0.transportMode == transportMode }) {
            
            return true
        }
        
        return false
    }
    
    func getSelectedRangeRoutes() -> [RouteObject] {
        
        var selectedRangeRoutes: [RouteObject] = []
        
        for item in self.presentedRoutes {
            
            if item.isSelected {
                
                selectedRangeRoutes.append(contentsOf: item.routes)
            }
        }
        
        return selectedRangeRoutes
    }
    
    deinit {
        
        
    }
}

struct RangeView: View {
    
    @ObservedObject var model: RangeSettingsModel
    
    var didSelectOptionItem: (_ item: RangeSettingsItem) -> Void = { _ in }
    var didSelectTransportMode: () -> Void = { }
    var onRangeAdded: () -> Void = {}
    var onRangeDeleted: (_ item: RangeValueRoutesItem) -> Void = { _ in }
    var onRangeSelected: (_ item: RangeValueRoutesItem) -> Void = { _ in }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            List {
                
                Section {
                    
                    RangeValueSliderView(model: model, onRangeAdded: onRangeAdded)
                    TransportModeOptionView(model: model, didSelectTransportMode: didSelectTransportMode)
                    
                } header: {
                            
                    if model.presentedRoutes.count > 0 {
                        HStack(spacing: 10) {
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                
                                ScrollViewReader { value in
                                    
                                    HStack(alignment: .center, spacing: 10) {
                                        ForEach(Array(model.presentedRoutes.enumerated()), id: \.1.id) { index, item in
                                            
                                            RangeValueRoutesItemView(model: model, item: model.presentedRoutes[index], index: index, onRangeDeleted: onRangeDeleted, onRangeSelected: onRangeSelected)
                                                .id(item.id)
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                        .onChange(of: model.presentedRoutes.count) { [oldCount = model.presentedRoutes.count] count in
                                            
                                            if count > oldCount {
                                                
                                                value.scrollTo(model.presentedRoutes[count - 1].id, anchor: .trailing)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 40)
                        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    }
                }
                .textCase(nil)
                
                Section {
                    
                    ForEach(Array(model.items.enumerated()), id: \.1.id) { index, item in
                        
                        if item.isToggle {
                            
                            RangeToggleItemView(model: model, item: $model.items[index])
                            
                        } else if item.isOption {
                            
                            RangeOptionItemView(model: model, item: $model.items[index], didSelectOptionItem: didSelectOptionItem)
                            
                        } else if item.isSlider {
                            
                            RangeSliderItemView(model: model, item: $model.items[index])
                        }
                    }
                }
            }
            .headerProminence(.increased)
            .blur(radius: model.isCalculating && model.iOS16available ? 2.5 : 0.0)
            .opacity(model.isCalculating ? 0.4 : 1)
            .ignoresSafeArea(.keyboard)
            .navigationBarTitleDisplayMode(.inline)
            .allowsHitTesting(!(model.isCalculating && model.iOS16available))
            
            if model.isCalculating {
                VStack(alignment: .center) {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(model.iOS16available ? nil : Color(.systemBackground).opacity(0.10))
            }
        }
    }
    
    func updateSettingsOnOption(item: RangeSettingsItem, newOption: Int) {
        
        let index = model.itemIndexFromKey(item.itemKey)
        
        let chosenOption = model.items[index].chosenOption
        
        if chosenOption != newOption {
            
            model.items[index].chosenOption = newOption
            
            model.settings[item.itemKey] = NSNumber(value: newOption)
            
            if item.itemType == .travelMode {
                
                model.refreshRangeSlider()
            }
        }
    }
    
    func updateTransportModeOnOption(newOption: Int) {
        
        if let mode = RangeTransportMode(rawValue: newOption) {
            
            model.refresh(mode: mode)
        }
    }
}

struct RangeValueRoutesItemView: View {
    
    @ObservedObject var model: RangeSettingsModel
    
    @ObservedObject var item: RangeValueRoutesItem
    
    var index: Int
    
    var onRangeDeleted: (_ item: RangeValueRoutesItem) -> Void
    
    var onRangeSelected: (_ item: RangeValueRoutesItem) -> Void
    
    var body: some View {
        
        Button() {
            
            item.isSelected.toggle()
            
            onRangeSelected(item)
            
        } label: {
            
            HStack(spacing: 0) {
                
                Image(systemName: getImageName(transportMode: item.transportMode))
                    .renderingMode(.template)
                    .foregroundColor(.primary)
                    .font(.system(size: 16))
                    .scaledToFit()
                    .padding(.leading, 10)
                
                Text(model.getValueStringWithUnit(value: item.rangeValue, unitType: item.rangeType))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color.primary)
                    .padding(.horizontal, 5)
                
                Divider()
                    .frame(height: 35)
                
                HStack(spacing: 0) {
                    
                    Button {
                        
                        onRangeDeleted(item)
                        
                        model.removePresentedRoutes(index: index)
                        
                    } label: {
                        
                        Image(systemName: "multiply")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 40)
            .background(RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemGroupedBackground)))
            .overlay(RoundedRectangle(cornerRadius: 20)
                .strokeBorder(item.isSelected ? Color(item.routeColor.withAlphaComponent(1.0)) : Color(uiColor: .tertiaryLabel),
                              lineWidth: item.isSelected ? 3 : 1))
            .contentShape(Rectangle())
        }
    }
    
    func getImageName(transportMode: RangeTransportMode) -> String {
        
        switch transportMode {
            
        case .car:
            return "car.fill"
            
        case .pedestrian:
            return "figure.walk"
            
        case .bicycle:
            return "bicycle"
            
        case .truck:
            if #available(iOS 16.0, *) {
                
                return "box.truck.fill"
            } else {
                
                return "bus.fill"
            }
        }
    }
}

struct TransportModeOptionView: View {
    
    @ObservedObject var model: RangeSettingsModel
    
    var didSelectTransportMode: () -> Void
    
    var body: some View {
        
        Button {
            
            didSelectTransportMode()
            
        } label: {
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Transport Mode")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color.primary)
                    
                    Text(getStringForTransportMode(model.mode))
                        .font(.system(size: 16, weight: .medium))
                        .italic()
                        .foregroundColor(.blue)
                }
                
                Spacer()
                Image(systemName: "info.circle")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(Color.blue)
                    .fixedSize()
                
            }
            .frame(minHeight: 50)
        }
    }
    
    func getStringForTransportMode(_ mode: RangeTransportMode) -> String {
        
        var string = ""
        
        switch mode {
            
        case .car:
            string = "Car"
            
        case .bicycle:
            string = "Bicycle"
            
        case .truck:
            string = "Truck"
            
        case .pedestrian:
            string = "Pedestrian"
        }
        
        return string
    }
}

struct RangeToggleItemView: View {
    
    @ObservedObject var model: RangeSettingsModel
    
    @Binding var item: RangeSettingsItem
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color.primary)
                
                if item.description.count > 0 {
                    Text(item.description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $item.toggleState)
                .fixedSize()
            
            Button("") {
                
                item.toggleState.toggle()
            }
            
        }
        .frame(minHeight: 50)
        .onChange(of: item.toggleState) { value in
            
            model.settings[item.itemKey] = NSNumber(value: value)
        }
    }
}

struct RangeOptionItemView: View {
    
    @ObservedObject var model: RangeSettingsModel
    
    @Binding var item: RangeSettingsItem
    
    var didSelectOptionItem: (_ item: RangeSettingsItem) -> Void
    
    var body: some View {
        
        Button {
            
            didSelectOptionItem(item)
            
        } label: {
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color.primary)
                    
                    Text(item.options[item.chosenOption])
                        .font(.system(size: 16, weight: .regular))
                        .italic()
                        .foregroundColor(Color.secondary)
                }
                
                Spacer()
                Image(systemName: "info.circle")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(Color.blue)
                    .fixedSize()
                
            }
            .frame(minHeight: 50)
        }
    }
}

struct RangeSliderItemView: View {
    
    @ObservedObject var model: RangeSettingsModel
    
    @Binding var item: RangeSettingsItem
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text(item.title)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color.secondary)
            
            VStack(spacing: 2) {
                HStack {
                    Text(getLeftTitle())
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(getCenterTitle())
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(getRightTitle())
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.primary)
                }
                
                Slider(
                    value: $item.sliderValue,
                    in: 0...item.sliderMaxValue,
                    step: 1,
                    onEditingChanged: { editing in
                        
                        if editing == false {
                            
                            model.settings[item.itemKey] = NSNumber(value: Int(item.sliderValue))
                        }
                    }
                )
            }
        }
        .padding(.vertical, 5)
    }
    
    func getLeftTitle() -> String {
        
        var string = ""
        
        if model.mode == .bicycle && item.itemKey == NavigationBikeSettingsKey.avoidHillsKey.rawValue {
            
            string = "Avoid Hills " + String(Int(item.sliderMinValue))
            
        } else {
            
            string = String(Int(item.sliderMinValue))
        }
        
        return string
    }
    
    func getCenterTitle() -> String {
        
        let string = String(Int(item.sliderValue))
        
        return string
    }
    
    func getRightTitle() -> String {
        
        var string = ""
        
        if model.mode == .bicycle && item.itemKey == NavigationBikeSettingsKey.avoidHillsKey.rawValue {
            
            string = "Allow Hills " + String(Int(item.sliderMaxValue))
            
        } else {
            
            string = String(Int(item.sliderMaxValue))
        }
        
        return string
    }
}

struct RangeValueSliderView: View {
    
    @ObservedObject var model: RangeSettingsModel
    var onRangeAdded: () -> Void
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {

            HStack {
                Text("Range Value")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color.secondary)
                
                Spacer()
                
                Button {
                    
                    if model.presentedRoutes.count < 10 {
                        
                        onRangeAdded()
                    }
                    
                } label: {
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 60, height: 40)
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack(spacing: 2) {
                HStack {
                    Text(model.rangeLeftLabel)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(model.getValueStringWithUnit(value: model.rangeValue, unitType: model.rangeType))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(model.rangeRightLabel)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.primary)
                }
                
                Slider(
                    value: $model.rangeValue,
                    in: model.minRangeValue...model.maxRangeValue,
                    step: model.rangeStep,
                    onEditingChanged: { editing in }
                )
            }
        }
        .padding(.vertical, 5)
    }
}

extension Color {
    
    static var randomRangeColor: Color {
        
        let r: Double = .random(in: 0...0.8)
        let g: Double = .random(in: 0...0.8)
        let b: Double = .random(in: 0...0.8)
        
        let color = Color(red: r, green: g, blue: b, opacity: 0.26)
        
        // ui_log("Color: randomRangeColor: red:%f, green:%f, blue:%f", r, g, b)
        
        return color
    }
}

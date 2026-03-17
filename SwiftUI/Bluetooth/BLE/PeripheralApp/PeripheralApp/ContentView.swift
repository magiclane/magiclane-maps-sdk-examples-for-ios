// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import SwiftUI
import GEMKit

struct ContentView: View {
    @ObservedObject var navModel: NavigationModel
    @ObservedObject var transModel: TransferDataModel
    @State private var zoom = 60
    @State private var isFollowButtonVisible = true
    @State private var isSimulationButtonVisible = true
    @State private var isStopNavigationButtonVisible = false
    @State private var mapMargin: CGFloat = 0
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            MapReader { proxy in
                ZStack {
                    MapBase()
                        .mapStyle(getStyleFollowingOS())
                        .mapSocialReports(false)
                        .mapSafety(false)
                        .mapTraffic(false)
                        .onFollowingPositionStateChanged { isFollowingPosition in
                            isFollowButtonVisible = !isFollowingPosition
                        }
                        .mapEdgeInsets(areaEdge(margin: mapMargin,  safeAreaInsets:geometry.safeAreaInsets))
                        .onAppear() {
                            flyToLocation(proxy)
                            setMapFollowPositionPreferences(proxy)
                            proxy.setPositionTracker(getPositionTrackerBuffer())
                            setPositionTrackerScale(proxy, 0.7)
                        }
                        .ignoresSafeArea()
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack(alignment: .bottom, content: {
                            if isFollowButtonVisible {
                                MapButtonView.init(type: .followPosition, isVisible: $isFollowButtonVisible) { type in
                                    startFollowingPosition(proxy)
                                }
                            }
                            Spacer()
                            if isSimulationButtonVisible {
                                MapButtonView.init(type: .simulation, isVisible: $isSimulationButtonVisible) { type in
                                    startSimulation(proxy)
                                }
                                .disabled(!transModel.isConnected)
                            }
                            else if isStopNavigationButtonVisible {
                                VStack {
                                    
                                    MapButtonView.init(type: .roadBlock, isVisible: $isStopNavigationButtonVisible) { type in
                                        setRoadBlock()
                                    }
                                    
                                    MapButtonView.init(type: .stopNavigation, isVisible: $isStopNavigationButtonVisible) { type in
                                        stopSimulation(proxy)
                                    }
                                    
                                }
                            }
                        })
                    }
                    
                    if navModel.isNavigationActive {
                        PanelView(navModel: navModel)
                    }
                    
//                    HStack{
//                        VStack{
//                            TransferPanel(transModel: transModel, type: .position)
//                            TransferPanel(transModel: transModel, type: .route)
//                            TransferPanel(transModel: transModel, type: .instruction)
//                            //TransferCompactPanel(transModel: transModel)
//                        }
//                        .padding(.leading, 10)
//                        Spacer()
//                    }
                }
                .onChange(of: scenePhase) { (phase) in
                    scenePhaseChanged(proxy, newPhase: phase)
                }
            }
        }
    }
    
    func getStyleFollowingOS() -> Int {
        return colorScheme == .dark ? MapStyleIdentifiers.night.rawValue : MapStyleIdentifiers.day.rawValue
    }
    
    func flyToLocation(_ proxy: MapProxy) {
        proxy.centerOn(coordinates: .basel, zoomLevel: 60)
    }
    
    func scenePhaseChanged(_ proxy: MapProxy, newPhase: ScenePhase) {
        if newPhase == .active {
            proxy.startRender()
        } else {
            proxy.stopRender()
        }
    }
    
    func startFollowingPosition(_ proxy: MapProxy) {
        let animation: Double = isSimulationActive() ? 1000 : 0
        startFollowingPosition2D(proxy, animation: animation)
    }
    
    func startFollowingPosition2D(_ proxy: MapProxy, animation: Double = 0, zoomLevel: Int = 80) {
        proxy.startFollowingPosition(duration: animation, zoomLevel: zoomLevel, viewAngle: 0) { finished in }
    }
    
    func startSimulation(_ proxy: MapProxy) {
        guard let mapViewController = proxy.mapViewController else { return }
        
        isSimulationButtonVisible = false
        
        AppManager.shared.startRouteSimulation { route in
            
            mapViewController.presentRoutes([route], withTraffic: nil, showSummary: false, animationDuration: 0)
            
            mapMargin = 0
            isStopNavigationButtonVisible = true
            startFollowingPosition(proxy)
        }
    }
    
    func stopSimulation(_ proxy: MapProxy) {
        guard let mapViewController = proxy.mapViewController else { return }
        
        mapViewController.removeAllRoutes()
        
        AppManager.shared.stopRouteSimulation()
        
        mapMargin = 0
        isSimulationButtonVisible = true
        isStopNavigationButtonVisible = false
    }
    
    func setRoadBlock() {
        
        AppManager.shared.setRoadBlock()
    }
    
    func isSimulationActive() -> Bool {
        
        return AppManager.shared.isSimulationActive()
    }
    
    func areaEdge(margin: CGFloat, safeAreaInsets: EdgeInsets) -> UIEdgeInsets {
        
        let scale = UIScreen.main.scale
        let insets = UIEdgeInsets.init(top: (safeAreaInsets.top + margin) * scale, left: margin * scale,
                                       bottom: (safeAreaInsets.bottom + margin) * scale, right: margin * scale)
        
        return insets
    }
    
    func setMapFollowPositionPreferences(_ proxy: MapProxy) {
        guard let mapViewController = proxy.mapViewController else { return }
        let followPositionPreferences = mapViewController.getPreferences().getFollowPositionPreferences()
        followPositionPreferences.setAccuracyCircleVisibility(true)
        followPositionPreferences.setTouchHandlerExitAllow(true)
    }
    
    func setPositionTrackerScale(_ proxy: MapProxy, _ scale: Double) {
        guard let mapViewController = proxy.mapViewController else { return }
        mapViewController.setPositionTrackerScaleFactor(scale)
    }
    
    func getPositionTrackerBuffer() -> Data {
        if let url = Bundle.main.url(forResource: "cylinder", withExtension: "glb") {
            if let data = NSData.init(contentsOf: url) as Data? {
                return data
            }
        }
        
        return Data()
    }
}

public struct PanelView: View {
    @ObservedObject var model: NavigationModel
    
    init(navModel: NavigationModel) {
        model = navModel
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack() {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.black)
                        .shadow(color: Color.gray, radius: 4.0, x: 3, y: 3)
                    HStack(alignment: .center) {
                        VStack {
                            Image(uiImage: model.turnImage)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                            //.border(Color.white.opacity(0.3))
                                .frame(width: 80, height: 80)
                            HStack(spacing: 0) {
                                Text(model.distance)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(Color.white)
                                Text(model.distanceUnit)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color.white)
                            }
                        }
                        .padding()
                        Text(model.instruction)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color.white)
                            .padding()
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 140)
                .padding(5)
                Spacer()
            }
        }
    }
}
//
//struct TransferPanel: View {
//    @ObservedObject var model: TransferDataModel
//    var bufferType: InfoType
//    
//    init(transModel: TransferDataModel, type: InfoType) {
//        model = transModel
//        bufferType = type
//    }
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 16, style: .continuous)
//                .fill(model.isConnected ? Color.green : Color.gray)
//            VStack(alignment: .center, spacing: 0) {
//                HStack(alignment: .center) {
//                    Image(systemName: getIconName())
//                        .renderingMode(.template)
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(model.isConnected ? .white : .white.opacity(0.5))
//                        .scaledToFit()
//                        .padding(.leading, 8)
//                    VStack(alignment: .leading) {
//                        Text(getText())
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(model.isConnected ? .white : .white.opacity(0.5))
//                        Text(model.bufferUnit)
//                            .font(.system(size: 12, weight: .light))
//                            .foregroundColor(model.isConnected ? .white : .white.opacity(0.5))
//                    }
//                    Spacer()
//                }
//            }
//        }
//        .shadow(color: .gray.opacity(0.5), radius: 4.0, x: 3, y: 3)
//        .frame(maxWidth: 95, maxHeight: 60)
//    }
//    
//    func getText() -> String {
//        switch bufferType {
//        case .position:    return model.bufferSize[0]
//        case .route:       return model.bufferSize[1]
//        case .instruction: return model.bufferSize[2]
//        default: return "unknown"
//        }
//    }
//    
//    func getIconName() -> String {
//        switch bufferType {
//        case .position:    return "mappin.circle"
//        case .route:       return "point.topleft.down.to.point.bottomright.curvepath"
//        case .instruction: return "arrow.turn.up.right"
//        default: return "unknown"
//        }
//    }
//}

struct TransferCompactPanel: View {
    @ObservedObject var model: TransferDataModel
    
    init(transModel: TransferDataModel) {
        model = transModel
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(model.isConnected ? Color.green : Color.gray)
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Spacer()
                    Text(getText(.eta))
                    Text(getText(.remainingTime))
                    Text(getText(.remainingDist))
                    Text(getText(.idTurn))
                    Spacer()
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(model.isConnected ? .white : .white.opacity(0.5))
                Text(model.bufferUnit)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(model.isConnected ? .white : .white.opacity(0.5))
                
            }
        }
        .shadow(color: .gray.opacity(0.5), radius: 4.0, x: 3, y: 3)
        .frame(maxWidth: 95, maxHeight: 60)
    }
    
    func getText(_ type: InfoType) -> String {
        switch type {
        case .eta:           return model.bufferSize[BufferSizeType.eta.rawValue]
        case .remainingDist: return model.bufferSize[BufferSizeType.remainingDist.rawValue]
        case .remainingTime: return model.bufferSize[BufferSizeType.remainingTime.rawValue]
        case .idTurn:        return model.bufferSize[BufferSizeType.idTurn.rawValue]
        default: return ""
        }
    }
}

#Preview {
    ContentView(navModel: NavigationModel.init(), transModel: TransferDataModel.init())
}

extension CoordinatesObject {
    static let basel =
    CoordinatesObject.coordinates(withLatitude: 47.538413, longitude: 7.600080)
}

enum MapButtonType: Int {
    case followPosition = 0, roadBlock, simulation, stopNavigation
}

struct MapButtonView: View {
    @State var type: MapButtonType
    @Binding var isVisible: Bool
    @State var onPressAction:(_ type: MapButtonType) -> Void
    
    var body: some View {
        Button {
            onPressAction(type)
        } label: {
            Image(systemName: getImageName())
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.accentColor)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(Color(.systemBackground))
                        .shadow(color: .gray.opacity(0.5), radius: 4.0, x: 3, y: 3)
                )
                .padding(8)
        }
        .buttonStyle(.plain)
        .opacity(isVisible ? 1 : 0)
    }
    
    func getImageName() -> String {
        switch type {
        case .followPosition:
            return "location.fill"
        case .simulation:
            return "point.topleft.down.to.point.bottomright.curvepath"
        case .stopNavigation:
            return "xmark.circle"
        case .roadBlock:
            return "hand.raised.fill"
        }
    }
}

class NavigationModel: ObservableObject {
    @Published var isNavigationActive: Bool = false
    @Published var turnImage: UIImage = UIImage.init()
    @Published var distance: String = ""
    @Published var distanceUnit: String = ""
    @Published var instruction: String = ""
    
    init() {
    }
    
    func clean() {
        self.isNavigationActive = false
        self.turnImage = UIImage.init()
        self.distance = ""
        self.distanceUnit = ""
        self.instruction = ""
    }
}

enum BufferSizeType: Int {
    case instructionDetails
    case turnDistance
    case idTurn
    case eta
    case remainingTime
    case remainingDist
    case cleanup
}

class TransferDataModel: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var bufferSize: [String] = ["0", "0", "0",
                                           "0", "0", "0", "0"]
    var bufferType: InfoType = .idTurn
    var bufferUnit: String = "bytes"
    
    init() {
    }
    
    func clean() {
        self.bufferSize = ["0", "0", "0",
                           "0", "0", "0", "0"]
    }
}

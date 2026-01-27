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
    @ObservedObject var transModel: TransferDataModel
    @State private var zoom = 60
    @State private var isFollowButtonVisible = true
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        
        VStack() {
            
            if transModel.isInfoReady {
                
                if transModel.turnImage != nil {
                    TurnImagePanel(image: transModel.turnImage!, turnDistance: transModel.turnDistance, instructionDetails: transModel.instructionDetails)
                }
                
                Spacer()
                
                TimeInfoView(transModel: transModel)
                
            } else {
                
                Text("Start a route")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.secondarySystemBackground))
    }
}

enum MapButtonType: Int {
    case followPosition = 0, settings, simulation, stopNavigation
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
        case .settings:
            return "gearshape.fill"
        case .simulation:
            return "point.topleft.down.to.point.bottomright.curvepath"
        case .stopNavigation:
            return "xmark.circle"
        }
    }
}

struct TurnImagePanel: View {
    var image: UIImage
    var turnDistance: String
    var instructionDetails: String
    
    init(image: UIImage, turnDistance: String, instructionDetails: String) {
        self.image = image
        self.turnDistance = turnDistance
        self.instructionDetails = instructionDetails
    }
    
    var body: some View {
        
        VStack {
            Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
                .frame(width: 150, height: 150)
                .scaledToFit()
                .padding(15)
                .background(RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground)).shadow(color: .gray.opacity(0.5), radius: 3, x: 0.8, y: 1.5))
                .padding(10)
            
            VStack {
                
                Text(turnDistance)
                    .font(.system(size: 28, weight: .semibold))
                
                Text(instructionDetails)
                    .font(.system(size: 24, weight: .medium))
            }
        }
    }
}

struct TimeInfoView: View {
    
    @ObservedObject var model: TransferDataModel
    
    init(transModel: TransferDataModel) {
        model = transModel
    }
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            Text(model.eta)
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.leading, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(model.remainingTime)
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(model.remainingDist)
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.trailing, 15)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground)).shadow(color: .gray.opacity(0.5), radius: 3, x: 0.8, y: 1.5))
        .padding([.horizontal, .bottom], 10)
    }
}

#Preview {
    ContentView(transModel: TransferDataModel.init())
}

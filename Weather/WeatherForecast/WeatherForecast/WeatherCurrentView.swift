// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import SwiftUI

class WeatherCurrentModel: ObservableObject {
    
    let id: String = UUID().uuidString
    
    var image: UIImage?
    var description: String = ""
    
    var temperature: String = ""
    var feelsLikeTemp: String = ""
    
    var localTime: String = ""
    var updatedAtTime: String = ""
    
    var parameters: [WeatherCurrentParameterItem] = []
}

struct WeatherCurrentParameterItem: Identifiable {
    
    let id: String = UUID().uuidString
    
    var name: String = ""
    var value: String = ""
}

struct WeatherCurrentView: View {
    
    @ObservedObject var model: WeatherCurrentModel
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                if let image = model.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
                
                Text(model.description)
                    .font(.system(size: 24))
                    .multilineTextAlignment(.leading)
                
                Text(model.temperature)
                    .font(.system(size: 27, weight: .bold))
                    .padding(.vertical, 8)
                
                Text(model.feelsLikeTemp)
                    .font(.system(size: 18, weight: .bold))
                
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                
                HStack {
                    
                    Text("Local time:")
                        .font(.system(size: 15, weight: .medium))
                        .multilineTextAlignment(.leading)
                    
                    Text(model.localTime)
                        .font(.system(size: 15, weight: .bold))
                        .multilineTextAlignment(.leading)
                }
                
                HStack {
                    
                    Text("Updated at:")
                        .font(.system(size: 15, weight: .medium))
                        .multilineTextAlignment(.trailing)
                    
                    Text(model.updatedAtTime)
                        .font(.system(size: 15, weight: .bold))
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(15)
        
        Spacer()
        
        List {
            
            ForEach(model.parameters) { parameter in
                
                HStack {
                    
                    Text(parameter.name)
                        .font(.system(size: 20, weight: .medium))
                    
                    Spacer()
                    
                    Text(parameter.value)
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
    }
}

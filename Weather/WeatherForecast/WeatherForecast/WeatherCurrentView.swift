// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

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

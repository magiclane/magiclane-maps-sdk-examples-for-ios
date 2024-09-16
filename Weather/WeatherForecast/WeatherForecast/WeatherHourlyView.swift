// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import SwiftUI

class WeatherHourlyModel: ObservableObject {
    
    @Published var items: [WeatherHourlyItem] = []
}

struct WeatherHourlyItem: Identifiable {
    
    let id: String = UUID().uuidString
    
    var image: UIImage?
    
    var time: String = ""
    
    var temperature: String = ""
}

struct WeatherHourlyView: View {
    
    @ObservedObject var model: WeatherHourlyModel
    
    var body: some View {
        
        List {
            
            ForEach(model.items) { item in
                
                HStack {
                    
                    Text(item.time)
                        .font(.system(size: 18, weight: .bold))
                    
                    Spacer()
                    
                    if let image = item.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    Text(item.temperature)
                        .font(.system(size: 18, weight: .bold))
                }
            }
        }
        .listStyle(.plain)
    }
}

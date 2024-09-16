// Copyright (C) 2019-2024, Magic Lane B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of Magic Lane
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with Magic Lane.

import SwiftUI

class WeatherDailyModel: ObservableObject {
    
    @Published var items: [WeatherDailyItem] = []
}

struct WeatherDailyItem: Identifiable {
    
    let id: String = UUID().uuidString
    
    var image: UIImage?
    
    var temperatureHigh: String = ""
    var temperatureLow: String = ""
    
    var date: String = ""
}

struct WeatherDailyView: View {
    
    @ObservedObject var model: WeatherDailyModel
    
    var body: some View {
        
        List {
            
            ForEach(model.items) { item in
                
                HStack {
                    
                    Text(item.date)
                        .font(.system(size: 16, weight: .regular))
                    
                    Spacer()
                    
                    if let image = item.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(item.temperatureHigh)
                            .font(.system(size: 17, weight: .bold))
                        
                        Text("/")
                            .font(.system(size: 17, weight: .regular))
                        
                        Text(item.temperatureLow)
                            .font(.system(size: 17, weight: .regular))
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

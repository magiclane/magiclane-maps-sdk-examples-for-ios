// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

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

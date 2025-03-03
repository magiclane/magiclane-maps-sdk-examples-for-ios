// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: BSD-3-Clause
//
// Contact Magic Lane at <info@magiclane.com> for commercial licensing options.

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

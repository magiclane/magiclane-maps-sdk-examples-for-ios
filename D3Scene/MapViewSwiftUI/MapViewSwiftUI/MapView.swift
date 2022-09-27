// Copyright (C) 2019-2022, General Magic B.V.
// All rights reserved.
//
// This software is confidential and proprietary information of General Magic
// ("Confidential Information"). You shall not disclose such Confidential
// Information and shall use it only in accordance with the terms of the
// license agreement you entered into with General Magic.

import SwiftUI
import GEMKit

struct MapRepresentable: UIViewControllerRepresentable {
    
    let mapViewController = MapViewController.init()
    
    typealias UIViewControllerType = MapViewController
    
    func makeUIViewController(context: Context) -> MapViewController {
        return mapViewController
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
    }
    
    public static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Self.Coordinator) {
    }
}

struct MapView: View {
    var mapRepresentable = MapRepresentable()
    
    var body: some View {
        VStack {
            mapRepresentable
                .ignoresSafeArea()
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .previewDevice("iPhone 12")
    }
}

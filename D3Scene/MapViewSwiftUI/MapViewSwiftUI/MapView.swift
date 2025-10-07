// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

extension Notification.Name {
    
    static let FollowingPositionChanged = Notification.Name("FollowingPositionChanged")
}

struct MapRepresentable: UIViewControllerRepresentable {
    
    let mapViewController = MapViewController.init()
    
    typealias UIViewControllerType = MapViewController
    
    func makeUIViewController(context: Context) -> MapViewController {
        
        mapViewController.delegate = context.coordinator
        
        return mapViewController
    }
    
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        
    }
    
    public static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Self.Coordinator) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MapViewControllerDelegate {
        
        var parent: MapRepresentable
        
        init(_ parent: MapRepresentable) {
            
            self.parent = parent
        }
        
        // MARK: - MapViewControllerDelegate
        
        func mapViewController(_ mapViewController: MapViewController, onFollowingPositionStateChanged isFollowingPosition: Bool) {
            
            NotificationCenter.default.post(name: .FollowingPositionChanged, object: isFollowingPosition)
        }
    }
}

struct MapView: View {

    var mapRepresentable: MapRepresentable = MapRepresentable()
    
    var body: some View {
        
        VStack {
            mapRepresentable
                .ignoresSafeArea()
        }
    }
}

struct MapFollowPositionModifier: ViewModifier {
    
    let action: (Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.FollowingPositionChanged)) { value in
                
                if let bool = value.object as? Bool {
                    
                    action(bool)
                }
            }
    }
}

extension View {
    
    func onFollowingPosition(perform action: @escaping (Bool) -> Void) -> some View {
        
        self.modifier(MapFollowPositionModifier(action: action))
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .previewDevice("iPhone 12")
    }
}

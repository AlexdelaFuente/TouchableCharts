//
//  ChartLineViewModel.swift
//  
//
//  Created by Alex de la Fuente Martín on 7/8/24.
//

import SwiftUI


@available(iOS 13.0, *)
public class ChartLineViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var data: [(String, Double, Bool)] = []
    
    private var isAnimated: Bool = true
    
    public init(data: [(String, Double, Bool)]) {
        self.data = data
    }
    
    
    public func changeData(_ data: [(String, Double, Bool)], animated: Bool = true) {
        isAnimated = animated
        withAnimation {
            self.data = data
        }
    }
    
    
    
}

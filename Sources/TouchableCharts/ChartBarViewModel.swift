//
//  ChartBarViewModel.swift
//
//
//  Created by Alex de la Fuente Martín on 7/8/24.
//

import SwiftUI

@available(iOS 13.0, *)
public class ChartBarViewModel: ObservableObject {
    @Published public var selectedIndex: Int = 0
    @Published public var data: [(Date, Double)] = []
    
    public init() {}
    
    
    public func selectIndex(_ index: Int) {
        guard index >= 0 && index < data.count else { return }
        
        withAnimation {
            self.selectedIndex = index
        }
    }
    
}

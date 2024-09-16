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
    
    @Published public var animatedIndexes: Set<Int> = []
    
    public init(data: [(Date, Double)]) {
        self.data = data
    }
    
    
    public func selectIndex(_ index: Int) {
        guard index >= 0 && index < data.count else { return }
        
        withAnimation {
            self.selectedIndex = index
        }
    }
    
    
    public func changeData(_ data: [(Date, Double)]) {
        
        for i in 0..<data.count {
            self.animatedIndexes.insert(i)
        }
        
        withAnimation {
            self.data = data
        }
        
    }
    
}

//
//  ChartLineViewModel.swift
//  
//
//  Created by Alex de la Fuente Martín on 7/8/24.
//

import SwiftUI


@available(iOS 16.0, *)
public class ChartLineViewModel: ObservableObject {
     
    @Published var selectedIndex: Int = 0
    @Published var data: [(String, Double, Bool)] = []
    
    
    public init(data: [(String, Double, Bool)], selectedIndex: Int = 0) {
        self.data = data
        self.selectedIndex = selectedIndex
    }
    
    
    public func changeData(_ data: [(String, Double, Bool)]) {
        withAnimation {
            self.data = data
        }
    }
    
    
    public func selectIndex(_ index: Int) {
        guard index >= 0 && index < data.count else { return }
        
        withAnimation {
            self.selectedIndex = index
        }
    }
}

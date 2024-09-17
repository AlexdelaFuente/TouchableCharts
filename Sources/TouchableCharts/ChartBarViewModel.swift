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
    
    @Published public var data: [(String, Double)] = [] {
        didSet {
            updateAnimatedIndexes()
        }
    }
    
    @Published public var animatedIndexes: Set<Int> = []
    
    private var isAnimated = true
    
    
    public init(data: [(String, Double)], selectedIndex: Int = 0) {
        self.data = data
        self.selectedIndex = selectedIndex
        self.animatedIndexes.removeAll() // First launch
    }
    
    
    public func selectIndex(_ index: Int) {
        guard index >= 0 && index < data.count else { return }
        
        withAnimation {
            self.selectedIndex = index
        }
    }
    
    
    public func changeData(_ data: [(String, Double)], animated: Bool = true) {
        isAnimated = animated
        withAnimation {
            self.data = data
        }
    }
    
    
    private func updateAnimatedIndexes() {
        let newIndexes = Set(0..<data.count)
        if isAnimated {
            withAnimation {
                self.animatedIndexes = newIndexes
            }
        } else {
            self.animatedIndexes = newIndexes
        }
        
    }
}

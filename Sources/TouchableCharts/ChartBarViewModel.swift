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
    
    @Published public var data: [(Date, Double)] = [] {
        didSet {
            updateAnimatedIndexes()
        }
    }
    
    @Published public var animatedIndexes: Set<Int> = []
    
    public init(data: [(Date, Double)]) {
        self.data = data
        self.updateAnimatedIndexes()
    }
    
    public func selectIndex(_ index: Int) {
        guard index >= 0 && index < data.count else { return }
        
        withAnimation {
            self.selectedIndex = index
        }
    }
    
    public func changeData(_ data: [(Date, Double)], animated: Bool = true) {
        if animated {
            withAnimation {
                self.data = data
            }
        } else {
            self.data = data
        }
        
    }
    
    private func updateAnimatedIndexes() {
        let newIndexes = Set(0..<data.count)
        
        withAnimation {
            self.animatedIndexes = newIndexes
        }
    }
    
    
    
}

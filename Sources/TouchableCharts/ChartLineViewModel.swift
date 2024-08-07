//
//  ChartLineViewModel.swift
//  
//
//  Created by Alex de la Fuente Martín on 7/8/24.
//

import Foundation


@available(iOS 13.0, *)
public class ChartLineViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    
    public init() {}
}

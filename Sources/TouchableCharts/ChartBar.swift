//
//  ChartBar.swift
//
//
//  Created by Alex de la Fuente Martín on 7/8/24.
//

import SwiftUI

/// A view that displays a horizontal bar chart.
///
/// `ChartBar` provides a customizable bar chart for displaying data over time. You can customize the colors,
/// spacing, and other attributes of the bars.
///
/// - Parameters:
///   - viewModel: The view model managing the state of the bar chart.
///   - barSpacing: The spacing between bars. Default is 20.
///   - barWidth: The width of each bar. Default is 30.
///   - barColor: The color of the bars. Default is gray.
///   - selectedBarColor: The color of the selected bar. Default is accent color.
///   - textColor: The color of the text labels. Default is black.
///   - selectedTextColor: The color of the selected text label. Default is accent color.


@available(iOS 15.0, *)
public struct ChartBar: View {
    
    @ObservedObject var viewModel: ChartBarViewModel
    
    private let minBarHeight: CGFloat = 30
    
    // Parámetros personalizables
    var barSpacing: CGFloat = 20
    var barWidth: CGFloat = 30
    var barColor: Color = .gray
    var selectedBarColor: Color = .accentColor
    var textColor: Color = .black
    var selectedTextColor: Color = .accentColor
    
    var areBarsAnimated: Bool = true
    
    public init(viewModel: ChartBarViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    GeometryReader { geometry in
                        let height = geometry.size.height * (0.90 + calculateNumber(from: geometry.size.height))
                        let availableHeight = height * (0.90)
                        let _ = print(height)
                        let _ = print(".")
                        let _ = print(availableHeight)
                        HStack(alignment: .bottom, spacing: barSpacing) {
                            ForEach(0..<viewModel.data.count, id: \.self) { index in
                                let item = viewModel.data[index]
                                let maxDataValue = viewModel.data.map { $0.1 }.max() ?? 1
                                let barHeight = CGFloat(item.1 / maxDataValue) * availableHeight
                                
                                let adjustedBarHeight = max(barHeight, minBarHeight)
                                
                                VStack {
                                    
                                    ZStack(alignment: .bottom) {
                                        
                                        
                                        ZStack(alignment: .center) {
                                            Capsule()
                                                .fill(viewModel.selectedIndex == index ? selectedBarColor.opacity(0.2) : barColor.opacity(0.2))
                                                .frame(width: barWidth, height: viewModel.animatedIndexes.contains(index) ? availableHeight : 0)
                                                .overlay {
                                                    Capsule()
                                                        .stroke(viewModel.selectedIndex == index ? selectedBarColor : barColor, lineWidth: 0.4)
                                                }
                                            
                                            let lineSpacing: CGFloat = 6
                                            let lineWidth: CGFloat = 1
                                            
                                            Path { path in
                                                var currentX: CGFloat = 0
                                                
                                                while currentX < 30 + availableHeight {
                                                    path.move(to: CGPoint(x: currentX, y: 0))
                                                    path.addLine(to: CGPoint(x: currentX - availableHeight, y: availableHeight))
                                                    currentX += lineSpacing
                                                }
                                            }
                                            .stroke(viewModel.selectedIndex == index ? selectedBarColor.opacity(0.6) : barColor.opacity(0.6), lineWidth: lineWidth)
                                            .frame(width: barWidth, height: viewModel.animatedIndexes.contains(index) ? availableHeight : 0)
                                            .mask {
                                                Capsule()
                                            }
                                        }
                                        
                                        Capsule()
                                            .fill(item.1 == 0.0 ? Color.clear : (viewModel.selectedIndex == index ? selectedBarColor : barColor))
                                            .frame(width: barWidth, height: viewModel.animatedIndexes.contains(index) ? adjustedBarHeight : 0)
                                            .overlay(
                                                Capsule()
                                                    .stroke(viewModel.selectedIndex == index ? selectedBarColor : barColor, lineWidth: 3)
                                            )
                                    }
                                    Text(item.0)
                                        .font(.system(size: 12))
                                        .fontWeight(viewModel.selectedIndex == index ? .heavy : .medium)
                                        .foregroundColor(viewModel.selectedIndex == index ? selectedTextColor : textColor)
                                        .frame(width: barWidth)
                                        .padding(.top, 4)
                                }
                                .frame(height: height, alignment: .bottom)
                                .id(index)
                                .onTapGesture {
                                    if viewModel.selectedIndex != index {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            viewModel.selectedIndex = index
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12).padding(.top)
                    }
                }.onAppear {
                    scrollViewProxy.scrollTo(viewModel.data.count - 1, anchor: .trailing)
                    animateBarsSequentially()
                }.padding()
            }
        }
    }
    
    
    
    
    
    private func animateBarsSequentially() {
        if areBarsAnimated {
            print("animatebars")
            for index in 0..<viewModel.data.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    let _ = withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.animatedIndexes.insert(index)
                    }
                }
            }
        }
    }
    
    
    private func calculateNumber(from numero: Double) -> Double {
        let minNumero: Double = 150
        let maxNumero: Double = 750
        
        let minSalida: Double = -0.05
        let maxSalida: Double = 0.05
        
        let numeroClamped = min(max(numero, minNumero), maxNumero)
        
        let resultado = minSalida + (numeroClamped - minNumero) * (maxSalida - minSalida) / (maxNumero - minNumero)
        
        return resultado
    }
    
    
}

// MARK: - ChartBar Modifiers
@available(iOS 15.0, *)
extension ChartBar {
    
    public func barSpacing(_ spacing: CGFloat) -> some View {
        var copy = self
        copy.barSpacing = spacing
        return copy
    }
    
    
    public func barWidth(_ width: CGFloat) -> some View {
        var copy = self
        copy.barWidth = width
        return copy
    }
    
    
    public func barColor(_ color: Color) -> some View {
        var copy = self
        copy.barColor = color
        return copy
    }
    
    
    public func selectedBarColor(_ color: Color) -> some View {
        var copy = self
        copy.selectedBarColor = color
        return copy
    }
    
    
    public func textColor(_ color: Color) -> some View {
        var copy = self
        copy.textColor = color
        return copy
    }
    
    
    public func selectedTextColor(_ color: Color) -> some View {
        var copy = self
        copy.selectedTextColor = color
        return copy
    }
    
    
    public func setBarAnimation(_ bool: Bool) -> some View {
        var copy = self
        copy.areBarsAnimated = bool
        return copy
    }
}

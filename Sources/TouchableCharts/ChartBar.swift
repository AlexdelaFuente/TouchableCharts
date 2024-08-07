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
///   - data: The data to be displayed, with each entry containing a date and a value.
///   - barSpacing: The spacing between bars. Default is 20.
///   - barWidth: The width of each bar. Default is 30.
///   - barColor: The color of the bars. Default is gray.
///   - selectedBarColor: The color of the selected bar. Default is accent color.
///   - textColor: The color of the text labels. Default is black.
///   - selectedTextColor: The color of the selected text label. Default is accent color.


@available(iOS 14.0, *)
public struct ChartBar: View {
    
    @ObservedObject var viewModel: ChartBarViewModel
    var data: [(Date, Double)]
    
    @State private var animatedIndexes: Set<Int> = []
    
    private let minBarHeight: CGFloat = 30
    
    // Parámetros personalizables
    var barSpacing: CGFloat
    var barWidth: CGFloat
    var barColor: Color
    var selectedBarColor: Color
    var textColor: Color
    var selectedTextColor: Color
    
    public init(viewModel: ChartBarViewModel,
                data: [(Date, Double)],
                barSpacing: CGFloat = 20,
                barWidth: CGFloat = 30,
                barColor: Color = .gray,
                selectedBarColor: Color = .accentColor,
                textColor: Color = .black,
                selectedTextColor: Color = .accentColor) {
        self.viewModel = viewModel
        self.data = data
        self.barSpacing = barSpacing
        self.barWidth = barWidth
        self.barColor = barColor
        self.selectedBarColor = selectedBarColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
    }
    
    public var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: barSpacing) {
                        ForEach(0..<data.count, id: \.self) { index in
                            let item = data[index]
                            let maxDataValue = data.map { $0.1 }.max() ?? 1
                            let barHeight = CGFloat(item.1 / maxDataValue) * 170
                            
                            let adjustedBarHeight = max(barHeight, minBarHeight)
                            
                            VStack {
                                Capsule()
                                    .fill(item.1 == 0.0 ? Color.clear : (viewModel.selectedIndex == index ? selectedBarColor : barColor))
                                    .frame(width: barWidth, height: animatedIndexes.contains(index) ? adjustedBarHeight : 0)
                                    .overlay(
                                        Capsule()
                                            .stroke(viewModel.selectedIndex == index ? selectedBarColor : barColor, lineWidth: 3)
                                    )
                                    
                                Text(formattedMonth(from: item.0))
                                    .font(.system(size: 12))
                                    .fontWeight(viewModel.selectedIndex == index ? .heavy : .medium)
                                    .foregroundColor(viewModel.selectedIndex == index ? selectedTextColor : textColor)
                                    .frame(width: barWidth)
                                    .padding(.top, 4)
                            }
                            .frame(height: 200, alignment: .bottom)
                            .id(index)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    viewModel.selectedIndex = index
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12).padding(.top)
                    
                }.onAppear {
                    scrollViewProxy.scrollTo(data.count - 1, anchor: .trailing)
                    animateBarsSequentially()
                }.padding()
            }
        }
    }
    
    func formattedMonth(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: date)
    }
    
    private func animateBarsSequentially() {
        for index in 0..<data.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                let _ = withAnimation(.easeInOut(duration: 0.5)) {
                    animatedIndexes.insert(index)
                }
            }
        }
    }
}



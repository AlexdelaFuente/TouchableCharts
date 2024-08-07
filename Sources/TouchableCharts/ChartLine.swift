//
//  ChartLine.swift
//
//
//  Created by Alex de la Fuente Martín on 7/8/24.
//

import SwiftUI

@available(iOS 14.0, *)
public struct ChartLine: View {
    
    @ObservedObject var viewModel: ChartLineViewModel
    var data: [(Date, Double, Bool)]
    
    @State private var animatedPoints: Bool = false
    @State private var animatedLines: Bool = false
    
    private let lineWidth: CGFloat = 3
    private let minChartHeight: CGFloat = 80
    private let maxChartHeight: CGFloat = 160
    
    // Customizable parameters
    var pointDiameter: CGFloat
    var selectedPointDiameter: CGFloat
    var lineColor: Color
    var pointColor: Color
    var selectedPointColor: Color
    var textColor: Color
    var selectedTextColor: Color
    
    public init(viewModel: ChartLineViewModel,
                data: [(Date, Double, Bool)],
                pointDiameter: CGFloat = 12,
                selectedPointDiameter: CGFloat = 18,
                lineColor: Color = .green,
                pointColor: Color = .gray,
                selectedPointColor: Color = .accentColor,
                textColor: Color = .black,
                selectedTextColor: Color = .accentColor) {
        self.viewModel = viewModel
        self.data = data
        self.pointDiameter = pointDiameter
        self.selectedPointDiameter = selectedPointDiameter
        self.lineColor = lineColor
        self.pointColor = pointColor
        self.selectedPointColor = selectedPointColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
    }
    
    public var body: some View {
        VStack {
            ZStack {
                VStack {
                    GeometryReader { geometry in
                        let frame = geometry.frame(in: .local)
                        let maxDataValue = data.map { $0.1 }.max() ?? 1
                        let minDataValue = data.map { $0.1 }.min() ?? 0
                        let valueRange = maxDataValue - minDataValue
                        
                        let dataRange = maxDataValue - minDataValue

                        var step: Double
                        if dataRange <= 50 {
                            step = 10.0
                        } else if dataRange <= 100 {
                            step = 20.0
                        } else if dataRange <= 500 {
                            step = 50.0
                        } else if dataRange <= 1000 {
                            step = 100.0
                        } else if dataRange <= 2000 {
                            step = 200.0
                        } else {
                            step = 500.0
                        }

                        let start = floor(minDataValue / step) * step
                        let end = ceil(maxDataValue / step) * step
                        var points = stride(from: start, through: end, by: step).map { $0 }
                        
                        if maxDataValue < 50 && minDataValue > -50 {
                            points = []
                            points.append(maxDataValue)
                            points.append(0)
                            if maxDataValue >= 25 {
                                points.append((maxDataValue * 0.75).rounded())
                                points.append((maxDataValue * 0.5).rounded())
                                points.append((maxDataValue * 0.25).rounded())
                            } else if maxDataValue >= 15 {
                                points.append((maxDataValue / 2).rounded())
                            } else if maxDataValue < 15 {
                                points.append((maxDataValue * 0.5).rounded())
                                points.append((maxDataValue * 0.25).rounded())
                            }
                            if minDataValue < 0 {
                                points.append(minDataValue)
                                if minDataValue < -25 {
                                    points.append((minDataValue * 0.75).rounded())
                                    points.append((minDataValue * 0.5).rounded())
                                    points.append((minDataValue * 0.25).rounded())
                                } else if minDataValue < -15 {
                                    points.append((minDataValue * 0.66).rounded())
                                    points.append((minDataValue * 0.33).rounded())
                                } else if minDataValue > -15 {
                                    points.append((minDataValue / 2).rounded())
                                }
                            }
                        }
                        
                        if minDataValue < 0 {
                            points.sort()
                            points.removeFirst()
                        }
                        
                        if abs(minDataValue) < (step / 2.5) {
                            points = points.filter { $0 != minDataValue }
                            points.append(0)
                        } else {
                            points = points.filter { $0 != minDataValue }
                            points.append(minDataValue)
                        }
                        
                        ForEach(points, id: \.self) { point in
                            let yPosition = frame.height - (frame.height * CGFloat((point - minDataValue) / valueRange))
                            
                            Path { path in
                                path.move(to: CGPoint(x: 16, y: yPosition))
                                path.addLine(to: CGPoint(x: frame.width, y: yPosition))
                            }.stroke(Color.gray, style: point == 0 ? StrokeStyle(lineWidth: 1) : StrokeStyle(lineWidth: 0.5, dash: [3]))
                            
                            Text("\(point.formatted()) \(User.shared.currency.symbol)")
                                .font(.system(size: 12))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .position(x: -150, y: yPosition)
                        }
                    }
                    .frame(height: maxChartHeight)
                }
                .padding(.leading, 32)
                
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            GeometryReader { geometry in
                                let frame = geometry.frame(in: .local)
                                let maxDataValue = data.map { $0.1 }.max() ?? 1
                                let minDataValue = data.map { $0.1 }.min() ?? 0
                                let valueRange = maxDataValue - minDataValue
                                
                                ZStack {
                                    Path { path in
                                        var previousPoint: CGPoint?
                                        
                                        for index in data.indices {
                                            let point = data[index]
                                            let xPosition = frame.width * CGFloat(index) / CGFloat(data.count - 1)
                                            let yPosition = frame.height - (frame.height * CGFloat((point.1 - minDataValue) / valueRange))
                                            
                                            let currentPoint = CGPoint(x: xPosition, y: yPosition)
                                            
                                            if let previous = previousPoint {
                                                let controlPoint1 = CGPoint(x: (previous.x + currentPoint.x) / 2, y: previous.y)
                                                let controlPoint2 = CGPoint(x: (previous.x + currentPoint.x) / 2, y: currentPoint.y)
                                                path.addCurve(to: currentPoint, control1: controlPoint1, control2: controlPoint2)
                                            } else {
                                                path.move(to: currentPoint)
                                            }
                                            
                                            previousPoint = currentPoint
                                        }
                                    }
                                    .trim(from: 0, to: animatedLines ? 1 : 0)
                                    .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                    .animation(.easeInOut(duration: Double(data.count) * 0.2), value: animatedLines)
                                    
                                    ForEach(data.indices, id: \.self) { index in
                                        let point = data[index]
                                        let xPosition = frame.width * CGFloat(index) / CGFloat(data.count - 1)
                                        let yPosition = frame.height - (frame.height * CGFloat((point.1 - minDataValue) / valueRange))
                                        
                                        Group {
                                            if !point.2 {
                                                Circle()
                                                    .stroke(index == viewModel.selectedIndex ? selectedPointColor : pointColor, lineWidth: 3)
                                                    .background(Circle().fill(Color.clear))
                                                    .frame(width: index == viewModel.selectedIndex ? selectedPointDiameter : pointDiameter, height: index == viewModel.selectedIndex ? selectedPointDiameter : pointDiameter)
                                                    .position(x: xPosition, y: yPosition)
                                                    .scaleEffect(animatedPoints ? 1 : 0.0)
                                                    .animation(.snappy.delay(Double(index) * 0.1), value: animatedPoints)
                                            } else {
                                                Circle()
                                                    .fill(index == viewModel.selectedIndex ? selectedPointColor : pointColor)
                                                    .frame(width: index == viewModel.selectedIndex ? selectedPointDiameter : pointDiameter, height: index == viewModel.selectedIndex ? selectedPointDiameter : pointDiameter)
                                                    .position(x: xPosition, y: yPosition)
                                                    .scaleEffect(animatedPoints ? 1 : 0.0)
                                                    .animation(.snappy.delay(Double(index) * 0.1), value: animatedPoints)
                                            }
                                            
                                            Text(formattedMonth(from: point.0))
                                                .font(.system(size: 14))
                                                .fontWeight(index == viewModel.selectedIndex ? .heavy : .medium)
                                                .foregroundColor(index == viewModel.selectedIndex ? selectedTextColor : textColor)
                                                .position(x: xPosition, y: frame.height + 20)
                                        }.onTapGesture {
                                            withAnimation(.easeInOut) {
                                                viewModel.selectedIndex = index
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(height: maxChartHeight)
                            .padding(.leading, 8)
                        }
                        .padding(.vertical, 28)
                        .frame(minWidth: CGFloat(data.count) * 50)
                        .padding(.leading, 8)
                        .padding(.trailing, 16)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(data.count) * 0.08) {
                                withAnimation {
                                    scrollProxy.scrollTo(data.count - 1, anchor: .trailing)
                                }
                            }
                            animatedPoints = true
                            animatedLines = true
                        }
                    }.padding(.leading, 48)
                }
            }
        }
        .padding()
    }
    
    
    func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: date)
    }
    
    
    func formattedMonth(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: date)
    }
}

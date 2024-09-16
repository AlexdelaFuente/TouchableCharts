//
//  ChartLine.swift
//
//
//  Created by Alex de la Fuente Martín on 7/8/24.
//

/*
 var pointDiameter: CGFloat
 var selectedPointDiameter: CGFloat
 var lineColor: Color
 var pointColor: Color
 var selectedPointColor: Color
 var textColor: Color
 var selectedTextColor: Color
 */

import SwiftUI

@available(iOS 16.0, *)
public struct ChartLine: View {
    
    @ObservedObject var viewModel: ChartLineViewModel
    
    
    @State private var animatedPoints: Bool = false
    @State private var animatedLines: Bool = false
    
    private let maxChartHeight: CGFloat = 160
    
    var lineWidth: CGFloat
    var pointDiameter: CGFloat
    var selectedPointDiameter: CGFloat
    var gridColor: Color
    var lineColor: Color
    var pointColor: Color
    var selectedPointColor: Color
    var textColor: Color
    var selectedTextColor: Color
    
    
    init(viewModel: ChartLineViewModel, lineWidth: CGFloat = 3, pointDiameter: CGFloat = 12, selectedPointDiameter: CGFloat = 18, gridColor: Color = .gray, lineColor: Color = .accentColor, pointColor: Color = .gray, selectedPointColor: Color = .blue, textColor: Color = .black, selectedTextColor: Color = .blue) {
        self.viewModel = viewModel
        self.lineWidth = lineWidth
        self.pointDiameter = pointDiameter
        self.selectedPointDiameter = selectedPointDiameter
        self.gridColor = gridColor
        self.lineColor = lineColor
        self.pointColor = pointColor
        self.selectedPointColor = selectedPointColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
    }
    
    
    // Computed properties
    private var maxDataValue: Double {
        viewModel.data.map { $0.1 }.max() ?? 1
    }
    private var minDataValue: Double {
        viewModel.data.map { $0.1 }.min() ?? 1
    }
    private var valueRange: Double {
        maxDataValue - minDataValue
    }
    
    private var dataRange: Double {
        maxDataValue - minDataValue
    }
    
    private var step: Double {
        let dataRange = maxDataValue - minDataValue
        switch dataRange {
        case ...50:
            return 10.0
        case ...100:
            return 20.0
        case ...500:
            return 50.0
        case ...1000:
            return 100.0
        case ...2000:
            return 200.0
        default:
            return 500.0
        }
    }

    private var points: [Double] {
        let start = floor(minDataValue / step) * step
        let end = ceil(maxDataValue / step) * step
        
        var points = stride(from: start, through: end, by: step).map { $0 }
        
        if maxDataValue < 50 && minDataValue > -50 {
            points = [maxDataValue, 0]
            if maxDataValue >= 25 {
                points.append(contentsOf: [(maxDataValue * 0.75).rounded(), (maxDataValue * 0.5).rounded(), (maxDataValue * 0.25).rounded()])
            } else if maxDataValue >= 15 {
                points.append((maxDataValue / 2).rounded())
            } else {
                points.append(contentsOf: [(maxDataValue * 0.5).rounded(), (maxDataValue * 0.25).rounded()])
            }
            if minDataValue < 0 {
                points.append(minDataValue)
                if minDataValue < -25 {
                    points.append(contentsOf: [(minDataValue * 0.75).rounded(), (minDataValue * 0.5).rounded(), (minDataValue * 0.25).rounded()])
                } else if minDataValue < -15 {
                    points.append(contentsOf: [(minDataValue * 0.66).rounded(), (minDataValue * 0.33).rounded()])
                } else {
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
        
        return points
    }

    
    public var body: some View {
        VStack {
            ZStack {
                VStack {
                    GeometryReader { geometry in
                        let frame = geometry.frame(in: .local)
                        

                        
                        ForEach(points, id: \.self) { point in
                            let yPosition = frame.height - (frame.height * CGFloat((point - minDataValue) / valueRange))
                            
                            Path { path in
                                path.move(to: CGPoint(x: 16, y: yPosition))
                                path.addLine(to: CGPoint(x: frame.width, y: yPosition))
                            }.stroke(gridColor, style: point == 0 ? StrokeStyle(lineWidth: 1) : StrokeStyle(lineWidth: 0.5, dash: [3]))
                            
                            Text("\(point.formatted())")
                                .foregroundStyle(textColor)
                                .font(.system(size: 12))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .position(x: -(frame.width/2.15), y: yPosition)
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
                                let maxDataValue = viewModel.data.map { $0.1 }.max() ?? 1
                                let minDataValue = viewModel.data.map { $0.1 }.min() ?? 0
                                let valueRange = maxDataValue - minDataValue
                                
                                ZStack {
                                    Path { path in
                                        var previousPoint: CGPoint?
                                        
                                        for index in viewModel.data.indices {
                                            let point = viewModel.data[index]
                                            let xPosition = frame.width * CGFloat(index) / CGFloat(viewModel.data.count - 1)
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
                                    .animation(.easeInOut(duration: Double(viewModel.data.count) * 0.2), value: animatedLines)
                                    
                                    ForEach(viewModel.data.indices, id: \.self) { index in
                                        let point = viewModel.data[index]
                                        let xPosition = frame.width * CGFloat(index) / CGFloat(viewModel.data.count - 1)
                                        let yPosition = frame.height - (frame.height * CGFloat((point.1 - minDataValue) / valueRange))
                                        
                                        Group {
                                            if !point.2 {
                                                Circle()
                                                    .stroke(index == viewModel.selectedIndex ? selectedPointColor : pointColor, lineWidth: 3)
                                                    .background(
                                                        Circle().fill(Color.clear)
                                                    )
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
                                            
                                            Text(point.0)
                                                .foregroundStyle(index == viewModel.selectedIndex ? selectedTextColor : textColor)
                                                .font(.system(size: 14))
                                                .fontWeight(index == viewModel.selectedIndex ? .heavy : .medium)
                                                .position(x: xPosition, y: frame.height + 20)
                                        }.onTapGesture {
                                            if viewModel.selectedIndex != index {
                                                withAnimation(.easeInOut) {
                                                    viewModel.selectedIndex = index
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(height: maxChartHeight)
                            .padding(.leading, 8)
                        }
                        .padding(.vertical, 28)
                        .frame(minWidth: CGFloat(viewModel.data.count) * 50)
                        .padding(.horizontal, 16)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(viewModel.data.count) * 0.08) {
                                withAnimation {
                                    scrollProxy.scrollTo(viewModel.data.count - 1, anchor: .trailing)
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
    
}

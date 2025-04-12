//
//  ElectrincFieldView.swift
//  BioFieldResearchAgent
//
//  Created by Jan Toegel on 12.04.2025.
//

import SwiftUI

struct ElectricFieldView: View {
    @State private var voltages: [Double] = (0..<8).map { _ in Double.random(in: 0...1) }

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 * 0.8

            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)

                ForEach(0..<8) { index in
                    let angle = Double(index) * 2 * .pi / 8
                    let sensorPoint = CGPoint(
                        x: center.x + radius * cos(angle),
                        y: center.y + radius * sin(angle)
                    )
                    Circle()
                        .fill(colorForVoltage(voltages[index]))
                        .frame(width: 8, height: 8)
                        .position(sensorPoint)
                }

                Canvas { context, size in
                    for x in 0..<Int(size.width) {
                        for y in 0..<Int(size.height) {
                            let distanceToCenter = sqrt(pow(Double(x) - center.x, 2) + pow(Double(y) - center.y, 2))
                            if distanceToCenter <= radius {
                                let voltage = idw(x: Double(x), y: Double(y), center: center, radius: radius)
                                let color = colorForVoltage(voltage)
                                context.fill(Path(CGRect(x: Double(x), y: Double(y), width: 1, height: 1)), with: .color(color))
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)

                Button("Regenerate") {
                    voltages = (0..<8).map { _ in Double.random(in: 0...1) }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
            }
        }
        .padding()
    }

    func idw(x: Double, y: Double, center: CGPoint, radius: Double, power: Double = 4) -> Double {
        let angles = (0..<8).map { Double($0) * 2 * .pi / 8 }
        let sensorPoints = angles.map { CGPoint(x: center.x + radius * cos($0), y: center.y + radius * sin($0)) }

        var numerator: Double = 0
        var denominator: Double = 0

        for i in 0..<8 {
            let distance = sqrt(pow(x - Double(sensorPoints[i].x), 2) + pow(y - Double(sensorPoints[i].y), 2))
            if distance == 0 {
                return voltages[i]
            }
            let weight = 1 / pow(distance, power)
            numerator += weight * voltages[i]
            denominator += weight
        }

        return denominator == 0 ? 0 : numerator / denominator
    }

    func colorForVoltage(_ voltage: Double) -> Color {
        let hue = 0.66 - (0.66 * voltage)
        return Color(hue: hue, saturation: 1.0, brightness: 1.0)
    }
}

struct ElectricFieldView_Previews: PreviewProvider {
    static var previews: some View {
        ElectricFieldView()
    }
}

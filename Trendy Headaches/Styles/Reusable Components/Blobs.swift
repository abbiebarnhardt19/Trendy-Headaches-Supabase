//
//  Blobs.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI
import Foundation

struct SameAmplitudeBlob: View {
    var waves: Int
    var amp: CGFloat
    var accent: String
    var x: CGFloat
    var y: CGFloat
    var rotation: CGFloat
    let seed = 4
    var width: CGFloat? = 700
    var height: CGFloat? = 500

    var body: some View {
        BlobShape(waves: waves, amplitude: amp, seed: seed)
            .fill(Color(hex: accent))
            .frame(width: width ?? 700, height: height ?? 500)
            .offset(x:x, y:y)
            .rotationEffect(.degrees(rotation))
    }

    private struct BlobShape: Shape {
        var waves: Int
        var amplitude: CGFloat
        var seed: Int

        func path(in rect: CGRect) -> Path {
            var path = Path()
            let step = rect.width / CGFloat(waves)
            var rng = SeededGenerator(seed: seed)

            path.move(to: .zero)

            for i in 0..<waves {
                let startX = CGFloat(i) * step
                let endX = startX + step

                let midX = (startX + endX) / 2
                let midY = midX * (rect.height / rect.width)

                let controlAmp1 = amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng))
                let controlAmp2 = amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng))
                let direction: CGFloat = (i % 2 == 0 ? -1 : 1)

                let controlX1 = startX + step * 0.25
                let controlY1 = midY + direction * controlAmp1

                let controlX2 = startX + step * 0.75
                let controlY2 = midY + direction * controlAmp2

                path.addCurve(to: CGPoint(x: endX, y: endX * (rect.height / rect.width)), control1: CGPoint(x: controlX1, y: controlY1),  control2: CGPoint(x: controlX2, y: controlY2))
            }
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.closeSubpath()
            return path
        }
    }
}

struct WavyTopBottomRectangle: View {
    var waves: Int
    var amp: CGFloat
    var accent: String
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    let seed = 4

    var body: some View {
        let path: Path = {
            var path = Path()
            let step = width / CGFloat(waves)
            
            var rng = SeededGenerator(seed: seed)
            let topAmps = (0..<waves).map { _ in amp * CGFloat(Double.random(in: 0.7...1.3, using: &rng)) }
            let bottomAmps = (0..<waves).map { _ in amp * CGFloat(Double.random(in: 0.7...1.3, using: &rng)) }

            path.move(to: CGPoint(x: 0, y: height))

            for i in 0..<waves {
                let startX = CGFloat(i) * step
                let endX = startX + step
                let direction: CGFloat = (i % 2 == 0 ? 1 : -1)

                let controlX1 = startX + step * 0.25
                let controlY1 = height + direction * bottomAmps[i]

                let controlX2 = startX + step * 0.75
                let controlY2 = height + direction * bottomAmps[i]

                path.addCurve( to: CGPoint(x: endX, y: height), control1: CGPoint(x: controlX1, y: controlY1), control2: CGPoint(x: controlX2, y: controlY2))
            }

            path.addLine(to: CGPoint(x: width, y: 0))

            for i in (0..<waves).reversed() {
                let startX = CGFloat(i+1) * step
                let endX = startX - step
                let direction: CGFloat = (i % 2 == 0 ? 1 : -1)

                let controlX1 = startX - step * 0.25
                let controlY1 = 0 + direction * topAmps[i]

                let controlX2 = startX - step * 0.75
                let controlY2 = 0 + direction * topAmps[i]

                path.addCurve(to: CGPoint(x: endX, y: 0), control1: CGPoint(x: controlX1, y: controlY1), control2: CGPoint(x: controlX2, y: controlY2))
            }

            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
            
            return path
        }()

        return path
            .fill(Color(hex: accent))
            .frame(width: width, height: height)
            .offset(x: x, y: y)
    }
}
//

// Reproducible random generator
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: Int) { self.state = UInt64(seed) }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}

//blob loading spinner
struct MultiBlobSpinner: View {
    var color: Color = .blue
    var size: CGFloat = 200
    var blobCount: Int = 7
    var orbitRadius: CGFloat = 50
    
    // Define different shape pairs for each blob
    let blobShapePairs: [([CGFloat], [CGFloat])] = [
        ([1.0, 0.6, 0.9, 0.65, 1.0, 0.7, 0.95, 0.75, 0.85, 0.8],
         [0.7, 1.0, 0.65, 0.95, 0.7, 1.0, 0.75, 0.9, 0.8, 0.65]),
        
        ([0.8, 0.9, 0.65, 1.0, 0.75, 0.85, 0.95, 0.7, 0.9, 0.8],
         [1.0, 0.7, 0.9, 0.65, 1.0, 0.8, 0.7, 0.95, 0.75, 0.85]),
        
        ([0.9, 0.75, 1.0, 0.7, 0.85, 0.95, 0.65, 0.9, 0.8, 1.0],
         [0.7, 0.95, 0.8, 1.0, 0.65, 0.85, 0.9, 0.75, 1.0, 0.7]),
        
        ([1.0, 0.65, 0.85, 0.9, 0.7, 1.0, 0.8, 0.75, 0.95, 0.85],
         [0.75, 0.9, 1.0, 0.7, 0.85, 0.65, 0.95, 1.0, 0.8, 0.9]),
        
        ([0.85, 1.0, 0.7, 0.9, 0.75, 0.8, 1.0, 0.65, 0.9, 0.95],
         [0.95, 0.7, 0.85, 0.75, 1.0, 0.9, 0.65, 0.85, 0.8, 1.0]),
        
        ([0.7, 0.85, 0.95, 0.8, 1.0, 0.75, 0.9, 0.85, 0.65, 0.95],
         [0.9, 1.0, 0.75, 0.85, 0.7, 0.95, 0.8, 0.65, 1.0, 0.8]),
        
        ([0.8, 0.9, 0.65, 1.0, 0.75, 0.85, 0.95, 0.7, 0.9, 0.8],
         [1.0, 0.7, 0.9, 0.65, 1.0, 0.8, 0.7, 0.95, 0.75, 0.85])
    ]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let rotation = Angle.degrees(time * 60)
            
            ZStack {
                ForEach(0..<blobCount, id: \.self) { index in
                    let morphPhase = (sin(time * 0.75 + Double(index) * 0.5) + 1) / 2
                    let shapes = blobShapePairs[index % blobShapePairs.count]
                    
                    MorphingBlobShape(
                        morphPhase: morphPhase,
                        shape1: shapes.0,
                        shape2: shapes.1
                    )
                    .fill(color.opacity(0.7))
                    .frame(width: size * 0.2, height: size * 0.2)
                    .offset(x: orbitRadius)
                    .rotationEffect(.degrees(Double(index) / Double(blobCount) * 360))
                }
            }
            .frame(width: size, height: size)
            .rotationEffect(rotation)
        }
    }
}

struct MorphingBlobShape: Shape {
    var morphPhase: Double
    var shape1: [CGFloat]
    var shape2: [CGFloat]
    
    var animatableData: Double {
        get { morphPhase }
        set { morphPhase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2.5
        
        let numPoints = min(shape1.count, shape2.count)
        var points: [CGPoint] = []
        
        for i in 0..<numPoints {
            let angle = (CGFloat(i) / CGFloat(numPoints)) * 2 * .pi
            
            // Smoothly interpolate between shapes
            let t = CGFloat(morphPhase)
            let radius1 = shape1[i] * baseRadius
            let radius2 = shape2[i] * baseRadius
            let radius = radius1 * (1 - t) + radius2 * t
            
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            points.append(CGPoint(x: x, y: y))
        }
        
        guard points.count > 0 else { return path }
        path.move(to: points[0])
        
        // Create smooth curves
        for i in 0..<points.count {
            let p0 = points[(i - 1 + points.count) % points.count]
            let p1 = points[i]
            let p2 = points[(i + 1) % points.count]
            let p3 = points[(i + 2) % points.count]
            
            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6,
                y: p1.y + (p2.y - p0.y) / 6
            )
            
            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6,
                y: p2.y - (p3.y - p1.y) / 6
            )
            
            path.addCurve(to: p2, control1: cp1, control2: cp2)
        }
        
        path.closeSubpath()
        return path
    }
}


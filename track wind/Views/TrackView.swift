import SwiftUI

import SwiftUI

struct TrackView: View {
    let homeDirection: Double
    let windTo: Double
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                
                // ---- TRACK PARAMETERS ----
                let L: Double = 100
                let curveLength: Double = 100
                let radius = curveLength / .pi
                
                let start = CGPoint(x: 0, y: 0)
                
                let theta = (90 - homeDirection) * .pi / 180
                let dx = cos(theta)
                let dy = sin(theta)
                
                let end = CGPoint(
                    x: start.x + L * dx,
                    y: start.y + L * dy
                )
                
                let perp = CGPoint(x: -dy, y: dx)
                
                func semicircle(center: CGPoint, flip: Bool) -> [CGPoint] {
                    let steps = 100
                    return (0...steps).map { i in
                        var angle = Double(i) / Double(steps) * .pi
                        if flip { angle *= -1 }
                        
                        let x = radius * cos(angle)
                        let y = radius * sin(angle)
                        
                        let xr = x * cos(theta - .pi/2) - y * sin(theta - .pi/2)
                        let yr = x * sin(theta - .pi/2) + y * cos(theta - .pi/2)
                        
                        return CGPoint(
                            x: center.x + xr,
                            y: center.y + yr
                        )
                    }
                }
                
                let centerStart = CGPoint(
                    x: start.x + perp.x * radius,
                    y: start.y + perp.y * radius
                )
                
                let centerEnd = CGPoint(
                    x: end.x + perp.x * radius,
                    y: end.y + perp.y * radius
                )
                
                let semiStart = semicircle(center: centerStart, flip: true)
                let semiEnd = semicircle(center: centerEnd, flip: false)
                
                let backStart = semiStart.last!
                let backEnd = semiEnd.last!
                
                // ---- TRANSFORM ----
                let centerX = (start.x + end.x + backStart.x + backEnd.x) / 4
                let centerY = (start.y + end.y + backStart.y + backEnd.y) / 4
                let scale = min(size.width, size.height) / 200
                
                func transform(_ p: CGPoint) -> CGPoint {
                    CGPoint(
                        x: (p.x - centerX) * scale + size.width / 2,
                        y: size.height / 2 - (p.y - centerY) * scale
                    )
                }
                
                // ---- TRACK BASE (background lane) ----
                var fullTrack = Path()
                fullTrack.move(to: transform(start))
                fullTrack.addLine(to: transform(end))
                fullTrack.addLines(semiEnd.map(transform))
                fullTrack.addLine(to: transform(backStart))
                fullTrack.addLines(semiStart.map(transform))
                
                context.stroke(
                    fullTrack,
                    with: .color(Color.gray.opacity(0.25)),
                    lineWidth: 14
                )
                
                // ---- HOME STRAIGHT ----
                var homePath = Path()
                homePath.move(to: transform(start))
                homePath.addLine(to: transform(end))
                
                context.stroke(
                    homePath,
                    with: .color(.blue),
                    lineWidth: 6
                )
                
                // ---- BACK STRAIGHT ----
                var backPath = Path()
                backPath.move(to: transform(backStart))
                backPath.addLine(to: transform(backEnd))
                
                context.stroke(
                    backPath,
                    with: .color(.purple),
                    lineWidth: 6
                )
                
                // ---- CURVES ----
                var curve1 = Path()
                curve1.addLines(semiStart.map(transform))
                
                var curve2 = Path()
                curve2.addLines(semiEnd.map(transform))
                
                context.stroke(curve1, with: .color(.secondary), lineWidth: 3)
                context.stroke(curve2, with: .color(.secondary), lineWidth: 3)
                
                // ---- START MARKER ----
                let startPoint = transform(end)
                context.fill(
                    Path(ellipseIn: CGRect(x: startPoint.x - 6, y: startPoint.y - 6, width: 12, height: 12)),
                    with: .color(.green)
                )

                // ---- WIND VECTOR (with clean filled arrowhead) ----
                let windScale: CGFloat = 30
                let arrowSize: CGFloat = 12     // size of the arrowhead
                let arrowOffset: CGFloat = 8    // distance from line end to tip

                let centerPoint = CGPoint(x: size.width / 2, y: size.height / 2)
                let windTheta = (90 - windTo) * .pi / 180

                // Compute full wind vector
                let windEnd = CGPoint(
                    x: centerPoint.x + windScale * CGFloat(cos(windTheta)),
                    y: centerPoint.y - windScale * CGFloat(sin(windTheta))
                )

                // Unit vector along the wind line
                let windDx = windEnd.x - centerPoint.x
                let windDy = windEnd.y - centerPoint.y
                let windLength = sqrt(windDx*windDx + windDy*windDy)
                let ux = windDx / windLength
                let uy = windDy / windLength

                // Arrow tip is at windEnd
                let arrowTip = windEnd

                // Line stops slightly before arrow tip
                let lineEnd = CGPoint(
                    x: windEnd.x - arrowOffset * ux,
                    y: windEnd.y - arrowOffset * uy
                )

                // Draw main wind line
                var windPath = Path()
                windPath.move(to: centerPoint)
                windPath.addLine(to: lineEnd)
                context.stroke(windPath, with: .color(.orange), lineWidth: 4)

                // Compute perpendicular angle for arrow sides
                let lineAngle = atan2(windDy, windDx)
                let arrowLeft = CGPoint(
                    x: arrowTip.x - arrowSize * cos(lineAngle + .pi/6),
                    y: arrowTip.y - arrowSize * sin(lineAngle + .pi/6)
                )
                let arrowRight = CGPoint(
                    x: arrowTip.x - arrowSize * cos(lineAngle - .pi/6),
                    y: arrowTip.y - arrowSize * sin(lineAngle - .pi/6)
                )

                // Draw filled triangle for arrowhead
                var arrowHead = Path()
                arrowHead.move(to: arrowTip)
                arrowHead.addLine(to: arrowLeft)
                arrowHead.addLine(to: arrowRight)
                arrowHead.closeSubpath()
                context.fill(arrowHead, with: .color(.orange))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 4)
        )
    }
}

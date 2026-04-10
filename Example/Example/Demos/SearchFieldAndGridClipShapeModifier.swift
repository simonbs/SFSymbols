import SwiftUI

extension View {
    func searchFieldAndGripClipShape(capsuleHeight: CGFloat) -> some View {
        modifier(SearchFieldAndGridClipShapeModifier(capsuleHeight: capsuleHeight))
    }
}

private struct SearchFieldAndGridClipShapeModifier: ViewModifier {
    let capsuleHeight: CGFloat
    private let edgePadding: CGFloat = 16

    func body(content: Content) -> some View {
        #if os(visionOS)
        content.clipShape(
            SearchFieldAndGridClipShape(
                edgePadding: edgePadding,
                capsuleHeight: capsuleHeight
            ),
            style: FillStyle(eoFill: true)
        )
        #else
        content.clipShape(
            SearchFieldAndGridClipShape(
                edgePadding: edgePadding,
                capsuleHeight: capsuleHeight
            )
        )
        #endif
    }
}

private struct SearchFieldAndGridClipShape: Shape {
    let edgePadding: CGFloat
    let capsuleHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        #if os(visionOS)
        let joinY = rect.minY + capsuleHeight / 2
        let bodyRect = CGRect(
            x: rect.minX,
            y: joinY,
            width: rect.width,
            height: rect.maxY - joinY
        )
        let capsuleRect = CGRect(
            x: rect.minX + edgePadding,
            y: rect.minY,
            width: rect.width - edgePadding * 2,
            height: capsuleHeight
        )
        let lowerHalfCapsuleRect = CGRect(
            x: capsuleRect.minX,
            y: joinY,
            width: capsuleRect.width,
            height: capsuleHeight / 2
        )
        var path = Path(bodyRect)
        path.addPath(lowerHalfCapsulePath(in: lowerHalfCapsuleRect, cornerRadius: capsuleHeight / 2))
        return path
        #else
        let joinY = rect.minY + capsuleHeight / 2
        let capsuleRect = CGRect(
            x: rect.minX + edgePadding,
            y: rect.minY,
            width: rect.width - edgePadding * 2,
            height: capsuleHeight
        )
        let bodyRect = CGRect(
            x: rect.minX,
            y: joinY,
            width: rect.width,
            height: rect.maxY - joinY
        )
        var path = Path()
        path.addRect(bodyRect)
        path.addPath(Capsule().path(in: capsuleRect))
        return path
        #endif
    }

    #if os(visionOS)
    private func lowerHalfCapsulePath(in rect: CGRect, cornerRadius: CGFloat) -> Path {
        let radius = min(cornerRadius, rect.width / 2, rect.height)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
    #endif
}

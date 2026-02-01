import SwiftUI

struct WordGridView: View {
    let grid: WordSearchGrid
    let foundWords: Set<String>
    let currentSelection: [GridPosition]
    let onSelectionChanged: ([GridPosition]) -> Void
    let onSelectionEnded: ([GridPosition]) -> Void

    @State private var metrics: GridMetrics?
    @State private var dragStart: GridPosition?
    @State private var dragCurrent: GridPosition?

    private let cellSize: CGFloat = 36
    private let spacing: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            let totalWidth = CGFloat(grid.cols) * cellSize + CGFloat(grid.cols - 1) * spacing
            let totalHeight = CGFloat(grid.rows) * cellSize + CGFloat(grid.rows - 1) * spacing
            let originX = (geo.size.width - totalWidth) / 2
            let originY = (geo.size.height - totalHeight) / 2

            ZStack {
                ForEach(Array(foundWords), id: \.self) { word in
                    if let positions = grid.getPositions(for: word) {
                        SelectionOverlay(
                            positions: positions,
                            cellSize: cellSize,
                            spacing: spacing,
                            origin: CGPoint(x: originX, y: originY),
                            color: ZenArcadeTheme.Colors.accentGreen
                        )
                    }
                }

                if !currentSelection.isEmpty {
                    SelectionOverlay(
                        positions: currentSelection,
                        cellSize: cellSize,
                        spacing: spacing,
                        origin: CGPoint(x: originX, y: originY),
                        color: ZenArcadeTheme.Colors.accentBlue
                    )
                }

                ForEach(0..<grid.rows, id: \.self) { row in
                    ForEach(0..<grid.cols, id: \.self) { col in
                        let pos = GridPosition(row: row, col: col)
                        let isSelected = currentSelection.contains(pos)
                        let isFound = isPositionInFoundWord(pos)

                        CellView(
                            letter: grid.cells[row][col],
                            isSelected: isSelected,
                            isFound: isFound
                        )
                        .frame(width: cellSize, height: cellSize)
                        .position(
                            x: originX + CGFloat(col) * (cellSize + spacing) + cellSize / 2,
                            y: originY + CGFloat(row) * (cellSize + spacing) + cellSize / 2
                        )
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let m = GridMetrics(
                            cellSize: cellSize,
                            spacing: spacing,
                            origin: CGPoint(x: originX, y: originY),
                            rows: grid.rows,
                            cols: grid.cols
                        )

                        if dragStart == nil {
                            if let start = m.gridPosition(for: value.startLocation) {
                                dragStart = start
                                dragCurrent = start
                                onSelectionChanged([start])
                            }
                        } else if let start = dragStart {
                            let snapped = m.snapToLine(from: start, to: value.location)
                            if snapped != dragCurrent {
                                dragCurrent = snapped
                                let line = SelectionLine(start: start, end: snapped)
                                onSelectionChanged(line.positions)
                            }
                        }
                    }
                    .onEnded { _ in
                        if let start = dragStart, let end = dragCurrent {
                            let line = SelectionLine(start: start, end: end)
                            onSelectionEnded(line.positions)
                        }
                        dragStart = nil
                        dragCurrent = nil
                    }
            )
        }
    }

    private func isPositionInFoundWord(_ pos: GridPosition) -> Bool {
        for word in foundWords {
            if let positions = grid.getPositions(for: word), positions.contains(pos) {
                return true
            }
        }
        return false
    }
}

struct CellView: View {
    let letter: Character
    let isSelected: Bool
    let isFound: Bool

    var body: some View {
        Text(String(letter))
            .font(ZenArcadeTheme.Font.rounded(18, .bold))
            .foregroundStyle(textColor)
    }

    private var textColor: Color {
        if isFound {
            return ZenArcadeTheme.Colors.accentGreen
        }
        if isSelected {
            return ZenArcadeTheme.Colors.accentBlue
        }
        return ZenArcadeTheme.Colors.textPrimary
    }
}

struct SelectionOverlay: View {
    let positions: [GridPosition]
    let cellSize: CGFloat
    let spacing: CGFloat
    let origin: CGPoint
    let color: Color

    var body: some View {
        if positions.count >= 1 {
            let start = positions.first!
            let end = positions.last!

            let startPoint = CGPoint(
                x: origin.x + CGFloat(start.col) * (cellSize + spacing) + cellSize / 2,
                y: origin.y + CGFloat(start.row) * (cellSize + spacing) + cellSize / 2
            )

            let endPoint = CGPoint(
                x: origin.x + CGFloat(end.col) * (cellSize + spacing) + cellSize / 2,
                y: origin.y + CGFloat(end.row) * (cellSize + spacing) + cellSize / 2
            )

            SelectionCapsulePath(
                start: startPoint,
                end: endPoint,
                radius: cellSize / 2
            )
            .fill(color.opacity(0.3))
            .allowsHitTesting(false)
        }
    }
}

struct SelectionCapsulePath: Shape {
    let start: CGPoint
    let end: CGPoint
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        if start == end {
            path.addEllipse(in: CGRect(
                x: start.x - radius,
                y: start.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            return path
        }

        let dx = end.x - start.x
        let dy = end.y - start.y
        let angle = atan2(dy, dx)
        let perpAngle = angle + .pi / 2

        let offsetX = cos(perpAngle) * radius
        let offsetY = sin(perpAngle) * radius

        let p1 = CGPoint(x: start.x + offsetX, y: start.y + offsetY)
        let p2 = CGPoint(x: start.x - offsetX, y: start.y - offsetY)
        let p3 = CGPoint(x: end.x - offsetX, y: end.y - offsetY)
        let p4 = CGPoint(x: end.x + offsetX, y: end.y + offsetY)

        path.move(to: p1)
        path.addArc(
            center: start,
            radius: radius,
            startAngle: .radians(Double(perpAngle)),
            endAngle: .radians(Double(perpAngle + .pi)),
            clockwise: false
        )
        path.addLine(to: p3)
        path.addArc(
            center: end,
            radius: radius,
            startAngle: .radians(Double(perpAngle + .pi)),
            endAngle: .radians(Double(perpAngle)),
            clockwise: false
        )
        path.addLine(to: p1)

        return path
    }
}

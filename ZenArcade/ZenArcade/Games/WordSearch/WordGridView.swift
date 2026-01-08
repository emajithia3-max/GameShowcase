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

                if !currentSelection.isEmpty {
                    SelectionOverlay(
                        positions: currentSelection,
                        cellSize: cellSize,
                        spacing: spacing,
                        origin: CGPoint(x: originX, y: originY),
                        color: Theme.Colors.accentBlue
                    )
                }

                ForEach(Array(foundWords), id: \.self) { word in
                    if let positions = grid.getPositions(for: word) {
                        SelectionOverlay(
                            positions: positions,
                            cellSize: cellSize,
                            spacing: spacing,
                            origin: CGPoint(x: originX, y: originY),
                            color: Theme.Colors.accentGreen
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
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)

            Text(String(letter))
                .font(Theme.Font.rounded(18, .bold))
                .foregroundStyle(textColor)
        }
    }

    private var backgroundColor: Color {
        if isFound {
            return Theme.Colors.accentGreen.opacity(0.2)
        }
        if isSelected {
            return Theme.Colors.accentBlue.opacity(0.3)
        }
        return Color(hex: "1A2B22")
    }

    private var textColor: Color {
        if isFound {
            return Theme.Colors.accentGreen
        }
        if isSelected {
            return Theme.Colors.accentBlue
        }
        return Theme.Colors.textPrimary
    }
}

struct SelectionOverlay: View {
    let positions: [GridPosition]
    let cellSize: CGFloat
    let spacing: CGFloat
    let origin: CGPoint
    let color: Color

    var body: some View {
        if positions.count >= 2 {
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

            Capsule()
                .fill(color.opacity(0.25))
                .frame(width: distance(from: startPoint, to: endPoint) + cellSize, height: cellSize)
                .position(midpoint(from: startPoint, to: endPoint))
                .rotationEffect(angle(from: startPoint, to: endPoint), anchor: .center)
                .allowsHitTesting(false)
        }
    }

    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2))
    }

    private func midpoint(from: CGPoint, to: CGPoint) -> CGPoint {
        CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
    }

    private func angle(from: CGPoint, to: CGPoint) -> Angle {
        .radians(atan2(to.y - from.y, to.x - from.x))
    }
}

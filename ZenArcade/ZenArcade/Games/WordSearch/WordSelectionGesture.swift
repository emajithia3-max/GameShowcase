import SwiftUI

struct SelectionLine {
    var start: GridPosition
    var end: GridPosition

    var positions: [GridPosition] {
        guard isValid else { return [] }

        var result: [GridPosition] = []
        let dRow = end.row - start.row
        let dCol = end.col - start.col

        let steps = max(abs(dRow), abs(dCol))
        guard steps > 0 else { return [start] }

        let stepRow = dRow == 0 ? 0 : dRow / abs(dRow)
        let stepCol = dCol == 0 ? 0 : dCol / abs(dCol)

        for i in 0...steps {
            result.append(GridPosition(row: start.row + i * stepRow, col: start.col + i * stepCol))
        }

        return result
    }

    var isValid: Bool {
        let dRow = abs(end.row - start.row)
        let dCol = abs(end.col - start.col)

        if dRow == 0 || dCol == 0 {
            return true
        }

        return dRow == dCol
    }
}

struct GridMetrics {
    let cellSize: CGFloat
    let spacing: CGFloat
    let origin: CGPoint
    let rows: Int
    let cols: Int

    func position(for gridPos: GridPosition) -> CGPoint {
        let x = origin.x + CGFloat(gridPos.col) * (cellSize + spacing) + cellSize / 2
        let y = origin.y + CGFloat(gridPos.row) * (cellSize + spacing) + cellSize / 2
        return CGPoint(x: x, y: y)
    }

    func gridPosition(for point: CGPoint) -> GridPosition? {
        let col = Int((point.x - origin.x) / (cellSize + spacing))
        let row = Int((point.y - origin.y) / (cellSize + spacing))

        guard row >= 0, row < rows, col >= 0, col < cols else { return nil }

        let cellX = origin.x + CGFloat(col) * (cellSize + spacing)
        let cellY = origin.y + CGFloat(row) * (cellSize + spacing)

        guard point.x >= cellX, point.x <= cellX + cellSize,
              point.y >= cellY, point.y <= cellY + cellSize else {
            return nil
        }

        return GridPosition(row: row, col: col)
    }

    func snapToLine(from start: GridPosition, to point: CGPoint) -> GridPosition {
        guard let raw = gridPosition(for: point) else {
            return start
        }

        let dRow = raw.row - start.row
        let dCol = raw.col - start.col

        if dRow == 0 || dCol == 0 {
            return raw
        }

        if abs(dRow) == abs(dCol) {
            return raw
        }

        if abs(dRow) > abs(dCol) {
            let signRow = dRow > 0 ? 1 : -1
            return GridPosition(row: start.row + abs(dCol) * signRow, col: raw.col)
        } else {
            let signCol = dCol > 0 ? 1 : -1
            return GridPosition(row: raw.row, col: start.col + abs(dRow) * signCol)
        }
    }
}

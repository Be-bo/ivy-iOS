//
//  GridView.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//
// This gridView is made for a generic type T
//

import SwiftUI

// Generic gridview that takes a list [T] and creates a cellView per item
// Refer to preview for example
struct GridView<T, Label> : View where Label : View, T : Identifiable {
    
    var rows: [Row<T>]
    var cellView: ((T) -> Label)
    
    init(cells: [T], maxCol: Int, _ cellView: @escaping ((T) -> Label)) {
        self.rows = Row.makeGrid(numberOfColumns: maxCol, cells: cells)
        self.cellView = cellView
    }
    
    var body: some View {
        ForEach(rows) { row in
            HStack {
                ForEach(row.cells, content: self.cellView)
                Spacer()
            }
        }
    }
}

// Preview
struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(
            cells: [Cell(1), Cell(2), Cell(3), Cell(4), Cell(5), Cell(6), Cell(7)],
            maxCol: 3
        ) { cell in
            Text("Cell #\(cell.value)")
        }
    }
}


/* SubViews */

// Generic row of type T
struct Row<T>: Identifiable {
    
    let id = UUID()
    var cells: [T]
    
    // Make an array of rows given an array of posts
    static func makeGrid(numberOfColumns: Int, cells: [T]) -> [Row]{
        
        var row = Row(cells: [])
        var grid = [Row] ()
        
        for cell in cells {
            
            // Make new Row if max columns reached
            if row.cells.count < numberOfColumns {
                row.cells.append(cell)
                print("appended: \(cell)")
            }
            else {
                grid.append(row)
                row = Row(cells: [cell])
                print("new row: \(cell)")
            }
        }
        
        // Append final uneven row
        if !row.cells.isEmpty {
            grid.append(row)
        }
        
        return grid
    }
}

// For Preview Only
struct Cell: Identifiable {
    let id = UUID()
    let value: Int
    
    init(_ value: Int) {
        self.value = value
    }
}

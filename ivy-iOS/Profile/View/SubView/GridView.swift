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
    
    var array = [T]()
    var rows : [Row<T>]
    //var cellView: ((GeometryProxy) -> ((T) -> Label))
    var cellView : ((T) -> Label)
    var maxCol : Int
    
    
    init(cells: [T], maxCol: Int, _ cellView: @escaping ((T) -> Label)) {
        self.array = cells
        self.rows = Row.makeGrid(numberOfColumns: maxCol, cells: cells)
        self.cellView = cellView
        self.maxCol = maxCol
    }
    
    var body: some View {
        //GeometryReader { geo in

            VStack (alignment: .leading) {
                ForEach(self.rows) { row in
                    HStack () {
                        ForEach(row.cells, content: self.cellView)
                        if (row.cells.count < self.maxCol) {
                            Spacer()
                        }
                    }
                }
            }
        //}
    }
}

// Preview
/*
struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(
            cells: [Cell(1), Cell(2), Cell(3), Cell(4), Cell(5), Cell(6), Cell(7)],
            maxCol: 3
        ) { geo in
            { cell in
                Rectangle()
                    .frame(width: geo.size.width/3, height: geo.size.width/3)
                    .foregroundColor(.red)
            }
        }
    }
}
 */


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
            }
            else {
                grid.append(row)
                row = Row(cells: [cell])
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

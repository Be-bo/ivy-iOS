//
//  ChatBubble.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-12-22.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Citations:
//  https://youtube.com/watch?v=PrasbHixcpU


import SwiftUI

struct ChatBubble: Shape {
    
    var myMsg : Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight, myMsg ? .bottomLeft : .bottomRight],
            cornerRadii: CGSize(width: 15, height: 15)
        )
        
        return Path(path.cgPath)
    }
}


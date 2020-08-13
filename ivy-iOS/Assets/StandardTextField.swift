//
//  StandardTextField.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct StandardTextField<CustomContent: View>: View{
    
    let content: CustomContent
    
    init(@ViewBuilder content: () -> CustomContent){
        self.content = content()
    }
    
    var body: some View{
        Text("nothing")
    }
    
}

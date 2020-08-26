//
//  EditProfileSupport.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-24.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

// Name Field
struct NameField: View {
    var hint = "Name"
    @Binding var name: String
    
    var body: some View {
        Group {
            TextField(hint, text: $name)
            Divider()
                .background(name != "" ? Color.green : nil)
                .padding(.bottom)
        }
    }
}


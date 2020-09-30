//
//  PersonCircleView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-22.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct PersonCircleView: View {
    var personId: String = ""
    @State var url = ""
    
    var body: some View {
        FirebaseImage(
            path: Utils.userPreviewImagePath(userId: self.personId),
            placeholder: Image(systemName: "person.crop.circle.fill"),
            width: 60,
            height: 60,
            shape: RoundedRectangle(cornerRadius: 30)
        )
    }
}

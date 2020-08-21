//
//  EventsTabItem.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct EventsTabItemView: View {
    var event: Event
    
    var body: some View {
        
        VStack(alignment: .leading){
            Image(systemName: "rectangle.fill")
                .resizable()
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 30))
            HStack{
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                Text("Event Name")
                    .frame(width: 140, height: 50, alignment: .leading)
                    .padding(.leading, 5)
            }
        }
    }
}


struct EventsTabItem_Previews: PreviewProvider {
    static var previews: some View {
        EventsTabItemView()
    }
}

//
//  ChatBubbleView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-12-22.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Citations:
//  https://youtube.com/watch?v=PrasbHixcpU
//

import SwiftUI

struct ChatMessageView: View {
    
    // Change to @Observed Obj if watching for edits
    var messageVM : MessageViewModel
    var thisUserID : String
    var thisUserIsAuthor : Bool
    
    init(messageVM: MessageViewModel, thisUserID : String) {
        self.messageVM = messageVM
        self.thisUserID = thisUserID
        self.thisUserIsAuthor = thisUserID == messageVM.message.author
    }
    
    var body: some View {
        HStack (spacing: 15){
            
            if thisUserIsAuthor {
                Spacer() // ThisUser is on the right side
            }
            else {
                FirebaseImage(
                    path: Utils.userPreviewImagePath(userId: self.messageVM.message.author),
                    placeholder: Image(systemName: "person.crop.circle.fill"),
                    width: 40,
                    height: 40,
                    shape: RoundedRectangle(cornerRadius: 20)
                )
            }
            
            VStack(alignment: thisUserIsAuthor ? .trailing : .leading, spacing: 5) {
                
                // Text
                Text(messageVM.message.text)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(thisUserIsAuthor ? AssetManager.ivyGreen : .gray)
                    .clipShape(ChatBubble(myMsg: thisUserIsAuthor))
                
                // Time Stamp
                if let time_stamp = messageVM.message.time_stamp {
                    Text(Utils.getExactTimeFromMillis(millis: Double(time_stamp)))
                        .font(.system(size: 12))
                        .foregroundColor(AssetManager.ivyLightGrey)
                        .padding(thisUserIsAuthor ? .leading : .trailing, 10)
                }
            }

            
            
            if (!thisUserIsAuthor) {
                Spacer() // Partner is on the left side
            }
            
        }
    }
}


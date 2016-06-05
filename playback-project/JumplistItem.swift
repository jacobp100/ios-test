//
//  JumplistItem.swift
//  playback-project
//
//  Created by Jacob Parker on 05/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import Foundation
import CoreData


class JumplistItem: NSManagedObject {

    static let DID_UPDATE = "JUMPLIST_DID_UPDATE"

    class func jumplistItemForMediaItemTime(mediaItem: MediaItem, time: Double, context: NSManagedObjectContext) -> JumplistItem? {
        let request = NSFetchRequest(entityName: "JumplistItem")
        request.predicate = NSPredicate(
            format: "mediaItem = %@ and time = %@",
            mediaItem,
            NSNumber(double: time)
        )

        if let jumplistItem = (try? context.executeFetchRequest(request))?.first as? JumplistItem {
            return jumplistItem
        } else if let jumplistItem = NSEntityDescription.insertNewObjectForEntityForName("JumplistItem", inManagedObjectContext: context) as? JumplistItem {
            jumplistItem.mediaItem = mediaItem
            jumplistItem.time = time
            return jumplistItem
        } else {
            return nil
        }
    }

    override func didSave() {
        NSNotificationCenter.defaultCenter().postNotificationName(
            JumplistItem.DID_UPDATE,
            object: self
        )
    }

}

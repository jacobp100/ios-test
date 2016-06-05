//
//  MediaItem.swift
//  playback-project
//
//  Created by Jacob Parker on 05/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import Foundation
import CoreData


class MediaItem: NSManagedObject {

    class func mediaItemForMusicPlayerFile(musicPlayerFile: MusicPlayerFile, context: NSManagedObjectContext) -> MediaItem? {

        let request = NSFetchRequest(entityName: "MediaItem")
        request.predicate = NSPredicate(
            format: "id = %@ and type = %@",
            musicPlayerFile.id,
            musicPlayerFile.type
        )

        if let mediaItem = (try? context.executeFetchRequest(request))?.first as? MediaItem {
            return mediaItem
        } else if let mediaItem = NSEntityDescription.insertNewObjectForEntityForName("MediaItem", inManagedObjectContext: context) as? MediaItem {
            mediaItem.id = musicPlayerFile.id
            mediaItem.type = musicPlayerFile.type
            return mediaItem
        } else {
            return nil
        }
    }

}

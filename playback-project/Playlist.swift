//
//  Playlist.swift
//  playback-project
//
//  Created by Jacob Parker on 05/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import Foundation
import CoreData


class Playlist: NSManagedObject {

    class func playlistForName(name: String, context: NSManagedObjectContext) -> Playlist? {

        let request = NSFetchRequest(entityName: "Playlist")
        request.predicate = NSPredicate(
            format: "name = %@",
            name
        )

        if let playlist = (try? context.executeFetchRequest(request))?.first as? Playlist {
            return playlist
        } else if let playlist = NSEntityDescription.insertNewObjectForEntityForName("Playlist", inManagedObjectContext: context) as? Playlist {
            playlist.name = name
            return playlist
        } else {
            return nil
        }
    }

}

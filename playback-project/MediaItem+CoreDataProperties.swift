//
//  MediaItem+CoreDataProperties.swift
//  playback-project
//
//  Created by Jacob Parker on 05/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MediaItem {

    @NSManaged var id: String?
    @NSManaged var pitch: NSNumber?
    @NSManaged var tempo: NSNumber?
    @NSManaged var type: String?
    @NSManaged var jumplistItems: Set<JumplistItem>?
    @NSManaged var playlist: Playlist?

}

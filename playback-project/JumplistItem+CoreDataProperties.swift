//
//  JumplistItem+CoreDataProperties.swift
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

extension JumplistItem {

    @NSManaged var time: NSNumber?
    @NSManaged var mediaItem: MediaItem?

}

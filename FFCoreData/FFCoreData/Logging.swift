//
//  Logging.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 27.07.18.
//  Copyright © 2018 Florian Friedrich. All rights reserved.
//

#if canImport(os)
import class os.OSLog
#else
import class FFFoundation.OSLog
#endif

extension OSLog {
    static let ffCoreData = OSLog(subsystem: "net.ffried.ffcoredata", category: "Default")
}

//
//  BuildConfig.swift
//  Toggle
//
//  Created by Jim Newkirk on 3/22/25.
//
import Foundation

enum BuildConfig {
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var buildType: String {
        isDebug ? "DEBUG" : "RELEASE"
    }
}

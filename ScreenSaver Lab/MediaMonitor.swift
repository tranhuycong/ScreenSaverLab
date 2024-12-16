//
//  MediaMonitor.swift
//  ScreenSaver Lab
//
//  Created by Tran Cong on 16/12/24.
//
import CoreFoundation
import Foundation

class MediaMonitor {
    static let shared = MediaMonitor()
    private var bundle: CFBundle?
    private var getInfoFunction: UnsafeMutableRawPointer?

    private init() {
        setupFramework()
    }

    private func setupFramework() {
        let path = "/System/Library/PrivateFrameworks/MediaRemote.framework"
        guard let url = NSURL(fileURLWithPath: path) as URL? else { return }
        bundle = CFBundleCreate(kCFAllocatorDefault, url as CFURL)
        getInfoFunction = CFBundleGetFunctionPointerForName(
            bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
    }

    func isMediaPlaying(completion: @escaping (Bool) -> Void) {
        guard let pointer = getInfoFunction else {
            completion(false)
            return
        }

        let function = unsafeBitCast(
            pointer,
            to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self)

        function(DispatchQueue.main) { info in
            let isPlaying = info["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? NSNumber
            completion(isPlaying?.doubleValue ?? 0 > 0)
        }
    }
}

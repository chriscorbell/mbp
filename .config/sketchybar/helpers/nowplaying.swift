#!/usr/bin/env swift
import Foundation

let frameworkURL = URL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework") as CFURL

guard
  let bundle = CFBundleCreate(kCFAllocatorDefault, frameworkURL),
  let functionPointer = CFBundleGetFunctionPointerForName(
    bundle,
    "MRMediaRemoteGetNowPlayingInfo" as CFString
  )
else {
  exit(0)
}

typealias GetNowPlayingInfo = @convention(c) (
  DispatchQueue,
  @escaping (NSDictionary) -> Void
) -> Void

let getNowPlayingInfo = unsafeBitCast(functionPointer, to: GetNowPlayingInfo.self)
let semaphore = DispatchSemaphore(value: 0)
var output = ""

func stringValue(_ info: NSDictionary, _ key: String) -> String {
  guard let value = info[key] else { return "" }
  return "\(value)".trimmingCharacters(in: .whitespacesAndNewlines)
}

getNowPlayingInfo(DispatchQueue.global(qos: .userInitiated)) { info in
  defer { semaphore.signal() }

  let playbackRate = (info["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? NSNumber)?.doubleValue ?? 0
  guard playbackRate > 0 else { return }

  let title = stringValue(info, "kMRMediaRemoteNowPlayingInfoTitle")
  let artist = stringValue(info, "kMRMediaRemoteNowPlayingInfoArtist")

  guard !title.isEmpty else { return }

  if artist.isEmpty || artist == title {
    output = title
  } else {
    output = "\(artist)  –  \(title)"
  }
}

_ = semaphore.wait(timeout: .now() + 1)

if !output.isEmpty {
  print(output)
}

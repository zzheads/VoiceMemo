//
//  MemoAudio.swift
//  VoiceMemo
//
//  Created by Alexey Papin on 02.01.17.
//  Copyright © 2017 Treehouse Island, Inc. All rights reserved.
//

import Foundation
import AVFoundation

class MemoSessionManager {
    static let sharedInstance = MemoSessionManager()
    let session: AVAudioSession
    
    var permissionGranted: Bool {
        return self.session.recordPermission() == .granted
    }
    
    private init() {
        self.session = AVAudioSession.sharedInstance()
        self.configureSession()
    }
    
    private func configureSession() {
        do {
            try self.session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.session.setActive(true)
        } catch {
            print(error)
        }
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        self.session.requestRecordPermission { permissionAllowed in
            completion(permissionAllowed)
        }
    }
}

class MemoRecorder {
    
    static let sharedInstance = MemoRecorder()
    
    private static let settings: [String: AnyObject] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC) as AnyObject,
        AVSampleRateKey: 22050.0 as AnyObject,
        AVEncoderBitDepthHintKey: 16 as NSNumber,
        AVNumberOfChannelsKey: 1 as NSNumber,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue as AnyObject
    ]
    
    private let recorder: AVAudioRecorder

    private static func outputURL() -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first! as NSString
        let audioPath = documentsDirectory.appendingPathComponent("memo.m4a")
        return URL(string: audioPath)!
    }
    
    private init() {
        self.recorder = try! AVAudioRecorder(url: MemoRecorder.outputURL(), settings: MemoRecorder.settings)
        self.recorder.prepareToRecord()
    }
    
    func start() {
        self.recorder.record()
    }
    
    func stop() -> String {
        self.recorder.stop()
        return self.recorder.url.absoluteString
    }
}

class MemoPlayer {
    static let sharedInstance = MemoPlayer()
    
    var player: AVAudioPlayer!
    
    private init() {}
    
    func play(track: Data) {
        if self.player.isPlaying {
            self.player.stop()
            self.player = nil
        }
        self.player = try! AVAudioPlayer(data: track, fileTypeHint: "m4a")
        self.player.play()
    }
}

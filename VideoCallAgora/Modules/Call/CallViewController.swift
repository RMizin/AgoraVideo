//
//  CallViewController.swift
//  VideoCallAgora
//
//  Created by Roman Mizin on 2/23/21.
//

import AgoraRtcKit

final class CallViewController: UIViewController {

    private let configuration: [String: Any]
    private let token: String
    private var agoraKit: AgoraRtcEngineKit!
    private var isJoined: Bool = false

    @IBOutlet private weak var myVideoView: VideoView!
    @IBOutlet private weak var membersStackView: UIStackView!

    init(token: String, configuration: [String: Any]) {
        self.token = token
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCall()
    }

    deinit {
        if isJoined {
            agoraKit.leaveChannel()
        }
    }
}

// MARK: - Call configuration

private extension CallViewController {

    func configureCall() {
        let config = AgoraRtcEngineConfig()
        config.appId = KeyCenter.appId
        config.areaCode = AgoraAreaCode.GLOB.rawValue

        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)

        guard let channelName = configuration["channelName"] as? String,
            let resolution = configuration["resolution"] as? CGSize,
            let fps = configuration["fps"] as? AgoraVideoFrameRate,
            let orientation = configuration["orientation"] as? AgoraVideoOutputOrientationMode else {
            return
        }

        // make myself a broadcaster
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(.broadcaster)

        // enable video module
        agoraKit.enableVideo()
        agoraKit.setVideoEncoderConfiguration(
            AgoraVideoEncoderConfiguration(
                size: resolution,
                frameRate: fps,
                bitrate: AgoraVideoBitrateStandard,
                orientationMode: orientation
            )
        )

        // set up local video to render your local camera preview
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0

        let localVideo = VideoView()
        videoCanvas.view = localVideo.contentView
        videoCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(videoCanvas)
        addMyStream(localVideo)

        // Set audio route to speaker
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)

        _ = agoraKit.joinChannel(byToken: token, channelId: channelName, info: nil, uid: 0, options: AgoraRtcChannelMediaOptions())
    }
}

// MARK: - Members management

private extension CallViewController {

    func addMyStream(_ localVideo: VideoView) {
        myVideoView.addSubview(localVideo)
        localVideo.translatesAutoresizingMaskIntoConstraints = false
        localVideo.topAnchor.constraint(equalTo: myVideoView.topAnchor).isActive = true
        localVideo.bottomAnchor.constraint(equalTo: myVideoView.bottomAnchor).isActive = true
        localVideo.leadingAnchor.constraint(equalTo: myVideoView.leadingAnchor).isActive = true
        localVideo.trailingAnchor.constraint(equalTo: myVideoView.trailingAnchor).isActive = true
    }

    func addMember(_ remoteVideo: VideoView) {
        remoteVideo.translatesAutoresizingMaskIntoConstraints = false
        remoteVideo.widthAnchor.constraint(equalToConstant: 200).isActive = true
        remoteVideo.heightAnchor.constraint(equalToConstant: 250).isActive = true
        membersStackView.insertArrangedSubview(remoteVideo, at: 0)
    }

    func removeMember(_ uid: UInt) {
        guard let stream = membersStackView.arrangedSubviews
                .compactMap({ $0 as? VideoView })
                .first(where: { $0.uid == uid }) else {
            return
        }

        membersStackView.removeArrangedSubview(stream)
        stream.removeFromSuperview()
    }
}

// MARK: - AgoraRtcEngineDelegate

extension CallViewController: AgoraRtcEngineDelegate {

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        isJoined = true
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let remoteVideo = VideoView()
        remoteVideo.uid = uid

        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteVideo.contentView
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
        addMember(remoteVideo)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = nil
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
        removeMember(uid)
    }
}

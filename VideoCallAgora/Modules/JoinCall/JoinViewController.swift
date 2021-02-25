//
//  JoinViewController.swift
//  VideoCallAgora
//
//  Created by Roman Mizin on 2/23/21.
//

import UIKit
import AgoraRtcKit

final class JoinViewController: UIViewController {

    @IBOutlet private weak var tokenTextField: UITextField! {
        didSet {
            tokenTextField.text = KeyCenter.token
        }
    }

    @IBOutlet private weak var channelTextField: UITextField! {
        didSet {
            channelTextField.text = "gbk"
        }
    }

    @IBAction func didTapConnect(_ sender: UIButton) {
        connect()
    }

    private func connect() {
        guard let channelName = channelTextField.text, !channelName.isEmpty else { return }
        guard let token = tokenTextField.text, !token.isEmpty else { return }
        channelTextField.resignFirstResponder()

        let newViewController = CallViewController(token: token, configuration: [
            "channelName": channelName,
            "resolution": CGSize(width: 640, height: 360),
            "fps": AgoraVideoFrameRate.fps30,
            "orientation": AgoraVideoOutputOrientationMode.adaptative
        ])

        present(newViewController, animated: true)
    }
}

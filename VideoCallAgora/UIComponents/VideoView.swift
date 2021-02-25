//
//  VideoView.swift
//  VideoCallAgora
//
//  Created by Roman Mizin on 2/23/21.
//

import UIKit


@IBDesignable class VideoView: UIView {

    @IBOutlet private(set) weak var contentView: UIView!

    var uid: UInt = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    private func initView() {
        loadFromXib("VideoView", contextOf: VideoView.self)
        layer.cornerRadius = 12
        contentView.layer.cornerRadius = 12
    }
}

// MARK: - Load from xib

extension UIView {
    func loadFromXib(_ nibName: String, contextOf: UIView.Type) {
        let nibView = Bundle(for: contextOf).loadNibNamed(nibName, owner: self, options: nil)!.first as! UIView

        nibView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        nibView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(nibView)
        nibView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nibView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        nibView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        nibView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

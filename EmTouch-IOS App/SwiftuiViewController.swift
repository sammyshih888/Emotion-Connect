//
//  SwiftuiViewController.swift
//  ARKit-CoreML-Emotion-Classification
//
//  Created by
//

import UIKit
import SwiftUI

class SwiftuiViewController: UIHostingController<Home> {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder , rootView: Home())
    }

}

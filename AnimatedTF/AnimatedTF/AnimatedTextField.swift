//
//  ViewController.swift
//  AnimatedTF
//
//  Created by Patricio Reyes on 02/06/22.
//

import UIKit

final class AnimatedTextField: UITextField {
    public var animationType: AnimationType = .linear(duration: 0.2)
    private var animator: Animator?
    
    public func animate() {
        animator = Animator(type: animationType)
        animator?.textfield = self
        animator?.start()
    }
}

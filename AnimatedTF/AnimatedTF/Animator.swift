//
//  ViewController.swift
//  AnimatedTF
//
//  Created by Patricio Reyes on 02/06/22.
//

import UIKit

enum AnimationType {
    case linear(duration: CGFloat)
    case spring(damping: CGFloat, response: CGFloat)
}

final class Animator {
    
    // MARK: - Public Properties
    public var duration: TimeInterval = 2.0
    public var type: AnimationType = .linear(duration: 2.0)
//    public var type: AnimationType = .linear
    public var verticalDisplacement: CGFloat = 0.0
   
    public weak var textfield: UITextField? {
          didSet {
              guard let text = textfield?.text else { return }
              verticalDisplacement = (textfield?.font?.lineHeight ?? 0) / 2
              setInitialAttributes(text: NSMutableAttributedString(string: text))
          }
    }
    
    // MARK: - Private Properties
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0.0
    private var attributedString: NSMutableAttributedString?
    
    // MARK: - Init
    convenience init(type: AnimationType) {
        self.init()
        self.type = type
        
        switch type {
        case .linear(let duration):
            self.duration = duration
        case .spring(_, let response):
            self.duration = (2.0 * response)
        }
    }
    
    // MARK: - Public Methods
    func start() {
        setupDisplayLink()
    }
}

extension Animator {
    
    // MARK: - DisplayLink Methods
    @objc
    private func displayLinkDidFire(_ displayLink: CADisplayLink) {
        let currentTime = CACurrentMediaTime()
        guard currentTime <= startTime + duration else {
            tearDownDisplayLink()
            return
        }
        setFrameAttributes(currentTime: currentTime)
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        startTime = CACurrentMediaTime()
    }
    
    private func tearDownDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    //MARK: - Offset transformations
    private func setInitialAttributes(text: NSMutableAttributedString) {
        let offset = -verticalDisplacement
        let attributedString = text.setAtttributes(baselineOffset: offset)
        self.attributedString = attributedString
        textfield?.attributedText = attributedString
    }
    
    private func setFrameAttributes(currentTime: CFTimeInterval) {
        guard let text = attributedString else { return }
        let timeElapsed = CGFloat(currentTime - startTime)
        let offset = getOffset(at: timeElapsed, type: type)
        let attributedText = text.setAtttributes(baselineOffset: offset)
        textfield?.attributedText = attributedText
    }

    private func getOffset(at timeElapsed: CGFloat, type: AnimationType) -> CGFloat {
        switch type {
        case .linear(_):
            return f_linear(t: timeElapsed)
        case .spring(let ratio, _):
            return f_damped(t: timeElapsed, dampingRatio: ratio)
        }
    }
    
    //MARK: - Animation Equations
    
    private func f_linear(t timeElapsed: CGFloat) -> CGFloat {
        var ratio = timeElapsed / duration
        ratio = fmax(0.0, ratio)
        ratio = fmin(1.0, ratio)
        let percent = (ratio - 1)
        return percent * verticalDisplacement
    }
    
    private func f_damped(t timeElapsed: CGFloat, dampingRatio: CGFloat) -> CGFloat {
        guard let displayLink = displayLink else { return 0.0 }
        let refreshPeriod = (displayLink.targetTimestamp - displayLink.timestamp)
        let refreshFrequency = 1 / refreshPeriod
        let totalFrames = floor(refreshFrequency * duration)
        let currentFrame = floor(refreshFrequency * timeElapsed)
        let spring = DampedSpring(frequencyResponse: totalFrames/2.0, dampingRatio: dampingRatio)
        var ratio = spring.calculatePosition(at: currentFrame, initialPosition: 1.0)
        ratio = fmax(0.0, ratio)
        let percent = (-1 * ratio)
        return percent * verticalDisplacement
    }
}

fileprivate extension NSMutableAttributedString {
    func setAtttributes(baselineOffset: CGFloat,
                        foregroundColor: UIColor = UIColor.white,
                        backgroundColor: UIColor = UIColor.black) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.baselineOffset: baselineOffset]
        
        self.setAttributes(attributes, range: NSRange.last(in: self.string))
        return self
    }
}

fileprivate extension NSRange {
    static func last(in text: String) -> NSRange {
        guard text.count > 0 else {
            return NSRange(location: 0, length: 0)
        }
        return NSRange(location: text.count - 1, length: 1)
    }
}

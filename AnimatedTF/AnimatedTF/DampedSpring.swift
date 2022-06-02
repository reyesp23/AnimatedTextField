//
//  ViewController.swift
//  AnimatedTF
//
//  Created by Patricio Reyes on 02/06/22.
//

import UIKit

struct DampedSpring {
    var frequencyResponse: CGFloat = 0.0
    var dampingRatio: CGFloat = 0.5
    var mass: CGFloat = 1

    init(frequencyResponse: CGFloat, dampingRatio: CGFloat) {
       self.frequencyResponse = frequencyResponse
       self.dampingRatio = dampingRatio
    }

    var stiffness: CGFloat {
        return pow(2 * .pi / frequencyResponse, 2) * mass
    }
    
    var dampingCoefficient: CGFloat {
        return 4 * .pi * dampingRatio * mass / frequencyResponse
    }
    
    var undampedNaturalFrequency: CGFloat {
        return sqrt(stiffness / mass)
    }
    
    var dampedNaturalFrequency: CGFloat {
        return undampedNaturalFrequency * sqrt(abs(1 - pow(dampingRatio, 2)))
    }
    
    var decayConstant: CGFloat {
        return undampedNaturalFrequency * dampingRatio
    }
    
    func calculatePosition(at t: CGFloat,
                           initialPosition: CGFloat,
                           initialVelocity: CGFloat = 0) -> CGFloat {
        let a = self.decayConstant
        let b = self.dampedNaturalFrequency
        let c = (initialVelocity + a * initialPosition) / b
        let d = initialPosition
        return exp(-a * t) * (d * cos(b * t) + c * sin(b * t))
    }
}

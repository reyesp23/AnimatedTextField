//
//  ViewController.swift
//  AnimatedTF
//
//  Created by Patricio Reyes on 02/06/22.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var textfield: AnimatedTextField! {
        didSet {
            textfield.font = UIFont.systemFont(ofSize: 45, weight: .bold)
            textfield.textColor = . black
            textfield.text = nil
            textfield.placeholder = "type..."
            textfield.animationType = .spring(damping: 0.3, response: 0.1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textfield.becomeFirstResponder()
    }
    
    @IBAction func didChanged(_ sender: Any) {
        textfield.animate()
    }
}

//
//  ViewController.swift
//  CustomKnob
//
//  Created by Nikita Kukushkin on 05/08/2014.
//  Copyright (c) 2014 Nikita Kukushkin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var animate: UISwitch!
    
    @IBOutlet weak var customKnob: Knob!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customKnob.addTarget(self, action: #selector(customKnobValueChanged(_:)), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions
    
    func customKnobValueChanged(_ sender: Knob) {
        label.text = String(format: "%.2f", sender.value)
        slider.setValue(sender.value, animated: animate.isOn)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        label.text = String(format: "%.2f", sender.value)
        customKnob.setValue(value: sender.value, animated: animate.isOn)
    }

    @IBAction func generateRandomValue(_ sender: UIButton) {
        let randomValue = (Float((arc4random()) % 101) / 100.0)
        label.text = String(format: "%.2f", randomValue)
        slider.setValue(randomValue, animated: animate.isOn)
        customKnob.setValue(value: randomValue, animated: animate.isOn)
    }
}


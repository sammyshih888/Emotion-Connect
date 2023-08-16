//
//  ResultViewController.swift
//  ARKit-CoreML-Emotion-Classification
//
//  Created by 魏淳豐 on 2023/4/10.
//

import UIKit

class ResultViewController: UIViewController {
    
    
    @IBOutlet weak var lb_happy: UILabel!
    @IBOutlet weak var pg_happy: UIProgressView!
    
    @IBOutlet weak var lb_angry: UILabel!
    
    @IBOutlet weak var pg_angry: UIProgressView!
    
    @IBOutlet weak var lb_disgust: UILabel!
    @IBOutlet weak var pg_disgust: UIProgressView!
    
    @IBOutlet weak var lb_fear: UILabel!
    @IBOutlet weak var pg_fear: UIProgressView!
    
    
    @IBOutlet weak var lb_sad: UILabel!
    
    @IBOutlet weak var pg_sad: UIProgressView!
    
    @IBOutlet weak var lb_surprised: UILabel!
    
    @IBOutlet weak var pg_surprised: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var data = UserDefaults.standard
        
        let t_sad = data.integer( forKey: "t_sad")
        let t_fear = data.integer( forKey: "t_fear")
        let t_angry = data.integer( forKey: "t_angry")
        let t_disgust =  data.integer( forKey: "t_disgust")
        let t_surprised = data.integer( forKey: "t_surprised")
        let t_happy = data.integer( forKey: "t_happy")
        
        let c_sad = data.integer( forKey: "c_sad")
        let c_fear = data.integer( forKey: "c_fear")
        let c_angry = data.integer( forKey: "c_angry")
        let c_disgust = data.integer( forKey: "c_disgust")
        let c_surprised = data.integer( forKey: "c_surprised")
        let c_happy = data.integer( forKey: "c_happy")
        
        var pg = 0;
        if( t_sad > 0 ){
            pg = c_sad  * 100 / t_sad  ;
        }
        
        lb_sad.text = "\(EmType.sad.name) \(pg)%";
        pg_sad.progress = Float(pg) / 100 ;
        
        //========================================
        pg = 0;
        if( t_happy > 0 ){
            pg = c_happy  * 100 / t_happy  ;
        }
        
        lb_happy.text = "\(EmType.happy.name) \(pg)%";
        pg_happy.progress = Float(pg) / 100 ;
        
        //========================================
        pg = 0;
        if( t_fear > 0 ){
            pg = c_fear  * 100 / t_fear  ;
        }
        
        lb_fear.text = "\(EmType.fear.name) \(pg)%";
        pg_fear.progress = Float(pg) / 100 ;
        //========================================
        pg = 0;
        if( t_angry > 0 ){
            pg = c_angry  * 100 / t_angry  ;
        }
        
        lb_angry.text = "\(EmType.angry.name) \(pg)%";
        pg_angry.progress = Float(pg) / 100 ;
        //========================================
        pg = 0;
        if( t_surprised > 0 ){
            pg = c_surprised  * 100 / t_surprised  ;
        }
        
        lb_surprised.text = "\(EmType.surprise.name) \(pg)%";
        pg_surprised.progress = Float(pg) / 100 ;
        //========================================
        pg = 0;
        if( t_disgust > 0 ){
            pg = c_disgust  * 100 / t_disgust  ;
        }
        
        lb_disgust.text = "\(EmType.disgust.name) \(pg)%";
        pg_disgust.progress = Float(pg) / 100 ;
        
    }

}

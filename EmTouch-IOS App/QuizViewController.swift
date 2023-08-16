//
//  QuizViewController.swift
//  ARKit-CoreML-Emotion-Classification
//
//  Created by Samantha on 2023/3/25.
//

import UIKit

class QuizViewController: UIViewController {

    
    
    

    
    var question_no : Int = 1
    let question_total : Int = 10
    
    var question_seq :[UIImage]=[]
    var question_seq_name :[String]=[]
    var question_opt1 :[EmType]=[]
    var question_opt2 :[EmType]=[]
    var question_res  :[EmType]=[]
    var question_quiz  :[EmType]=[]
    
    @IBOutlet weak var optbtn_left: UIButton!
    @IBOutlet weak var optbtn_right: UIButton!
    @IBOutlet weak var qno_label: UILabel!
    @IBOutlet weak var finish_button: UIButton!
    @IBOutlet weak var target_button: UIButton!
    @IBOutlet weak var target_img: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        target_img.layer.cornerRadius = 15
        
        

        reset_questions()
        
        update_qno()
    }
    
    func save_result(){
        let data = UserDefaults.standard
        
        var t_sad = data.integer( forKey: "t_sad")
        var t_fear = data.integer( forKey: "t_fear")
        var t_angry = data.integer( forKey: "t_angry")
        var t_disgust =  data.integer( forKey: "t_disgust")
        var t_surprised = data.integer( forKey: "t_surprised")
        var t_happy = data.integer( forKey: "t_happy")
        
        var c_sad = data.integer( forKey: "c_sad")
        var c_fear = data.integer( forKey: "c_fear")
        var c_angry = data.integer( forKey: "c_angry")
        var c_disgust = data.integer( forKey: "c_disgust")
        var c_surprised = data.integer( forKey: "c_surprised")
        var c_happy = data.integer( forKey: "c_happy")
        
        
        var i=0
        for _ in question_quiz {
            
            let target = question_quiz[i]
            
            var correct = false
            if( target == question_res[i] ){
                correct = true
            }
            
            switch (target){
            case .sad:
                t_sad = t_sad + 1
                if( correct ){
                    c_sad = c_sad + 1
                }
            case .happy:
                t_happy = t_happy + 1
                if( correct ){
                    c_happy = c_happy + 1
                }
            case .surprise:
                t_surprised = t_surprised + 1
                if( correct ){
                    c_surprised = c_surprised + 1
                }
            case .none:
                break
            case .angry:
                t_angry = t_angry + 1
                if( correct ){
                    c_angry = c_angry + 1
                }
            case .disgust:
                t_disgust = t_disgust + 1
                if( correct ){
                    c_disgust = c_disgust + 1
                }
            case .fear:
                t_fear = t_fear + 1
                if( correct ){
                    c_fear = c_fear + 1
                }
            }
            i = i + 1
        }
        
        data.setValue(t_sad, forKey: "t_sad")
        data.setValue(t_fear, forKey: "t_fear")
        data.setValue(t_angry, forKey: "t_angry")
        data.setValue(t_disgust, forKey: "t_disgust")
        data.setValue(t_surprised, forKey: "t_surprised")
        data.setValue(t_happy, forKey: "t_happy")
        
        data.setValue(c_sad, forKey: "c_sad")
        data.setValue(c_fear, forKey: "c_fear")
        data.setValue(c_angry, forKey: "c_angry")
        data.setValue(c_disgust, forKey: "c_disgust")
        data.setValue(c_surprised, forKey: "c_surprised")
        data.setValue(c_happy, forKey: "c_happy")
    }
    
    func update_qno(){
        
        let idx = question_no-1
        
        qno_label.text = "\(question_no) / \(question_total)"
        target_img.image = question_seq[idx]
        
        
        
        let s1:String = "  \(question_opt1[idx].name)"
        optbtn_left.setTitle(s1, for: .normal)
        optbtn_left.setImage(UIImage(named: question_opt1[idx].name_img), for: .normal)
        
        let s2:String = "  \(question_opt2[idx].name)"
        optbtn_right.setTitle(s2, for: .normal)
        optbtn_right.setImage(UIImage(named: question_opt2[idx].name_img), for: .normal)
        
        if question_res[idx] == EmType.none {
            target_button.setTitle("（請選擇）" , for: .normal)
            target_button.setImage(UIImage(systemName: "faceid"), for: .normal)
            
            
            
        }else{
            target_button.setTitle("  \(question_res[idx].name)" , for: .normal)
            target_button.setImage(UIImage(named: question_res[idx].name_img), for: .normal)
        

            
        }
        
        finish_button.isEnabled = false
        if( check_finished() ){
            save_result()
            finish_button.isEnabled = true
        }
        
    }
    
    
    
    func reset_questions(){
        for _ in 1...question_total {
            var tr1 = EmType.allCases.randomElement()
            while tr1 == EmType.none {
                tr1 = EmType.allCases.randomElement()
            }
            var tr2 = EmType.allCases.randomElement()
            while tr1==tr2 || tr2 == EmType.none{
                tr2 = EmType.allCases.randomElement()
            }
            //there are 32 items in each type
            let r = Int.random(in: 0..<32)
            let fname = tr1!.tag+"\(r)"
            //print(fname)
            question_seq_name.append( fname )
            question_seq.append(UIImage(named:fname)!)
            
            if Int.random(in: 0...9)<5{
                question_opt1.append(tr1!)
                question_opt2.append(tr2!)
            }else{
                question_opt1.append(tr2!)
                question_opt2.append(tr1!)
            }
            question_res.append( EmType.none)
            question_quiz.append(tr1!)
        }
    }
    
    func check_finished()->Bool{
        for r in question_res
        {
            if (r == EmType.none) {
                return false
            }
        }
        return true
    }
    
    @IBAction func pre_button(_ sender: Any) {
        if question_no > 1 {
            question_no = question_no-1
        }
        update_qno()
    }
    
    @IBAction func next_button(_ sender: Any) {
        if question_no<question_total{
            question_no=question_no+1
        }
        update_qno()
    }
    
    
    @IBAction func left_opt_button(_ sender: Any) {
        
        let idx = question_no-1
        question_res[idx] = question_opt1[idx]
        
        update_qno()
    }
    
    @IBAction func right_opt_button(_ sender: Any) {
        
        let idx = question_no-1
        question_res[idx] = question_opt2[idx]
        
        update_qno()
    }
    
    
    @IBAction func save_result(_ sender: Any) {
        
       
    }
    /*
    // MARK: - Navigation

     @IBOutlet weak var target_label: UILabel!
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

enum EmType:CaseIterable{
    case angry
    case disgust
    case fear
    case sad
    case happy
    case surprise
    case none
    
    var name:String{
        switch self{
        case .angry:
            return "生氣 Angry"
        case .disgust:
            return "厭惡 Disgust"
        case .fear:
            return "害怕 Fear"
        case .sad:
            return "難過 Sad"
        case .happy:
            return "開心 Happy"
        case .surprise:
            return "驚訝 Surprised"
        case .none:
            return "none"
        }
    }
    
    var name_img:String{
        switch self{
        case .angry:
            return "angry"
        case .disgust:
            return "disgust"
        case .fear:
            return "fear"
        case .sad:
            return "sad"
        case .happy:
            return "happy"
        case .surprise:
            return "surprise"
        case .none:
            return "none"
        }
    }
    
    var tag:String{
        switch self{
        case .angry:
            return "A"
        case .disgust:
            return "D"
        case .fear:
            return "F"
        case .sad:
            return "S"
        case .happy:
            return "H"
        case .surprise:
            return "U"
        case .none:
            return "_"
        }
    }
}

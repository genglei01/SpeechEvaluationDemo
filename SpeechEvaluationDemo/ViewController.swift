//
//  ViewController.swift
//  SpeechEvaluationDemo
//
//  Created by LeoGeng on 17/04/2017.
//  Copyright © 2017 LeoGeng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    fileprivate var _speechEvaluator:IFlySpeechEvaluator?
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    
    @IBOutlet weak var lblXml: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _speechEvaluator = IFlySpeechEvaluator.sharedInstance()
        _speechEvaluator?.delegate = self
        
        _speechEvaluator?.setParameter("", forKey: IFlySpeechConstant.params())
        _speechEvaluator?.setParameter("1600", forKey: IFlySpeechConstant.sample_RATE())
        _speechEvaluator?.setParameter("utf-8", forKey: IFlySpeechConstant.text_ENCODING())
        _speechEvaluator?.setParameter("xml", forKey: IFlySpeechConstant.result_TYPE())
        _speechEvaluator?.setParameter("5000", forKey: IFlySpeechConstant.vad_BOS())
        _speechEvaluator?.setParameter("3000", forKey: IFlySpeechConstant.vad_EOS())
        _speechEvaluator?.setParameter("read_sentence", forKey: IFlySpeechConstant.ise_CATEGORY())
        _speechEvaluator?.setParameter("en_us", forKey: IFlySpeechConstant.language())
        _speechEvaluator?.setParameter("5000", forKey: IFlySpeechConstant.speech_TIMEOUT())
        _speechEvaluator?.setParameter("eva.pcm", forKey: IFlySpeechConstant.ise_AUDIO_PATH())
        
        self.setExclusiveTouchForButtons()
        
    }
    
    private func setExclusiveTouchForButtons(){
        self.view.subviews.forEach(){ subView in
            if let btn = subView as? UIButton{
                btn.isExclusiveTouch = true
            }
        }
    }
    
    @IBAction func tapReadButton(_ sender: Any) {
        if let data = self.txtView.text!.data(using: String.Encoding.utf8){
            _speechEvaluator?.startListening(data, params: nil)
            self.lblMsg.isHidden = false
            self.lblResult.text = ""
            lblXml.text = ""
        }
    }
    
    fileprivate func getErrorText(dict:[Int:[Int]])->NSAttributedString{
        let attrString = NSMutableAttributedString(string: self.txtView.text!)
        let sentences = self.txtView.text!.components(separatedBy: ".")
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        attrString.addAttributes([NSFontAttributeName:self.txtView.font!,NSParagraphStyleAttributeName:style], range: NSRange(location: 0, length: self.txtView.text.characters.count))
        
        var indexOfSentence = 0
        var startIndex = 0
        sentences.forEach(){ sentence in
            let wrongWordsIndex = dict[indexOfSentence]
            
            if wrongWordsIndex != nil{
                let words = sentence.components(separatedBy: CharacterSet.whitespacesAndNewlines)
                
                var wordIndexInCurrentSentence = 0
                words.forEach(){ word in
                    if wrongWordsIndex!.contains(wordIndexInCurrentSentence){
                        let wrongWord = words[wordIndexInCurrentSentence]
                        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: startIndex, length: wrongWord.characters.count))
                    }
                    
                    wordIndexInCurrentSentence += 1
                    startIndex += word.characters.count + 1
                }
            }else{
                startIndex += sentence.characters.count + 1
            }
            
            indexOfSentence += 1
        }
        
        return attrString
        
    }
}


extension ViewController:IFlySpeechEvaluatorDelegate{
    public func onResults(_ results: Data!, isLast: Bool) {
        if isLast {
            let parser = EvaluationResultParser(data: results)
            lblResult.text = "\(parser.totalScore)"
            txtView.attributedText = self.getErrorText(dict: parser.getWrongWordsIndex())
            lblXml.text = parser.xml
        }
    }
    
    public func onError(_ errorCode: IFlySpeechError!) {
        print(errorCode.errorDesc)
        self.lblMsg.isHidden = true
    }
    
    public func onCancel() {
        self.lblMsg.isHidden = true
    }
    
    public func onEndOfSpeech() {
        self.lblMsg.isHidden = true
    }
    
    public func onBeginOfSpeech() {
        
    }
    
    public func onVolumeChanged(_ volume: Int32, buffer: Data!) {
        
    }
}


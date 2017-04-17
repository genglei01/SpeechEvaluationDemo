//
//  EvaluationResultParser.swift
//  VoiceEvaluation
//
//  Created by LeoGeng on 11/04/2017.
//  Copyright © 2017 LeoGeng. All rights reserved.
//

import Foundation
import AEXML

class EvaluationResultParser {
    private var _xmlDoc:AEXMLDocument?
    
    var totalScore:Float{
        get{
            let strScore = _xmlDoc?.root["read_sentence"]["rec_paper"]["read_chapter"].first?.attributes["total_score"] ?? "0"
            let score = Float(strScore) ?? 0
            return  round(score * 100)/100
        }
    }
    
    var xml:String{
        get{
            return _xmlDoc?.xml ?? ""
        }
    }
    
    init(data:Data) {
        _xmlDoc = try? AEXMLDocument(xml: data)
        print(_xmlDoc?.xml ?? "")
    }
    
    func getWrongWordsIndex() -> [Int:[Int]]{
        var dict = [Int:[Int]]()
        _xmlDoc?.root["read_sentence"]["rec_paper"]["read_chapter"].children.forEach(){ sentence in
            var arr = [Int]()
            sentence.children.forEach(){word in
                let score = Float((word.attributes["total_score"] ?? "0")) ?? 0
                if score < 2{
                    let index = Int((word.attributes["index"] ?? "-1")) ??  -1
                    if index != -1{
                        arr.append(index)
                    }
                }
            }
            
            let index = Int((sentence.attributes["index"] ?? "-1")) ??  -1
            if index != -1 && arr.count > 0{
                dict[index] = arr
            }
        }
        
        return dict
    }
}

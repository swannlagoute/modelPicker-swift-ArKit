//
//  Model.swift
//  ModelPickerAr
//
//  Created by macbookpro on 19/10/2022.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var Cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        
        self.Cancellable = ModelEntity.loadModelAsync(named: filename).sink(receiveCompletion: { loadCompletion in
            //Handler error
            print("DEBUG: Unable to load modelEntity for modelName: \(self.modelName)")
        },receiveValue: {modelEntity in
            //Get our modelEntity
            self.modelEntity = modelEntity
            print("DEBUG: successfully loaded modelEntity for modelName")
        })
    }
}

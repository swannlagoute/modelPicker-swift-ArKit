//
//  ContentView.swift
//  ModelPickerAr
//
//  Created by macbookpro on 17/10/2022.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView : View {
    
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedPlacement: Model?
    
    private var models: [Model] = {
        //Dynamically get our models file name
        let fileManager = FileManager.default
        guard let path = Bundle.main.resourcePath, let files = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        var availableModels: [Model] = []
        for filename in files where filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            
            let model = Model(modelName: modelName)
            
            availableModels.append(model)
        }
        return availableModels
    }()
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedPlacement: self.$modelConfirmedPlacement)
            
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnable: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedPlacement: self.$modelConfirmedPlacement)
            } else {
                ModelsPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var modelConfirmedPlacement: Model?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = CustomArView(frame: .zero)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelConfirmedPlacement {
            
            if let modelEntity = model.modelEntity {
                print("DEBUG: adding model to scene: \(model.modelName)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                
                uiView.scene.addAnchor(anchorEntity)
            } else {
                print("DEBUG: enable to load modelEntity for: \(model.modelName)")
            }
            
            DispatchQueue.main.async {
                self.modelConfirmedPlacement = nil
            }
        }
    }
}

class CustomArView: ARView {
    let focusSquare = FESquare()
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        focusSquare.viewDelegate = self
        focusSquare.delegate = self
        focusSquare.setAutoUpdate(to: true)
        
        self.setUpArView()
    }
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpArView() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        self.session.run(config)
    }
}

extension CustomArView: FEDelegate {
    func toTrackingState() {
        print("tracking")
    }
    func toInitializingState() {
        print("initializing")
    }
}

struct ModelsPickerView: View {
    
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in
                    Button(action: {
                        print("DEBUG: selected models with names: \(self.models[index].modelName)")
                        self.selectedModel = self.models[index]
                        self.isPlacementEnabled = true
                    }) {
                        Image(uiImage:self.models[index].image).resizable().frame(height: 80).aspectRatio(1/1, contentMode: .fit).background(Color.white).cornerRadius(12)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }.padding(20)
         .background(Color.black.opacity(0.5))
         
    }
}

struct PlacementButtonsView: View {
    
    @Binding var isPlacementEnable: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedPlacement: Model?
    
    var body: some View {
        HStack {
            //Cancel Button
            Button(action: {
                print("DEBUG: Cancel model placement")
                self.resetPlacementParameter()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
            }
            //Confirm Button
            Button(action: {
                print("DEBUG: Confirm model placement")
                self.modelConfirmedPlacement = self.selectedModel
                self.resetPlacementParameter()
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
            }
        }
    }
    func resetPlacementParameter() {
        self.isPlacementEnable = false
        self.selectedModel = nil
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

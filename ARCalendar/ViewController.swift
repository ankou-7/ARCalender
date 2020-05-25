//
//  ViewController.swift
//  ARCalendar
//
//  Created by 安江洸希 on 2020/05/17.
//  Copyright © 2020 安江洸希. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var textview: UIView!
    var textlabel: UILabel!

    var sceneView: ARSCNView!
    var isExistScreen = false
    //var plane:SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // 背景を黒色に
        //sceneView.backgroundColor = UIColor.black
        
        //カメラ位置をタップでコントロール可能にする(ダブルタップで元のカメラ位置に戻る）
        //sceneView.allowsCameraControl = true
        
        // 描画パフォーマンス情報を表示
        //sceneView.showsStatistics = true
        
        // デバッグ用設定
        // 検出した3D空間の特徴点を表示する
        sceneView.debugOptions = [.showFeaturePoints]
        
        ///
        //736,414
        let screenWidth:CGFloat = view.frame.size.width
        //let screenHeight:CGFloat = view.frame.size.height
        textview = UIView(frame: CGRect(x: screenWidth-110, y: 50, width: 100, height: 50))
        textview.backgroundColor = UIColor.black
        self.view.addSubview(textview)
        
        textlabel = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: 50))
        textlabel.text = "メモを書く"
        textlabel.textColor = UIColor.white
        textview.addSubview(textlabel)
        
        // タップジェスチャーを作成します。
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.singleTap))
        // シングルタップで反応するように設定します。
        singleTapGesture.numberOfTapsRequired = 1
        // ビューにジェスチャーを設定します。
        textview.addGestureRecognizer(singleTapGesture)
        
        ///
        
//        // Create a new scene
//        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
//        // シーンを生成
//        let scene = SCNScene()
//
//        // Set the scene to the view
//        sceneView.scene = scene
//
//        //geometry(形状を作成）
//        let planeGeometry = SCNPlane(width: 0.5,height: 0.5)
//        //色を指定
//        planeGeometry.firstMaterial?.diffuse.contents = UIColor.black
//        //SCNNodeに入れる
//        let planeNode = SCNNode(geometry: planeGeometry)
//
//        planeNode.position = SCNVector3Make(0, 0, -0.5)
//        planeNode.eulerAngles.x = -Float.pi/2
//        planeNode.opacity = 0.9
//
//        sceneView.scene.rootNode.addChildNode(planeNode)
        
    }
    
    @objc func singleTap(_ gesture: UITapGestureRecognizer) {
        // シングルタップされた時の処理を記述してください。
        print("tapped")
        let nextvc = writememo()
        nextvc.view.backgroundColor = UIColor.white
        self.present(nextvc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // 平面検出 (水平・垂直) が有効になるように設定
        configuration.planeDetection = [.vertical]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func createbox(from anchor: ARPlaneAnchor) -> SCNNode{
        //geometry(形状を作成）
        let boxGeometry = SCNBox(width: 0.2, height: 0.4, length: 0.1, chamferRadius: 0)
        //色を指定
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.white//(white: 0.0, alpha: 0.9)
        //SCNNodeに入れる
        let boxNode = SCNNode(geometry: boxGeometry)
        
        boxNode.position = SCNVector3Make(0, 0, -0.5)
        //boxNode.eulerAngles.x = -Float.pi/2 //傾き
        //boxNode.opacity = 0.9 //明度

        return boxNode
    }
    
    // 新しいアンカーに対応するノードがシーンに追加されたときに呼び出される
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return  }
//
//        let floor = createbox(from: planeAnchor)
//        node.addChildNode(floor)
        
        if self.isExistScreen {return} //１回呼ばれていたらそれ以降はノードを作らないようにする
        if let planeAnchor = anchor as? ARPlaneAnchor {
            self.isExistScreen = true
        //位置とサイズによる平面ノードの追加
            let plane = SCNNode()
            let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                    height: CGFloat(planeAnchor.extent.z))
            
            //UIKitベース
            self.createViewController(for: plane)
            //SwiftUIベース
            //self.createHostingController(for: plane)
                        
            plane.geometry = geometry
            plane.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)

            node.addChildNode(plane)
        }
        
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor,
//                   let planeNode = node.childNodes.first,
//                   let planeNodeGeometry = planeNode.geometry as? SCNPlane
//            else { return }
//
//        let updatedPosition = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
//        planeNode.position = updatedPosition
//
//        planeNodeGeometry.width  = CGFloat(planeAnchor.extent.x)
//        planeNodeGeometry.height = CGFloat(planeAnchor.extent.z)
//    }
    
//    func createHostingController(for node: SCNNode) {
//        // create a hosting controller with SwiftUI view
//        let arVC = UIHostingController(rootView:WatchViewController())
//        // Do this on the main thread
//        DispatchQueue.main.async {
//            arVC.willMove(toParent: self)
//            // make the hosting VC a child to the main view controller
//            self.addChild(arVC)
//            // 表示する大きさの指定（基準点（左上）からの位置、x,yからの位置）
//            arVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 800)
////            // add the ar card view as a subview to the main view
//            self.view.addSubview(arVC.view)
//            // render the view on the plane geometry as a material
//            self.shows(hostingVC: arVC, on: node)
//        }
//    }
//    func shows(hostingVC: UIHostingController<WatchViewController>, on node: SCNNode) {
//        // create a new material
//        let material = SCNMaterial()
//        // 背景をtrue/不透明、false/透明にする
//        hostingVC.view.isOpaque = false
//        // set the diffuse of the material to the view of the Hosting View Controller
//        material.diffuse.contents = hostingVC.view
//        // Set the material to the geometry of the node (plane geometry)
//        node.geometry?.materials = [material]
//        hostingVC.view.backgroundColor = UIColor.black
//    }
    //
    func createViewController(for node: SCNNode) {
        
        DispatchQueue.main.async {
            let arVC = ARCalendar()
            arVC.willMove(toParent: self)
            // make the hosting VC a child to the main view controller
            self.addChild(arVC)
            // set the pixel size of the Card View
            arVC.view.frame = CGRect(x: 0, y: 0, width: 850, height: 600)//width: 736, height: 414
            // add the ar card view as a subview to the main view
            self.view.addSubview(arVC.view)
            // render the view on the plane geometry as a material
            self.shows(hostingVC: arVC, on: node)
        }
    }
    func shows(hostingVC: UIViewController, on node: SCNNode) {
        // create a new material
        let material = SCNMaterial()
        // this allows the card to render transparent parts the right way
        hostingVC.view.isOpaque = false
        // set the diffuse of the material to the view of the Hosting View Controller
        material.diffuse.contents = hostingVC.view
        // Set the material to the geometry of the node (plane geometry)
        node.geometry?.materials = [material]
        hostingVC.view.backgroundColor = UIColor.clear
    }
}

//struct ViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
//    }
//}

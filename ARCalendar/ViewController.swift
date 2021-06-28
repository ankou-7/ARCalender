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
import MultipeerConnectivity

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    var textview: UIView!
    var textlabel: UILabel!
    var savebutton: UIButton!
    var reworldbutton: UIButton!
    var mappingStatusLabel: UILabel! //world mapのマッピングのステータス状態を表示
    var sendMapbutton: UIButton! //world map送信用ボタン
    var sessionInfoLabel: UILabel! //端末の接続状況の表示

    @IBOutlet var sceneView: ARSCNView!
    var isExistScreen = false
    var re_world_pressed = false
    
    var multipeerSession: MultipeerSession! //通信用
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
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
        
        savebutton = UIButton(frame: CGRect(x: 10, y: 50, width: 80, height: 80))
        savebutton.backgroundColor = UIColor.yellow
        savebutton.setTitle("保存", for: .normal)
        savebutton.addTarget(self, action: #selector(saveworld), for: .touchUpInside)
        self.view.addSubview(savebutton)
        
        sendMapbutton = UIButton(frame: CGRect(x: 100, y: 50, width: 80, height: 80))
        sendMapbutton.backgroundColor = UIColor.blue
        sendMapbutton.setTitle("送信", for: .normal)
        sendMapbutton.addTarget(self, action: #selector(sendMap), for: .touchUpInside)
        self.view.addSubview(sendMapbutton)
        
        sessionInfoLabel = UILabel(frame: CGRect(x: 100, y: 150, width: 500, height: 80))
        sessionInfoLabel.backgroundColor = UIColor.lightGray
        sessionInfoLabel.text = "端末間の接続"
        self.view.addSubview(sessionInfoLabel)
        
        reworldbutton = UIButton(frame: CGRect(x: 10, y: 150, width: 80, height: 80))
        reworldbutton.backgroundColor = UIColor.red
        reworldbutton.setTitle("再現", for: .normal)
        reworldbutton.addTarget(self, action: #selector(Reworld), for: .touchUpInside)
        self.view.addSubview(reworldbutton)
        
        mappingStatusLabel = UILabel(frame: CGRect(x: 10, y: 250, width: 100, height: 100))
        mappingStatusLabel.backgroundColor = UIColor.green
        mappingStatusLabel.text = "通信部"
        self.view.addSubview(mappingStatusLabel)
        
        // タップジェスチャーを作成します。
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.singleTap))
        // シングルタップで反応するように設定します。
        singleTapGesture.numberOfTapsRequired = 1
        // ビューにジェスチャーを設定します。
        textview.addGestureRecognizer(singleTapGesture)
        
        //ジェスチャーの追加
        let gesture = UITapGestureRecognizer(target: self, action:#selector(onTap))
        self.sceneView.addGestureRecognizer(gesture)
        
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
    
    //world mapの保存を行う
    @objc func saveworld() {
        print("保存")
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("can't encode map") }
            UserDefaults.standard.set(data, forKey: "hello_world")
        }
    }
    
    //生成されたWorldMapをデータ型に変換して送信する
    @objc func sendMap(_ button: UIButton) {
        print("送信")
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("can't encode map") }
            self.multipeerSession.sendToAllPeers(data) //worl mapのデータ型を送信
        }
    }
    
    //通信用
    var mapProvider: MCPeerID?
    //送信したデータを受け取ってworld mapを再現する
    func receivedData(_ data: Data, from peer: MCPeerID) {
        
        do {
            if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                // Run the session with the received world map.
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = .horizontal
                configuration.initialWorldMap = worldMap //保存したWorldMapで再開する
                sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                
                // Remember who provided the map for showing UI feedback.
                mapProvider = peer
            }
            else
            if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
                // Add anchor to the session, ARSCNView delegate adds visible content.
                sceneView.session.add(anchor: anchor)
            }
            else {
                print("unknown data recieved from \(peer)")
            }
        } catch {
            print("can't decode data recieved from \(peer)")
        }
    }
    
    //保存したworld mapを再現する
    @objc func Reworld() {
        print("reworld")
        let data = UserDefaults.standard.data(forKey: "hello_world")
        if let worldMap = try! NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data!) {
            // Run the session with the received world map.
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.vertical, .horizontal]
            configuration.initialWorldMap = worldMap //保存したWorldMapで再開する
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
        self.re_world_pressed = true
    }
    
    @objc func singleTap(_ gesture: UITapGestureRecognizer) {
        // シングルタップされた時の処理を記述してください。
        print("tapped")
        let nextvc = writememo()
        nextvc.view.backgroundColor = UIColor.white
        self.present(nextvc, animated: true, completion: nil)
    }
    
    //ビュー表示時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.re_world_pressed {
            print("通常時")
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            // 平面検出 (水平・垂直) が有効になるように設定
            configuration.planeDetection = [.vertical, .horizontal]
            // Run the view's session
            sceneView.session.run(configuration)
        }
        else {
            print("再現時")
            let data = UserDefaults.standard.data(forKey: "hello_world")
            if let worldMap = try! NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data!) {
                // Run the session with the received world map.
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = .horizontal
                configuration.initialWorldMap = worldMap //保存したWorldMapで再開する
                sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            }
        }
        
    }
    
    //ビュー非表示時に呼ばれる
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
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // frame.worldMappingStatus
        print(frame.worldMappingStatus)
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            sendMapbutton.isEnabled = false
        case .extending:
            sendMapbutton.isEnabled = !multipeerSession.connectedPeers.isEmpty
        case .mapped:
            sendMapbutton.isEnabled = !multipeerSession.connectedPeers.isEmpty
        @unknown default:
            sendMapbutton.isEnabled = false
        }
        mappingStatusLabel.text = frame.worldMappingStatus.description //world mapのマッピングの状況を表示
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState) //端末の接続状況を表示
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty && multipeerSession.connectedPeers.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move around to map the environment, or wait to join a shared session."
            
        case .normal where !multipeerSession.connectedPeers.isEmpty && mapProvider == nil:
            let peerNames = multipeerSession.connectedPeers.map({ $0.displayName }).joined(separator: ", ")
            message = "Connected with \(peerNames)."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing) where mapProvider != nil,
             .limited(.relocalizing) where mapProvider != nil:
            message = "Received map from \(mapProvider!.displayName)."
            
        case .limited(.relocalizing):
            message = "Resuming session — move to where you were when the session was interrupted."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = "default"
            
        }
        
        sessionInfoLabel.text = message
        //sessionInfoView.isHidden = message.isEmpty
    }
    
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
    
    @objc func onTap(sender: UITapGestureRecognizer) {
        //タップ位置の取得
        let location = sender.location(in: sceneView)

        //ヒットテスト（タップされた位置のARアンカーを探す）
        let hitTest = sceneView.hitTest(location, types: .existingPlaneUsingExtent) //タップした箇所が平面内かどうか
        if !hitTest.isEmpty {
            //ARアンカーの追加
            let anchor = ARAnchor(name:"calendar", transform: hitTest.first!.worldTransform)
            sceneView.session.add(anchor: anchor)
            
        }
    }
    
    // 新しいアンカーに対応するノードがシーンに追加されたときに呼び出される
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return  }
//
//        let floor = createbox(from: planeAnchor)
//        node.addChildNode(floor)
        
            DispatchQueue.main.async {
                if self.isExistScreen {
//                    print("存在")
//                    let configuration = ARWorldTrackingConfiguration()
//                    configuration.planeDetection = [.vertical, .horizontal]
//                    self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//                    self.isExistScreen = false
                    return
                } //１回呼ばれていたらそれ以降はノードを作らないようにする
                    
                //ARAnchorのnameがmodelの時
                if anchor.name == "calendar" {
                    //let planeAnchor = anchor as? ARPlaneAnchor
                    //カレンダー追加部分
                    let plane = SCNNode()
                    plane.name = "ar_calendar"
                    let geometry = SCNPlane(width: CGFloat(0.3),
                                            height: CGFloat(0.3))
                    //UIKitベース
                    self.createViewController(for: plane)
                    //SwiftUIベース
                    //self.createHostingController(for: plane)

                    plane.geometry = geometry
                    plane.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)

                    node.addChildNode(plane)
                    
                    //self.isExistScreen = true
                }
                
//                if let planeAnchor = anchor as? ARPlaneAnchor {
//
//                    //検出した面を視認できるようにする
//                    let planeNode = SCNNode()
//                    let geometry2 = SCNPlane(
//                        width: CGFloat(planeAnchor.extent.x),
//                        height: CGFloat(planeAnchor.extent.z))
//                    geometry2.materials.first?.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
//                    planeNode.geometry = geometry2
//                    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
//                    node.addChildNode(planeNode)
//
//                }
                
            }
        
    }
    
    //平面検出をするたびに更新していく
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

//        DispatchQueue.main.async {
//            if self.isExistScreen {return}
//
//            //ARPlaneAnchorの時
//            if let planeAnchor = anchor as? ARPlaneAnchor {
//                //位置とサイズの更新
//                guard let planeNode = node.childNodes.first,
//                let geometry = planeNode.geometry as? SCNPlane else {fatalError()}
//                planeNode.simdPosition = SIMD3<Float>(planeAnchor.center.x, 0, planeAnchor.center.z)
//                geometry.width = CGFloat(planeAnchor.extent.x)
//                geometry.height = CGFloat(planeAnchor.extent.z)
//            }
//        }
    }
    
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
    
}

//struct ViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
//    }
//}

extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .extending:
            return "Extending"
        case .mapped:
            return "Mapped"
        @unknown default:
            return "Unknown"
        }
    }
}

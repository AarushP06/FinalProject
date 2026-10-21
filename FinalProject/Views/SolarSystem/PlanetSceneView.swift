//
//  PlanetSceneView.swift
//  FinalProject
//

import SwiftUI
import SceneKit
import UIKit

/// A slowly spinning 3D sphere. Drag to rotate, pinch to zoom
/// (SceneKit's built-in camera control).
struct PlanetSceneView: View {
    @State private var planetScene: PlanetScene

    init(colorHex: String) {
        // Build the scene once, so it isn't recreated every time SwiftUI redraws.
        _planetScene = State(initialValue: PlanetScene.make(colorHex: colorHex))
    }

    var body: some View {
        SceneView(scene: planetScene.scene,
                  pointOfView: planetScene.camera,
                  options: [.allowsCameraControl, .autoenablesDefaultLighting])
    }
}

/// Holds the SceneKit scene and its camera.
struct PlanetScene {
    let scene: SCNScene
    let camera: SCNNode

    /// TODO (Prompt 3): use a texture image instead of a flat color, and add Saturn's rings.
    static func make(colorHex: String) -> PlanetScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black

        let sphere = SCNSphere(radius: 1)
        sphere.segmentCount = 96
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(hex: colorHex)
        sphere.materials = [material]

        let planetNode = SCNNode(geometry: sphere)
        planetNode.runAction(.repeatForever(.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 20)))
        scene.rootNode.addChildNode(planetNode)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 3.2)
        scene.rootNode.addChildNode(cameraNode)

        return PlanetScene(scene: scene, camera: cameraNode)
    }
}

#Preview {
    PlanetSceneView(colorHex: "#C1440E")
        .frame(height: 320)
}

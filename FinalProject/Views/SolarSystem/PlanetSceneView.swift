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

    init(planetName: String, colorHex: String, textureName: String? = nil) {
        // Build the scene once, so it isn't recreated every time SwiftUI redraws.
        _planetScene = State(initialValue: PlanetScene.make(planetName: planetName,
                                                            colorHex: colorHex,
                                                            textureName: textureName))
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

    static func make(planetName: String, colorHex: String, textureName: String?) -> PlanetScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black

        let sphere = SCNSphere(radius: 1)
        sphere.segmentCount = 96
        let material = SCNMaterial()
        let assetName = textureName ?? "\(planetName.lowercased())_texture"
        if let texture = UIImage(named: assetName) {
            material.diffuse.contents = texture
        } else {
            material.diffuse.contents = UIColor(hex: colorHex)
        }
        sphere.materials = [material]

        let planetNode = SCNNode(geometry: sphere)
        planetNode.runAction(.repeatForever(.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 20)))
        scene.rootNode.addChildNode(planetNode)

        if planetName == "Saturn" {
            // A thin annulus stays tilted while the planet spins inside it.
            let rings = SCNTube(innerRadius: 1.2, outerRadius: 1.75, height: 0.02)
            rings.radialSegmentCount = 128
            let ringMaterial = SCNMaterial()
            ringMaterial.diffuse.contents = UIColor(red: 0.85, green: 0.77, blue: 0.59, alpha: 1)
            ringMaterial.transparency = 0.65
            ringMaterial.isDoubleSided = true
            rings.materials = [ringMaterial]

            let ringNode = SCNNode(geometry: rings)
            ringNode.eulerAngles.x = .pi / 3
            scene.rootNode.addChildNode(ringNode)
        }

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 3.2)
        scene.rootNode.addChildNode(cameraNode)

        return PlanetScene(scene: scene, camera: cameraNode)
    }
}

#Preview {
    PlanetSceneView(planetName: "Mars", colorHex: "#C1440E")
        .frame(height: 320)
}

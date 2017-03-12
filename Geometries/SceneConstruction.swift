/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SceneConstruction.swift                                                               Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Mar12/17  ..  Copyright © 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable large_tuple
// swiftlint:disable variable_name
// swiftlint:disable statement_position

import SceneKit
import SatKit

// MARK: - Scene construction functions ..

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ "construct(scene:)"                                                                              ┃
  ┃                                                                                                  ┃
  ┃  .. sets some properties on the window's NSView (SceneView) including an overlayed SpriteKit     ┃
  ┃     placard which will display data and take hits.                                               ┃
  ┃                                                                                                  ┃
  ┃  .. gets the rootNode in that SceneView ("total") and attaches various other nodes:              ┃
  ┃     "frame" is a comes from the SceneKit file "com.ramsaycons.geometries.scn" and represents     ┃
  ┃             the inertial frame and it never directly transformed. It contains the "earth" node   ┃
  ┃             which is composed of a solid sphere ("globe"), graticule marks ("grids'), and the    ┃
  ┃             geographic coastlines, lakes , rivers, etc ("coast").                                ┃
  ┃                                                                                                  ┃
  ┃                              +--------------------------------------------------------------+    ┃
  ┃ SCNView.scene.rootNode       |                              "com.ramsaycons.geometries.scn" |    ┃
  ┃     == Node("total") ---+----|  Node("frame") --------+                                     |    ┃
  ┃                         |    |                        |                                     |    ┃
  ┃                         |    |                        +-- Node("earth") --+                 |    ┃
  ┃                              |                        |                   +-- Node("globe") |    ┃
  ┃                              |                        |                   +-- Node("grids") |    ┃
  ┃                              |                        |                   +-- Node("coast") |    ┃
  ┃                              +------------------------|-------------------------------------+    ┃
  ┃                                                                                                  ┃
  ┃             "construct(scene:)" adds nodes programmatically to represent other objects; It adds  ┃
  ┃             the light of the sun ("solar"), rotating once a year in inertial coordinates to the  ┃
  ┃             "frame", and the observer ("obsvr") to the "earth".                                  ┃
  ┃                                                                                                  ┃
  ┃             "construct(scene:)" also adds a 'double node' to represent to external viewer; a     ┃
  ┃             node at a fixed distant radius ("orbit"), with a camera ("camra") pointing to the    ┃
  ┃             the frame center.                                                                    ┃
  ┃                                                                                                  ┃
  ┃                         |                                                                        ┃
  ┃                         |                                                                        ┃
  ┃                         +-- Node("orbit") --+        +-- Node("spots")   +-- Node("obsvr")       ┃
  ┃                                             |        |                                           ┃
  ┃                                             |        +-- Node("light"+"solar")                   ┃
  ┃                                             |                                                    ┃
  ┃                                             +-- Node("camra")                                    ┃
  ┃                                                                                                  ┃
  ┃         Satellites also moving in the inertial frame but they are not added to the scene         ┃
  ┃         by this "construct(scene:)".                                                             ┃
  ┃                                                                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func construct(scene totalView: SceneView) {
    print("ViewController.sceneConstruction()")

    totalView.scene = SCNScene()
    totalView.backgroundColor = NSColor.blue
    totalView.autoenablesDefaultLighting = true
    totalView.showsStatistics = true

    if let overlay = OverlayScene(fileNamed:"OverlayScene") { totalView.overlaySKScene = overlay }

    guard let totalNode = totalView.scene?.rootNode,
          let frameScene = SCNScene(named: "com.ramsaycons.frame.scn"),
          let frameNode = frameScene.rootNode.childNode(withName: "frame", recursively: true),
          let earthNode = frameNode.childNode(withName: "earth", recursively: true) else { return }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ by here we have "frameNode" and "earthNode" ..                                                   ╎
  ╎ .. next, label "frameNode" as "frame"                                                            ╎
  ╎ .. and make "earthNode" a subnode of "frameNode"                                                 ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    totalNode.name = "total"
    totalNode.addChildNode(frameNode)              // "total << "frame"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ get the observer's position ..                                                                   ╎
  ╎ .. and attach "obsvrNode" to "earthNode"                                                         ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let obsCelestial = geo2eci(julianDays:-1.0, geodetic: Vector(AnnArborLatitude,
                                                                 AnnArborLongitude,
                                                                 AnnArborAltitude))
    addViewer(earthNode, at:(obsCelestial.x, obsCelestial.y, obsCelestial.z))

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ rotate "earthNode" for time of day                                                               ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    earthNode.eulerAngles.z += CGFloat(ZeroMeanSiderealTime(julianDaysNow()) * deg2rad)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ .. and attach "camraNode" to "totalNode" and "lightNode" to "earthNode"                          ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    addViewCamera(totalNode)
    addSolarLight(frameNode)

//      addMarkerSpot(frameNode, color: NSColor.magenta, at:(eRadiusKms * 1.05,0.0,0.0))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ attach the camera a long way from the center of a (non-rendering node) and pointed at (0, 0, 0)  │
  │ with a viewpoint initially on x-axis at 120,000Km with north (z-axis) up                         │
  │                                                      http://stackoverflow.com/questions/25654772 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func addViewCamera(_ parentNode: SCNNode) {

    let orbitNode = SCNNode()                           // non-rendering node, holds the camera
    orbitNode.name = "orbit"

    let camera = SCNCamera()                            // create a camera
    let cameraRange = 120_000.0
    camera.xFov = 800_000.0 / cameraRange
    camera.yFov = 800_000.0 / cameraRange
    camera.automaticallyAdjustsZRange = true

    let cameraNode = SCNNode()
    cameraNode.name = "camra"
    cameraNode.camera = camera
    cameraNode.position = SCNVector3(x: 0, y: 0, z: CGFloat(cameraRange))

    let cameraConstraint = SCNLookAtConstraint(target: parentNode)
    cameraConstraint.isGimbalLockEnabled = true
    cameraNode.constraints = [cameraConstraint]

    orbitNode.addChildNode(cameraNode)                  //            "orbit" << "camra"
    parentNode.addChildNode(orbitNode)                  // "total" << "orbit"
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func addSolarLight(_ parentNode: SCNNode) {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let sunLight = SCNLight()
    sunLight.type = SCNLight.LightType.directional      // make a directional light
    sunLight.castsShadow = true

    let lightNode = SCNNode()
    lightNode.name = "light"
    lightNode.light = sunLight

    parentNode.addChildNode(lightNode)                  //           "frame" << "light"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

    let solarNode = SCNNode()                           // position of sun in (x,y,z)
    solarNode.name = "solar"

    let sunVector = solarCel(julianDays: julianDaysNow())
    solarNode.position = SCNVector3((-sunVector.x, -sunVector.y, -sunVector.z))

    let solarConstraint = SCNLookAtConstraint(target: solarNode)
    lightNode.constraints = [solarConstraint]           // keep the light coming from the sun

    parentNode.addChildNode(solarNode)
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ a spot on the x-axis (points at vernal equinox)                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func addMarkerSpot(_ parentNode: SCNNode, color: NSColor, at: (Double, Double, Double)) {
    let spotsGeom = SCNSphere(radius: 100.0)
    spotsGeom.isGeodesic = true
    spotsGeom.segmentCount = 6
    spotsGeom.firstMaterial?.diffuse.contents = color

    let spotsNode = SCNNode(geometry:spotsGeom)
    spotsNode.name = "spots"
    spotsNode.position = SCNVector3(at)

    parentNode.addChildNode(spotsNode)              //           "frame" << "spots"
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ a spot on the x-axis (points at vernal equinox)                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func addViewer(_ parentNode: SCNNode, at: (Double, Double, Double)) {
    let viewrGeom = SCNSphere(radius: 50.0)
    viewrGeom.isGeodesic = true
    viewrGeom.segmentCount = 18
    viewrGeom.firstMaterial?.emission.contents = NSColor.green

    let viewrNode = SCNNode(geometry:viewrGeom)
    viewrNode.name = "obsvr"
    viewrNode.position = SCNVector3(at)

    parentNode.addChildNode(viewrNode)              //           "frame" << "viewr"
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ a satellite ..                                                                                   │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func addSatellite(_ parentNode: SCNNode, sat: Satellite) {

    if let trailNode = parentNode.childNode(withName: sat.catalogNum, recursively: true) {
        trailNode.removeFromParentNode()
    }

    let trailNode = SCNNode()
    trailNode.name = sat.catalogNum
    parentNode.addChildNode(trailNode)                  //           "frame" << "trail"

    let timeDelta = 15                                  // seconds between ticks on orbit path

//    SCNTransaction.begin()

    for index in -30...0 {
        let satCel = sat.position(minsAfterEpoch: sat.minsAfterEpoch + Double(timeDelta*index) / 60.0)

        let dottyGeom = SCNSphere(radius: 25.0)
        dottyGeom.isGeodesic = true
        dottyGeom.segmentCount = 6

//        if index == 0 {
//            dottyGeom.radius = 50
//            dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)              // NSColor.red
//        }
//        else {
//            dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)              // NSColor.white (!!CPU!!)
//        }

        let dottyNode = SCNNode(geometry:dottyGeom)
        dottyNode.position = SCNVector3((satCel.x, satCel.y, satCel.z))

        trailNode.addChildNode(dottyNode)               //        "frame" << "trail"
    }

//    SCNTransaction.commit()

}

func createTrail(_ geometry: SCNGeometry) -> SCNParticleSystem {

    let trail = SCNParticleSystem(named: "Fire.scnp", inDirectory: nil)!

    trail.emitterShape = geometry

    return trail
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (X, Y, X) --> (rad, inc, azi)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func cameraCart2Pole(_ x: Double, _ y: Double, _ z: Double) -> (Double, Double, Double) {
    let rad = sqrt(x*x + y*y + z*z)
    return (rad, acos(z/rad), atan2(y, x))
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (lon, lat, alt) --> (X, Y, X)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func cameraPole2Cart(_ rad: Double, _ inc: Double, _ azi: Double) -> (Double, Double, Double) {
    return (rad * sin(inc) * cos(azi), rad * sin(inc) * sin(azi), rad * cos(inc))
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ reads a binary file (x,y,z), (x,y,z), (x,y,z), (x,y,z), .. and makes a SceneKit object ..        │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func trailMesh() -> SCNGeometry? {

    if let dataContent = try? Data.init(contentsOf: URL(fileURLWithPath: "/tmp/coast.vector")) {
        let vectorCount = (dataContent.count) / 12           // count of vertices (two per line)

        let vertexSource = SCNGeometrySource(data: dataContent,
                                             semantic: SCNGeometrySource.Semantic.vertex,
                                             vectorCount: vectorCount,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: 12)

        let element = SCNGeometryElement(data: nil,
                                         primitiveType: .line,
                                         primitiveCount: vectorCount,
                                         bytesPerIndex: MemoryLayout<Int>.size)

        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    else {
        print("CoastMesh file missing")
        return nil
    }
}

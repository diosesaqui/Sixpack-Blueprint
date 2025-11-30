//
//  LocalExercises.swift
//  CoreBlastFY
//
//  Created by Riccardo Washington on 6/11/20.
//  Copyright © 2020 Riccardo Washington. All rights reserved.
//

import Foundation

struct LocalExercises: ExerciseInfoStoreProtocol {
    func fetchExercises(completion: @escaping ([Exercise], ExerciseInfoStoreError?) -> Void) {
        completion(LocalExercises.exercises, nil)
        return
    }
    // NOTE: updog is intentionally excluded from the main exercises array
    // It's added as a cool-down/stretch at the end of each workout via exercisesToReturn
    static let exercises: [Exercise] = [reversePlank,legRaises, openClose, pendulums, tPlank, leftSidePlankHipDip, rightSidePlankHipDip, leftSidePlankWrap, rightSidePlankWrap, inOuts, kneeDrives]
}

//Exercises
let legRaises = Exercise(name: "leg raises", tip: "slow controlled movement", level: .beginner, movement: .dynamic)
let openClose = Exercise(name: "open close", tip: "slow and under control", level: .novice, movement: .dynamic)
let pendulums = Exercise(name: "pendulums", tip: "slow and under control, core engaged", level: .advanced, movement: .dynamic, totalBody: true)
let reversePlank = Exercise(name: "reverse plank", tip: "core engaged, keep back flat", level: .beginner, movement: .stationary, totalBody: true)
let tPlank = Exercise(name: "t plank", tip: "core engaged - deep breaths", level: .solid, movement: .dynamic, totalBody: true)

let leftSidePlankHipDip = Exercise(name: "left side plank hipdip", tip: "engage lower oblique", level: .solid, movement: .dynamic, isSide: true, totalBody: true)
let rightSidePlankHipDip = Exercise(name: "right side plank hipdip", tip: "engage lower oblique", level: .solid, movement: .dynamic, isSide: true, totalBody: true)
let leftSidePlankWrap = Exercise(name: "left side plank wrap", tip: "engage lower oblique", level: .solid, movement: .dynamic, isSide: true)
let rightSidePlankWrap = Exercise(name: "right side plank wrap", tip: "engage lower oblique", level: .solid, movement: .dynamic, isSide: true)
let updog = Exercise(name: "updog", tip: "Breathe and stretch abs", level: .beginner, movement: .stationary)
let inOuts = Exercise(name: "in outs", tip: "core engaged - deep breaths", level: .beginner, movement: .dynamic)
let kneeDrives = Exercise(name: "kneedrives", tip: "core engaged - deep breaths", level: .novice, movement: .dynamic, totalBody: true)
let leftObliqueStretch = Exercise(name: "left oblique stretch", tip: "Breathe and stretch abs", level: .beginner, movement: .stationary)
let rightObliqueStretch = Exercise(name: "right oblique stretch", tip: "Breathe and stretch abs", level: .beginner, movement: .stationary)



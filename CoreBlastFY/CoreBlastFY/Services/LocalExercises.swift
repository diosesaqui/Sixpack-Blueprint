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
    static let newExercises: [Exercise] = [
        // MARK: - Core Exercises (Beginner to Advanced)
        // Beginner Core
        plank, deadBug, birdDog, crunches, wallSit,
        
        // Novice Core  
        legRaises, bicycleCrunches, russianTwists, flutterKicks, reverseCrunches, sideCrunches, obliqueCrunches, sidePlank, inOuts,
        
        // Solid Core
        vUps, toeTouch, plankJacks, tPlank, leftSidePlankHipDip, rightSidePlankHipDip, leftSidePlankWrap, rightSidePlankWrap,
        
        // Advanced Core
        superman, reversePlank, openClose,
        
        // Expert Core  
        pendulums, kneeDrives,
        
        // MARK: - Upper Body Exercises
        // Beginner Upper Body
        wallPushUps, armCircles, armSwings,
        
        // Novice Upper Body
        pushUps, shoulderRolls, shoulderShrugs,
        
        // Solid Upper Body
        widePushUps, pikePushUps, tricepDips,
        
        // Advanced Upper Body
        diamondPushUps, spiderPushUps,
        
        // Expert Upper Body
        clapPushUps,
        
        // MARK: - Lower Body Exercises
        // Beginner Lower Body
        squats, lunges, calfRaises, marchingInPlace, walkingInPlace, sideSteps, standingKneeRaises,
        
        // Novice Lower Body
        starJumps,
        
        // Solid Lower Body
        jumpSquats, squatJumps,
        
        // Advanced Lower Body
        jumpLunges, boxJumps,
        
        // Expert Lower Body
        pistolSquats,
        
        // MARK: - Cardio/Full Body Exercises
        // Beginner Cardio
        jumpingJacks, highKnees, buttKicks,
        
        // Novice Cardio
        mountainClimbers,
        
        // Solid Cardio
        burpees,
        
        // MARK: - Stretching/Recovery Exercises
        neckRolls, hipCircles, legSwings, torsoTwists, standingForwardFold, sideStretches, quadStretches, calfStretches, deepBreathing, wallAngels
    ]
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

// MARK: - New Exercises for Browse Tab

// Core exercises
let plank = Exercise(name: "Plank", tip: "Keep core tight, straight line from head to feet", level: .beginner, movement: .stationary)
let sidePlank = Exercise(name: "Side Plank", tip: "Keep body in straight line, engage obliques", level: .novice, movement: .stationary, isSide: true)
let vUps = Exercise(name: "V-Ups", tip: "Reach hands to toes, control the movement", level: .solid, movement: .dynamic)
let crunches = Exercise(name: "Crunches", tip: "Lift shoulders off ground, don't pull on neck", level: .beginner, movement: .dynamic)
let bicycleCrunches = Exercise(name: "Bicycle Crunches", tip: "Alternate elbow to opposite knee", level: .novice, movement: .dynamic)
let russianTwists = Exercise(name: "Russian Twists", tip: "Rotate torso side to side, keep core engaged", level: .novice, movement: .dynamic)
let deadBug = Exercise(name: "Dead Bug", tip: "Keep lower back pressed to floor", level: .beginner, movement: .dynamic)
let birdDog = Exercise(name: "Bird Dog", tip: "Keep hips level, extend opposite arm and leg", level: .beginner, movement: .dynamic, totalBody: true)
let flutterKicks = Exercise(name: "Flutter Kicks", tip: "Keep lower back pressed down, small kicks", level: .novice, movement: .dynamic)
let toeTouch = Exercise(name: "Toe Touches", tip: "Reach up to toes, engage upper abs", level: .solid, movement: .dynamic)
let reverseCrunches = Exercise(name: "Reverse Crunches", tip: "Bring knees to chest, control the movement", level: .novice, movement: .dynamic)
let sideCrunches = Exercise(name: "Side Crunches", tip: "Crunch to the side, engage obliques", level: .novice, movement: .dynamic, isSide: true)
let obliqueCrunches = Exercise(name: "Oblique Crunches", tip: "Target side abs, control the movement", level: .novice, movement: .dynamic, isSide: true)
let superman = Exercise(name: "Superman", tip: "Lift chest and legs, squeeze glutes", level: .novice, movement: .dynamic, totalBody: true)
let plankJacks = Exercise(name: "Plank Jacks", tip: "Jump feet apart and together in plank", level: .solid, movement: .dynamic, totalBody: true)

// Upper body exercises  
let pushUps = Exercise(name: "Push Ups", tip: "Keep body straight, full range of motion", level: .novice, movement: .dynamic, totalBody: true)
let diamondPushUps = Exercise(name: "Diamond Push Ups", tip: "Hands form diamond, focus on triceps", level: .advanced, movement: .dynamic)
let widePushUps = Exercise(name: "Wide Push Ups", tip: "Hands wider than shoulders, focus on chest", level: .solid, movement: .dynamic)
let pikePushUps = Exercise(name: "Pike Push Ups", tip: "Pike position, focus on shoulders", level: .solid, movement: .dynamic)
let wallPushUps = Exercise(name: "Wall Push Ups", tip: "Stand arm's length from wall, gentle movement", level: .beginner, movement: .dynamic)
let clapPushUps = Exercise(name: "Clap Push Ups", tip: "Explosive movement, clap at top", level: .rockstar, movement: .explosive)
let spiderPushUps = Exercise(name: "Spider Push Ups", tip: "Bring knee to elbow during push up", level: .advanced, movement: .dynamic, totalBody: true)
let tricepDips = Exercise(name: "Dips", tip: "Lower body with control, focus on triceps", level: .solid, movement: .dynamic)

// Lower body exercises
let squats = Exercise(name: "Squats", tip: "Sit back like sitting in chair, chest up", level: .beginner, movement: .dynamic, totalBody: true)
let jumpSquats = Exercise(name: "Jump Squats", tip: "Land softly, full squat before jumping", level: .solid, movement: .explosive, totalBody: true)
let pistolSquats = Exercise(name: "Pistol Squats", tip: "Single leg squat, use assistance if needed", level: .rockstar, movement: .dynamic)
let lunges = Exercise(name: "Lunges", tip: "Step forward, 90 degree angles in both knees", level: .novice, movement: .dynamic, totalBody: true)
let jumpLunges = Exercise(name: "Jump Lunges", tip: "Switch legs in the air, land softly", level: .advanced, movement: .explosive, totalBody: true)
let boxJumps = Exercise(name: "Box Jumps", tip: "Jump onto stable surface, land softly", level: .advanced, movement: .explosive, totalBody: true)
let calfRaises = Exercise(name: "Calf Raises", tip: "Rise up on toes, control the movement", level: .beginner, movement: .dynamic)
let wallSit = Exercise(name: "Wall Sit", tip: "Back against wall, thighs parallel to floor", level: .beginner, movement: .stationary)
let squatJumps = Exercise(name: "Squat Jumps", tip: "Jump up from squat position", level: .solid, movement: .explosive, totalBody: true)

// Cardio/Full body exercises
let jumpingJacks = Exercise(name: "Jumping Jacks", tip: "Land softly, full range of motion", level: .beginner, movement: .dynamic, totalBody: true)
let mountainClimbers = Exercise(name: "Mountain Climbers", tip: "Keep plank position, quick feet", level: .novice, movement: .dynamic, totalBody: true)
let burpees = Exercise(name: "Burpees", tip: "Full body movement, maintain form", level: .solid, movement: .explosive, totalBody: true)
let highKnees = Exercise(name: "High Knees", tip: "Bring knees up to chest level", level: .beginner, movement: .dynamic, totalBody: true)
let buttKicks = Exercise(name: "Butt Kicks", tip: "Kick heels to glutes, stay upright", level: .beginner, movement: .dynamic, totalBody: true)
let starJumps = Exercise(name: "Star Jumps", tip: "Jump into star shape, land softly", level: .novice, movement: .explosive, totalBody: true)
let marchingInPlace = Exercise(name: "Marching In Place", tip: "Lift knees, swing arms naturally", level: .beginner, movement: .dynamic)
let walkingInPlace = Exercise(name: "Walking In Place", tip: "Natural walking motion, controlled pace", level: .beginner, movement: .dynamic)
let sideSteps = Exercise(name: "Side Steps", tip: "Step side to side, maintain posture", level: .beginner, movement: .dynamic)
let standingKneeRaises = Exercise(name: "Standing Knee Raises", tip: "Lift knee to waist level", level: .beginner, movement: .dynamic)

// Stretching/Mobility exercises
let armCircles = Exercise(name: "Arm Circles", tip: "Control the movement, full range of motion", level: .beginner, movement: .dynamic)
let armSwings = Exercise(name: "Arm Swings", tip: "Swing arms across body and back", level: .beginner, movement: .dynamic)
let neckRolls = Exercise(name: "Neck Rolls", tip: "Slow and controlled, don't force", level: .beginner, movement: .dynamic)
let shoulderRolls = Exercise(name: "Shoulder Rolls", tip: "Roll shoulders back and forward", level: .beginner, movement: .dynamic)
let shoulderShrugs = Exercise(name: "Shoulder Shrugs", tip: "Lift shoulders up towards ears", level: .beginner, movement: .dynamic)
let hipCircles = Exercise(name: "Hip Circles", tip: "Rotate hips in controlled circles", level: .beginner, movement: .dynamic)
let legSwings = Exercise(name: "Leg Swings", tip: "Swing leg forward and back", level: .beginner, movement: .dynamic)
let torsoTwists = Exercise(name: "Torso Twists", tip: "Rotate torso left and right", level: .beginner, movement: .dynamic)
let standingForwardFold = Exercise(name: "Standing Forward Fold", tip: "Fold forward gently, don't force", level: .beginner, movement: .stationary)
let sideStretches = Exercise(name: "Side Stretches", tip: "Reach arm overhead and lean", level: .beginner, movement: .stationary)
let quadStretches = Exercise(name: "Quad Stretches", tip: "Pull heel to glute, keep knees together", level: .beginner, movement: .stationary)
let calfStretches = Exercise(name: "Calf Stretches", tip: "Keep heel down, lean forward", level: .beginner, movement: .stationary)
let deepBreathing = Exercise(name: "Deep Breathing", tip: "Breathe deeply and slowly", level: .beginner, movement: .stationary)
let wallAngels = Exercise(name: "Wall Angels", tip: "Back against wall, move arms up and down", level: .beginner, movement: .dynamic)



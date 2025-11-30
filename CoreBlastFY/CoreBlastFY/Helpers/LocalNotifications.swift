//
//  LocalNotifications.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 1/20/20.
//  Copyright © 2020 Riccardo Washington. All rights reserved.
//

import Foundation
import UserNotifications

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

let notificationsAllowedKey = "notificationsAllowed"
var notificationsAllowed = UserDefaults.standard.bool(forKey: notificationsAllowedKey)

let decrementNotifId = UUID().uuidString

func sendPointDecrementNotification() {
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    let content = UNMutableNotificationContent()
    content.title = "It's been over \(UserManager.missedWorkouts) days since completed last workout!"
    content.body = "\(UserManager.missedWorkouts - 2) points has been deducted for missing \(UserManager.missedWorkouts) consecutive days, complete a workout to gain your points back!"
    content.categoryIdentifier = "lostPointNotification"
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: Sounds.backOnTrack))
    
    let request = UNNotificationRequest(identifier: decrementNotifId, content: content, trigger: trigger)
    notificationCenter.add(request)
}

func registerForNotifications() {
    
    if !notificationsAllowed {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                mealPrepNotification()
                prepareProgressionPicNotification()
                prepareFriNotification()
                prepareRelaxNotification()
                prepareMFNotification()
                timeToWorkoutMNotification()
                timeToWorkoutTNotification()
                timeToWorkoutWNotification()
                timeToWorkoutTHNotification()
                timeToWorkoutFNotification()
                prepareJournalEntryNotification()
                notificationsAllowed = true
                UserDefaults.standard.set(notificationsAllowed, forKey: notificationsAllowedKey)
            }
        }
    }
}

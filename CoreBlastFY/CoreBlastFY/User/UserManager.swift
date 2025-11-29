//
//  UserManager.swift
//  CoreBlast
//
//  Created by Riccardo Washington on 12/14/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import Foundation

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    static var fourDaysAgo: Date { return Date().fourDaysAgo }
    static var threeDaysAgo: Date { return Date().threeDaysAgo }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var day: Int {
        return Calendar.current.component(.day,  from: self)
    }
    var year: Int {
        return Calendar.current.component(.year,  from: self)
    }
    
    var ymd: String {
        return "\(month)\(day)\(year)"
    }
    var fourDaysAgo: Date {
          return Calendar.current.date(byAdding: .day, value: -4, to: noon)!
    }
    var threeDaysAgo: Date {
          return Calendar.current.date(byAdding: .day, value: -3, to: noon)!
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
    func daysAgo(_ days: Int) -> Date {
         return Calendar.current.date(byAdding: .day, value: days, to: noon)!
    }
}

func isPassedMoreThan(days: Int, fromDate date : Date, toDate date2 : Date) -> Bool {
    let unitFlags: Set<Calendar.Component> = [.day]
    let deltaD = Calendar.current.dateComponents( unitFlags, from: date, to: date2)
    return deltaD.day! > days
}

func missedWorkoutdaysCount(days: Int, fromDate date : Date, toDate date2 : Date) -> Int {
    let unitFlags: Set<Calendar.Component> = [.day]
    let deltaD = Calendar.current.dateComponents(unitFlags, from: date, to: date2)
    return deltaD.day! - days
}


class UserManager {
    
    static let workoutDateKey = "WorkoutDate"
    static let totalPointsKey = "TotalPoints"
    static let lastDecrement = "LastDecrement"
    static var missedWorkouts = 0
    
    static func decrementPoint() -> (Bool, Int?) {
        let today = Date()
        let todayString = today.ymd
    
        guard let lastWorkout = UserAPI.user.lastWorkoutComplete else { return (false, nil) }
        let lastDecrement = UserDefaults.standard.string(forKey: UserManager.lastDecrement)
        if isPassedMoreThan(days: 3, fromDate: lastWorkout, toDate: today), UserAPI.user.totalPoints > 0, lastDecrement != todayString {
            let days = missedWorkoutdaysCount(days: 0, fromDate: lastWorkout, toDate: today)
            UserAPI.user.totalPoints -= days - 2
            UserDefaults.standard.setValue(todayString, forKey: UserManager.lastDecrement)
            if UserAPI.user.totalPoints < 0 {
                 UserAPI.user.totalPoints = 0
            }
            UserManager.missedWorkouts = days
            UserDefaults.standard.setValue(UserAPI.user.totalPoints, forKey: UserManager.totalPointsKey)
            save()
            return (true, UserManager.missedWorkouts)
        } else {
            return (false, nil)
        }
    }
    
    static func incrementPoint() {
        UserAPI.user.lastWorkoutComplete = Date()
        UserAPI.user.totalPoints += 1
        UserDefaults.standard.setValue(UserAPI.user.totalPoints, forKey: UserManager.totalPointsKey)
        save()
    }
    
    static func calculateLevel(totalPoints: Int) {
        switch totalPoints {
        case _ where totalPoints == UserAPI.user.nextLevelUp:
            UserAPI.user.coreLevel = UserAPI.user.nextLevel
            save()
        default: break
        }
    }
    
    static func save() {

             let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
             let archiveURL = documentsDirectory.appendingPathComponent("User").appendingPathExtension("json")
             
             let jsonEncoder = JSONEncoder()
             
             do {
                let encodedData = try jsonEncoder.encode(UserAPI.user)
                 try encodedData.write(to: archiveURL)
             } catch let error {
                 print(error)
             }
         }
         
    static func loadUserFromFile() -> User {
            
             let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
             let archiveURL = documentsDirectory.appendingPathComponent("User").appendingPathExtension("json")
             
             let jsonDecoder = JSONDecoder()
            guard let decodedData = try? Data(contentsOf: archiveURL) else { return User() }
            
             do {
                var user = try jsonDecoder.decode(User.self, from: decodedData)
                
                // Restore the selectedTime from UserDefaults
                if let savedWorkoutTime = UserDefaults.standard.object(forKey: workoutDateKey) as? Date {
                    user.selectedTime = savedWorkoutTime
                }
                
                return user
             } catch let error {
                 print(error)
                return User()
             }
         }
    }

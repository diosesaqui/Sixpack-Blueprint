//
//  OptimizedNotifications.swift
//  CoreBlastFY
//
//  Created by Claude AI on 11/29/25.
//

import Foundation
import UserNotifications


class OptimizedNotificationManager {
    static let shared = OptimizedNotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Notification IDs
    struct NotificationID {
        static let dailyWorkout = "daily_workout_reminder"
        static let progressPhoto = "weekly_progress_photo"
        static let workoutStreak = "workout_streak_motivation"
        static let welcomeBack = "welcome_back_reminder"
        static let achievementUnlock = "achievement_unlocked"
        static let perfectWeek = "perfect_week_celebration"
        static let pointLossWarning = "point_loss_warning"
        static let streakWarning = "streak_loss_warning"
    }
    
    // MARK: - User Behavior Tracking
    private func getUserEngagementLevel() -> String {
        let completedWorkouts = UserDefaults.standard.integer(forKey: "completedWorkoutsCount")
        let daysSinceInstall = getDaysSinceInstall()
        
        if completedWorkouts >= 21 { return "champion" }
        if completedWorkouts >= 7 { return "committed" }
        if completedWorkouts >= 3 { return "building" }
        return "beginner"
    }
    
    private func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = Date()
        var currentStreak = 0
        
        // Count consecutive days backwards from today
        for i in 0..<100 { // Check up to 100 days back
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateKey = "workout_\(DateFormatter.yyyyMMdd.string(from: date))"
                if UserDefaults.standard.bool(forKey: dateKey) {
                    currentStreak += 1
                } else {
                    break
                }
            }
        }
        
        return currentStreak
    }
    
    private func getDaysSinceInstall() -> Int {
        guard let installDate = UserDefaults.standard.object(forKey: "appInstallDate") as? Date else {
            // Set install date if not exists
            UserDefaults.standard.set(Date(), forKey: "appInstallDate")
            return 0
        }
        return Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
    }
    
    // MARK: - Main Setup
    func setupOptimizedNotifications() {
        clearAllNotifications()
        
        guard notificationsAllowed else { return }
        
        // Core notifications only
        scheduleDailyWorkoutReminder()
        scheduleWeeklyProgressReminder()
        scheduleStreakMotivation()
        scheduleWelcomeBackNotification()
        
        // Achievement-based notifications
        checkForAchievementNotifications()
    }
    
    // MARK: - Achievement Notifications
    private func checkForAchievementNotifications() {
        let completedWorkouts = UserDefaults.standard.integer(forKey: "completedWorkoutsCount")
        let achievements = [3, 7, 14, 21, 30, 50, 100]
        
        // Get list of already shown achievements
        let shownAchievements = UserDefaults.standard.array(forKey: "shownAchievements") as? [Int] ?? []
        
        for milestone in achievements {
            if completedWorkouts == milestone && !shownAchievements.contains(milestone) {
                scheduleAchievementNotification(milestone: milestone)
                // Mark this achievement as shown
                let updatedShownAchievements = shownAchievements + [milestone]
                UserDefaults.standard.set(updatedShownAchievements, forKey: "shownAchievements")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    private func scheduleAchievementNotification(milestone: Int) {
        let achievementMessages: [Int: (String, String)] = [
            3: ("🎉 First Victory!", "3 workouts down! You're building the habit!"),
            7: ("🔥 Week Warrior!", "7 workouts complete! You're on fire!"),
            14: ("💪 Two Week Titan!", "14 workouts! Your consistency is incredible!"),
            21: ("🏆 Habit Master!", "21 workouts! You've officially built the habit!"),
            30: ("👑 Monthly Champion!", "30 workouts! You're a core legend!"),
            50: ("⭐ Elite Status!", "50 workouts! You're in the top 1%!"),
            100: ("💎 Century Club!", "100 workouts! You're absolutely unstoppable!")
        ]
        
        guard let message = achievementMessages[milestone] else { return }
        
        // Track achievement unlock
        AnalyticsManager.shared.trackAchievementUnlocked(milestone: milestone)
        
        let content = UNMutableNotificationContent()
        content.title = message.0
        content.body = message.1
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(NotificationID.achievementUnlock)_\(milestone)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule achievement notification: \(error)")
            }
        }
    }
    
    // MARK: - Core Notification Functions
    
    private func scheduleDailyWorkoutReminder() {
        guard let selectedTime = UserAPI.user.selectedTime else { return }
        
        let (hour, minute) = getHourAndMinuteFromDate(date: selectedTime)
        guard let unwrappedHour = hour, let unwrappedMinute = minute else { return }
        
        // Personalized messages based on user engagement level and streak
        let engagementLevel = getUserEngagementLevel()
        let currentStreak = getCurrentStreak()
        let motivationalMessages: [(String, String)]
        
        // Special streak messages when applicable
        if currentStreak >= 7 {
            motivationalMessages = [
                ("🔥 \(currentStreak)-day streak!", "You're absolutely crushing it!"),
                ("⚡ Streak master!", "\(currentStreak) days straight - legendary!"),
                ("💎 Unstoppable!", "Don't break that \(currentStreak)-day chain!"),
                ("🏆 Streak champion!", "\(currentStreak) days of greatness!"),
                ("👑 You're on fire!", "Keep that \(currentStreak)-day momentum!"),
                ("🚀 Consistency king!", "\(currentStreak) days = pure dedication"),
                ("⭐ Streak legend!", "This \(currentStreak)-day run is incredible!")
            ]
        } else {
            switch engagementLevel {
            case "champion":
                motivationalMessages = [
                    ("🏆 Champions train daily!", "Time to dominate another core session"),
                    ("👑 You're a core legend!", "Show them how it's done"),
                    ("⚡ Unstoppable force!", "Your dedication is inspiring"),
                    ("🔥 Core master mode!", "Another day, another victory"),
                    ("💎 Elite level achieved!", "Champions train when they don't feel like it"),
                    ("🚀 Ready to dominate!", "This is what greatness looks like"),
                    ("⭐ Legendary status!", "Your consistency is unmatched")
                ]
            case "committed":
                motivationalMessages = [
                    ("💪 Building momentum!", "Time to level up your core"),
                    ("🎯 Consistency is key!", "You're in the groove now"),
                    ("🔥 You're on track!", "Don't stop when you're winning"),
                    ("⚡ Strong foundation!", "Every workout builds your strength"),
                    ("🚀 Keep climbing!", "You're becoming unstoppable"),
                    ("💥 Rhythm found!", "This is where transformation happens"),
                    ("🌟 Show must go on!", "Your body is adapting amazingly")
                ]
            case "building":
                motivationalMessages = [
                    ("🌱 Growing stronger!", "Every rep is progress"),
                    ("🎯 You're getting there!", "Consistency beats perfection"),
                    ("💪 Building the habit!", "Small steps, big results"),
                    ("⚡ Progress in motion!", "You're doing better than you think"),
                    ("🔥 Momentum building!", "Keep showing up for yourself"),
                    ("🚀 On the right path!", "Your future self will thank you"),
                    ("💎 Forming greatness!", "This is how champions are made")
                ]
            default: // beginner
                motivationalMessages = [
                    ("🌟 Start strong today!", "Just 5 minutes can change everything"),
                    ("💪 You've got this!", "Every champion started somewhere"),
                    ("🎯 Begin your journey!", "The first step is always the hardest"),
                    ("⚡ Quick wins await!", "Small actions, massive results"),
                    ("🔥 Ignite your potential!", "Your transformation starts now"),
                    ("🚀 Launch your goals!", "Believe in your ability to succeed"),
                    ("💎 Discover your strength!", "You're stronger than you think")
                ]
            }
        }
        
        // Schedule for each day of the week with rotating messages
        for weekday in 1...7 {
            let messageIndex = (weekday - 1) % motivationalMessages.count
            let (title, body) = motivationalMessages[messageIndex]
            
            scheduleWeeklyNotification(
                id: "\(NotificationID.dailyWorkout)_\(weekday)",
                title: title,
                body: body,
                weekday: weekday,
                hour: unwrappedHour,
                minute: unwrappedMinute
            )
        }
    }
    
    private func scheduleWeeklyProgressReminder() {
        // Saturday at 10 AM for progress photos
        scheduleWeeklyNotification(
            id: NotificationID.progressPhoto,
            title: "📸 Transformation Thursday!",
            body: "Document your progress! Your future self will thank you 💪",
            weekday: 5, // Friday - better day for progress pics
            hour: 18,
            minute: 0
        )
    }
    
    private func scheduleStreakMotivation() {
        // Sunday at 8 PM - Sunday motivation for the week ahead
        scheduleWeeklyNotification(
            id: NotificationID.workoutStreak,
            title: "💪 Sunday Reset!",
            body: "New week, new gains! Are you ready to dominate your core goals?",
            weekday: 1, // Sunday
            hour: 20,
            minute: 0
        )
    }
    
    private func scheduleWelcomeBackNotification() {
        // This will be triggered programmatically when user hasn't opened app in 2+ days
        // Just register the category for now
        let content = UNMutableNotificationContent()
        content.title = "We miss you! 👋"
        content.body = "Your core training is waiting. Just 5 minutes can make a difference!"
        content.sound = UNNotificationSound.default
        
        // This will be scheduled dynamically when app detects user hasn't opened in 48 hours
    }
    
    // MARK: - Helper Functions
    
    private func scheduleWeeklyNotification(
        id: String,
        title: String,
        body: String,
        weekday: Int,
        hour: Int,
        minute: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.timeZone = TimeZone.current
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification \(id): \(error)")
            }
        }
    }
    
    func scheduleWelcomeBackReminder() {
        // Check if we've already sent a welcome back notification recently (within last 24 hours)
        if let lastWelcomeBack = UserDefaults.standard.object(forKey: "lastWelcomeBackNotification") as? Date {
            let hoursSinceLastWelcomeBack = Date().timeIntervalSince(lastWelcomeBack) / 3600
            if hoursSinceLastWelcomeBack < 24 {
                return // Don't send another welcome back notification too soon
            }
        }
        
        // Call this when app detects user hasn't opened in 48+ hours
        let welcomeBackMessages = [
            ("🔥 Your abs miss you!", "Just 5 minutes to reignite your fitness fire"),
            ("💪 Ready for a comeback?", "Champions bounce back stronger"),
            ("⚡ Your streak awaits!", "Every champion has comeback moments"),
            ("🎯 Time to restart your engine!", "Your future physique is calling"),
            ("💥 Miss me yet?", "Your core hasn't forgotten you")
        ]
        
        let randomMessage = welcomeBackMessages.randomElement() ?? welcomeBackMessages[0]
        
        let content = UNMutableNotificationContent()
        content.title = randomMessage.0
        content.body = randomMessage.1
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationID.welcomeBack,
            content: content,
            trigger: trigger
        )
        
        // Mark that we've sent a welcome back notification
        UserDefaults.standard.set(Date(), forKey: "lastWelcomeBackNotification")
        UserDefaults.standard.synchronize()
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule welcome back notification: \(error)")
            }
        }
    }
    
    // MARK: - Management Functions
    
    func clearAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    UserDefaults.standard.set(true, forKey: notificationsAllowedKey)
                    self.setupOptimizedNotifications()
                }
                completion(granted)
            }
        }
    }
    
    func updateNotificationTime(newTime: Date) {
        // Re-setup notifications with new time
        setupOptimizedNotifications()
    }
    
    func checkForPointLossWarning() {
        // Check if user is about to lose points (after 3 days of no workout)
        guard let lastWorkout = UserAPI.user?.lastWorkoutComplete else { return }
        
        let calendar = Calendar.current
        let today = Date()
        let daysSinceLastWorkout = calendar.dateComponents([.day], from: lastWorkout, to: today).day ?? 0
        
        // Clear old warnings
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.pointLossWarning, NotificationID.streakWarning])
        
        if daysSinceLastWorkout == 2 {
            // User is on day 2 without workout - warn about point loss tomorrow
            schedulePointLossWarning()
        } else if daysSinceLastWorkout == 1 && UserAPI.user?.currentStreak ?? 0 > 0 {
            // User will lose their streak tomorrow if they don't workout
            scheduleStreakLossWarning()
        }
    }
    
    private func schedulePointLossWarning() {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Point Loss Alert!"
        content.body = "Work out today or you'll lose points tomorrow! Keep your progress going 💪"
        content.sound = UNNotificationSound.default
        
        // Schedule for 6 PM today
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationID.pointLossWarning, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule point loss warning: \(error)")
            }
        }
    }
    
    private func scheduleStreakLossWarning() {
        let currentStreak = UserAPI.user?.currentStreak ?? 0
        let content = UNMutableNotificationContent()
        content.title = "🔥 Your \(currentStreak) day streak is at risk!"
        content.body = "Don't lose your momentum! Complete today's workout to keep your streak alive"
        content.sound = UNNotificationSound.default
        
        // Schedule for 7 PM today
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationID.streakWarning, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule streak loss warning: \(error)")
            }
        }
    }
    
    func checkForInactiveUser() {
        // Check for point loss warning first
        checkForPointLossWarning()
        
        guard let lastOpenTime = UserDefaults.standard.object(forKey: "lastAppOpenTime") as? Date else {
            return
        }
        
        let hoursSinceLastOpen = Date().timeIntervalSince(lastOpenTime) / 3600
        
        // If user hasn't opened app in 48+ hours, schedule welcome back notification
        if hoursSinceLastOpen >= 48 {
            scheduleWelcomeBackReminder()
            
            // Track user inactivity for analytics
            AnalyticsManager.shared.trackUserInactive(hoursInactive: Int(hoursSinceLastOpen))
        }
    }
    
    // MARK: - Analytics Integration
    
    func trackNotificationInteraction(notificationId: String, action: String) {
        AnalyticsManager.shared.trackNotificationInteraction(
            notificationId: notificationId,
            action: action
        )
    }
    
    // MARK: - Smart Engagement Features
    
    func triggerWorkoutCompletionFlow() {
        // Call this when a workout is completed
        let completedWorkouts = UserDefaults.standard.integer(forKey: "completedWorkoutsCount")
        
        // Check for achievement unlock
        checkForAchievementNotifications()
        
        // Check for perfect week
        checkForPerfectWeekNotification()
        
        // Track completion time for future optimization
        trackWorkoutCompletionTime()
        
        // Track user engagement level
        let engagementLevel = getUserEngagementLevel()
        AnalyticsManager.shared.trackEngagementLevel(level: engagementLevel)
        
        // Track streak milestones
        let currentStreak = getCurrentStreak()
        if [3, 7, 14, 21, 30, 50, 100].contains(currentStreak) {
            AnalyticsManager.shared.trackStreakMilestone(streakLength: currentStreak)
        }
    }
    
    private func checkForPerfectWeekNotification() {
        let calendar = Calendar.current
        let today = Date()
        
        // Check if user completed workouts for 7 consecutive days
        var consecutiveDays = 0
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateKey = "workout_\(DateFormatter.yyyyMMdd.string(from: date))"
                if UserDefaults.standard.bool(forKey: dateKey) {
                    consecutiveDays += 1
                } else {
                    break
                }
            }
        }
        
        if consecutiveDays >= 7 {
            // Check if we've already shown perfect week notification for this week
            let weekKey = "perfectWeek_\(DateFormatter.yyyyMMdd.string(from: today))"
            let hasShownThisWeek = UserDefaults.standard.bool(forKey: weekKey)
            
            if !hasShownThisWeek {
                schedulePerfectWeekCelebration()
                AnalyticsManager.shared.trackPerfectWeek()
                UserDefaults.standard.set(true, forKey: weekKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    private func schedulePerfectWeekCelebration() {
        let content = UNMutableNotificationContent()
        content.title = "🔥 PERFECT WEEK!"
        content.body = "7 days straight! You're absolutely crushing it! 🏆"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationID.perfectWeek,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule perfect week notification: \(error)")
            }
        }
    }
    
    private func trackWorkoutCompletionTime() {
        let hour = Calendar.current.component(.hour, from: Date())
        let currentTimes = UserDefaults.standard.array(forKey: "workoutCompletionTimes") as? [Int] ?? []
        let updatedTimes = currentTimes + [hour]
        
        // Keep only last 30 completion times for analysis
        let recentTimes = Array(updatedTimes.suffix(30))
        UserDefaults.standard.set(recentTimes, forKey: "workoutCompletionTimes")
    }
    
    private func getOptimalNotificationTime() -> (hour: Int, minute: Int) {
        // Analyze user's workout completion patterns
        let completionTimes = UserDefaults.standard.array(forKey: "workoutCompletionTimes") as? [Int] ?? []
        
        if completionTimes.count >= 5 {
            // Find the most common hour (mode)
            let timeGroups = Dictionary(grouping: completionTimes, by: { $0 })
            let mostCommonTime = timeGroups.max { $0.value.count < $1.value.count }?.key ?? 18
            
            // Schedule notification 30 minutes before their usual time
            let optimalHour = max(6, mostCommonTime - 1) // Not before 6 AM
            return (hour: optimalHour, minute: 30)
        }
        
        // Default fallback
        return (hour: 18, minute: 0)
    }
}

// MARK: - Backward Compatibility

// Simplified registration function that replaces the old one
func registerForOptimizedNotifications() {
    OptimizedNotificationManager.shared.requestPermissions { granted in
        if granted {
            print("Notifications authorized and optimized notifications scheduled")
        }
    }
}
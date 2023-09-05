//
//  ViewController.swift
//  task3_app
//
//  Created by Nazlıcan Çay on 29.08.2023.
//

import UIKit
import UserNotifications
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    var timer: Timer?
    var timeLeft: TimeInterval = 0
    var player: AVAudioPlayer?
        
    @IBOutlet weak var setResetButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var playPauseButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
        
        // Customizing the Play/Pause button
            playPauseButton.backgroundColor = UIColor.green
            playPauseButton.layer.cornerRadius = 12 // Modify this to change how rounded the corners are
            playPauseButton.setTitleColor(UIColor.white, for: .normal)  // Set the text color to white
            
            // Customizing the Set/Reset button
            setResetButton.backgroundColor = UIColor.gray
            setResetButton.layer.cornerRadius = 12 // Modify this to change how rounded the corners are
             setResetButton.setTitleColor(UIColor.white, for: .normal)  // Set the text color to white

        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Handle error if needed
            }
            timePicker.datePickerMode = .countDownTimer
            playPauseButton.setTitle("Play/Pause", for: .normal)
            setResetButton.setTitle("Set/Reset", for: .normal)

    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        if timer == nil {
            // if timer is not already running
            if timeLeft == 0 {
                timeLeft = timePicker.countDownDuration
            }
            
            if timeLeft > 0 {
                timePicker.isHidden = true
                updateLabelTime(timeLeft)
                timerLabel.isHidden = false
                playPauseButton.setTitle("Pause", for: .normal)
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                scheduleNotification()
            }
        } else {
            // If timer is already running, then pause it
            timer?.invalidate()
            timer = nil
            playPauseButton.setTitle("Play", for: .normal)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerElapsed"])
        }
    }


    func updateLabelTime(_ time: TimeInterval) {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        
        var timeString = ""
        
        if minutes > 0 {
            timeString += "\(minutes) :"
            if minutes > 1 {
               // timeString = ""
            }
        }
        
        if minutes > 0 && seconds > 0 {
            //timeString = ""
        }
        
        if seconds > 0 {
            timeString += "\(seconds)"
            if seconds > 1 {
                //timeString = " "
            }
        }
        
        timerLabel.text = timeString
    }

    
    @objc func updateTimer() {
        timeLeft -= 1

        updateLabelTime(timeLeft)

        if timeLeft <= 0 {
            timerElapsed()
        }
    }
    
    func timerElapsed() {
        timer?.invalidate()
        timer = nil
        playPauseButton.setTitle("Play", for: .normal)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerElapsed"])

        if timeLeft >= 60 {
            // Do nothing, the notification will fire.
        } else {
            // The timer is less than 60 seconds, so we need to play the sound directly.
            if let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.play()
                } catch {
                    print("Error playing sound")
                }
            }
        }
    }


    
    func scheduleNotification() {
        if timeLeft >= 60 {
            let notification = UNMutableNotificationContent()
            notification.title = "Timer"
            notification.body = "Timer has elapsed!"
            notification.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm.mp3"))

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeLeft, repeats: false)
            let request = UNNotificationRequest(identifier: "timerElapsed", content: notification, trigger: trigger)

            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    @IBAction func setResetTapped(_ sender: UIButton) {
        // Stop the timer and reset timeLeft
           timer?.invalidate()
           timer = nil
        
        // Show the timePicker and hide the timerLabel
           timePicker.isHidden = false
           timerLabel.isHidden = true
           timePicker.countDownDuration = timeLeft
           timeLeft = 0
        
        // Reset the play/pause button title to "Play"
            playPauseButton.setTitle("Play", for: .normal)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerElapsed"])
    }

    
}
extension ViewController: UNUserNotificationCenterDelegate {
    
    // This function will be called right when a notification is delivered to a foreground app.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // You can show the notification with a banner even if the app is in the foreground
        completionHandler([.banner, .sound])
    }
}



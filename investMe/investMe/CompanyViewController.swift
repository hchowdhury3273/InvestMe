//
//  CompanyViewController.swift
//  investMe
//
//  Created by Helal Chowdhury on 3/7/20.
//  Copyright © 2020 Helal. All rights reserved.
//

import UIKit
import NotificationCenter
import EventKit

class CompanyViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var video: UIWebView!
    
    
    
    let closeThresholdHeight: CGFloat = 300
    let openThreshold: CGFloat = UIScreen.main.bounds.height - 200
    let closeThreshold = UIScreen.main.bounds.height - 300 // same value as closeThresholdHeight
    var panGestureRecognizer: UIPanGestureRecognizer?
    var animator: UIViewPropertyAnimator?

    private var lockPan = false

    override func viewDidLoad() {
        gotPanned(0)
        super.viewDidLoad()

        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(respondToPanGesture))
        view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.delegate = self
        panGestureRecognizer = gestureRecognizer
        
//        let youtubeURL = "https://www.youtube.com/watch?v=Rg6GLVUnnpM"
//        video.allowsInlineMediaPlayback = true
//        video.loadHTMLString("<iframe width=\"\(video.frame.width)\" height=\"\(video.frame.height)\" src=\"\(youtubeURL)?&playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
        
        getVideo(videoCode: "7Ueq-Tj9TJs")
    }
    
    //play video
    func getVideo(videoCode: String){
        let url = URL(string: "https://www.youtube.com/embed/\(videoCode)")
        video.loadRequest(URLRequest(url: url!))
    }

    func gotPanned(_ percentage: Int) {
        if animator == nil {
            animator = UIViewPropertyAnimator(duration: 1, curve: .linear, animations: {
                let scaleTransform = CGAffineTransform(scaleX: 1, y: 5).concatenating(CGAffineTransform(translationX: 0, y: 240))
                self.navBarView.transform = scaleTransform
                self.navBarView.alpha = 0
            })
            animator?.isReversed = true
            animator?.startAnimation()
            animator?.pauseAnimation()
        }
        animator?.fractionComplete = CGFloat(percentage) / 100
    }

    // MARK: methods to make the view draggable

    @objc func respondToPanGesture(recognizer: UIPanGestureRecognizer) {
        guard !lockPan else { return }
        if recognizer.state == .ended {
            let maxY = UIScreen.main.bounds.height - CGFloat(openThreshold)
            lockPan = true
            if maxY > self.view.frame.minY {
                maximize { self.lockPan = false }
            } else {
                minimize { self.lockPan = false }
            }
            return
        }
        let translation = recognizer.translation(in: self.view)
        moveToY(self.view.frame.minY + translation.y)
        recognizer.setTranslation(.zero, in: self.view)
    }

    func maximize(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.moveToY(0)
        }) { _ in
            if let completion = completion {
                completion()
            }
        }
    }

    func minimize(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.moveToY(self.closeThreshold)
        }) { _ in
            if let completion = completion {
                completion()
            }
        }
    }

    private func moveToY(_ position: CGFloat) {
        view.frame = CGRect(x: 0, y: position, width: view.frame.width, height: view.frame.height)

        let maxHeight = view.frame.height - closeThresholdHeight
        let percentage = Int(100 - ((position * 100) / maxHeight))

        gotPanned(percentage)

        let name = NSNotification.Name(rawValue: "BottomViewMoved")
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["percentage": percentage])
    }
    
    @IBAction func meetingClicked(_ sender: Any) {
        let eventStore:EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) {(granted, error) in
            if (granted) && (error) == nil
            {
                print("granted \(granted)")
                print("error \(error)")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = "Investment Meeting EyeRide CEO"
                event.startDate = Date()
                event.endDate = Date()
                event.notes = ""
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError{
                    print("error : \(error)")
                }
                print("Save Event")
            } else{
                print("error : \(error)")
            }
            
        }
    }
    
    
    
}

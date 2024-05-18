//
//  ContentView.swift
//  MC2-My
//
//  Created by baabguui on 5/18/24.
//

import SwiftUI
import ActivityKit

struct ContentView: View {
    @State private var activity: Activity<SampleDynamicAttributes>? = nil
    
    @State private var accumulated: Int = 0
    @State private var timer: Int = 5
    
//    func start() {
//        secondsTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
//    }
//    
//    func stop() {
//        secondsTimer.upstream.connect().cancel()
//    }
    
    // TODO: 60초 타이머
    func sixtyTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { sixty in
            timer -= 1
            if timer == 0 {
                sixty.invalidate()
                timer = 5
            }
        }
    }

//    func sixtyTimer(up accumulated: Int, down timer: Int){
//        if accumulated % 5 == 0 && accumulated != 0 {
//            start()
//        }
//        
//    }
    var body: some View {
        VStack {
            Text("\(accumulated)")
            Text("\(timer)")
            Button("start"){
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
                    accumulated += 1
                }
                Task {
                    try activity = Activity<SampleDynamicAttributes>
                        .request(attributes: SampleDynamicAttributes(), content: ActivityContent(state: SampleDynamicAttributes.ContentState(accumulated: accumulated, timer: timer, status: .accumulated), staleDate: nil))
                }
            }
        }
        .padding()
        .onChange(of: accumulated){
            Task {
                if accumulated % 10 == 0 && accumulated != 0 {
                    sixtyTimer()
                    print(timer.description)
                }
                if timer >= 0 && timer < 5 {
//                    try await LiveActivityManager.updateActivity(accumulated: accumulated, timer: timer, status: DynamicIslandStatus.timer)
                    try await activity?.update(ActivityContent(state: SampleDynamicAttributes.ContentState(accumulated: accumulated, timer: timer, status: .timer), staleDate: nil))
                } else {
//                    try await LiveActivityManager.updateActivity(accumulated: accumulated, timer: timer, status: DynamicIslandStatus.accumulated)
                    try await activity?.update(ActivityContent(state: SampleDynamicAttributes.ContentState(accumulated: accumulated, timer: timer, status: .accumulated), staleDate: nil))
                }
            }
            
        }
    }
}


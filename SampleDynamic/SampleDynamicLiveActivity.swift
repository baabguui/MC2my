//
//  SampleDynamicLiveActivity.swift
//  SampleDynamic
//
//  Created by baabguui on 5/18/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

enum DynamicIslandStatus: Codable {
    case timer
    case accumulated
}

struct SampleDynamicAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var accumulated: Int
        var timer: Int
        var status: DynamicIslandStatus
    }
    
    // Fixed non-changing properties about your activity go here!
}

struct SampleDynamicLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SampleDynamicAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.accumulated)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.center) {
                    switch context.state.status {
                    case .timer:
                        Text("\(context.state.timer)")
                            .foregroundColor(.green)
                            .contentTransition(.identity)
                            
                    case .accumulated:
                        Text("\(context.state.accumulated)")
                            .foregroundColor(.orange)
                            .contentTransition(.identity)
                    }
                }
                
            } compactLeading: {
                Text("\(context.state.timer)")
                    .opacity(context.state.timer < 10 ? 1 : 0)
            } compactTrailing: {
                Text("\(context.state.accumulated)")
                    .opacity(context.state.timer < 10 ? 0 : 1)
            } minimal: {
                ZStack {
                    Text("\(context.state.timer)")
                        .opacity(context.state.timer < 10 ? 1 : 0)
                    Text("\(context.state.accumulated)")
                        .opacity(context.state.timer < 10 ? 0 : 1)
                }
            }
            .keylineTint(Color.red)
        }
        
    }
}

//extension SampleDynamicAttributes {
//    fileprivate static var preview: SampleDynamicAttributes {
//        SampleDynamicAttributes(name: "World")
//    }
//}
//
//extension SampleDynamicAttributes.ContentState {
//    fileprivate static var smiley: SampleDynamicAttributes.ContentState {
//        SampleDynamicAttributes.ContentState(emoji: "😀")
//     }
//
//     fileprivate static var starEyes: SampleDynamicAttributes.ContentState {
//         SampleDynamicAttributes.ContentState(emoji: "🤩")
//     }
//}

//#Preview("Notification", as: .content, using: SampleDynamicAttributes.preview) {
//    SampleDynamicLiveActivity()
//} contentStates: {
//    SampleDynamicAttributes.ContentState.smiley
//    SampleDynamicAttributes.ContentState.starEyes
//}

//LiveActivity - start, end, update
//우리 코드에 맞지 않음. => 왜인지 몰라 생각해봐
class LiveActivityManager {
    
    @discardableResult
    static func startActivity(accumulated: Int, timer: Int, status: DynamicIslandStatus) throws -> String {
        
        var activity: Activity<SampleDynamicAttributes>?
        let initialState =  SampleDynamicAttributes.ContentState(accumulated: accumulated, timer: timer, status: status)
        
        do {
            activity = try Activity.request(attributes: SampleDynamicAttributes(), contentState: initialState, pushType: nil)
            
            guard let id = activity?.id else { throw
                LiveActivityErrorType.failedToGetID }
            return id
        } catch {
            throw error
        }
    }
    
    static func listAllActivities() -> [[String:Int]] {
        let sortedActivities = Activity<SampleDynamicAttributes>.activities.sorted{ $0.id > $1.id }
        
        return sortedActivities.map {
            [
                "accumulated": $0.contentState.accumulated,
                "timer": $0.contentState.timer
            ]
        }
    }
    
    static func endAllActivities() async {
        for activity in Activity<SampleDynamicAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
    }
    
    static func endActivity(_ id: String) async {
        await Activity<SampleDynamicAttributes>.activities.first?.end(dismissalPolicy: .immediate)
    }
    
    static func updateActivity(accumulated: Int, timer: Int, status: DynamicIslandStatus) async {
        
        let updatedContentState = SampleDynamicAttributes.ContentState(accumulated: accumulated, timer: timer, status: status)
        
        let activity = Activity<SampleDynamicAttributes>.activities[0]
        let activity2 = Activity<SampleDynamicAttributes>.activities[1]
        let activity3 = Activity<SampleDynamicAttributes>.activities[2]
        
        await activity.update(using: updatedContentState)
        await activity2.update(using: updatedContentState)
        await activity3.update(using: updatedContentState)
    }
    
}

enum LiveActivityErrorType: Error {
    case failedToGetID
}

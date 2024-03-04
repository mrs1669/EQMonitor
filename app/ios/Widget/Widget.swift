//
//  extension_example.swift
//  extension-example
//
//

import ActivityKit
import WidgetKit
import SwiftUI

@main
struct Widgets: WidgetBundle {
  var body: some Widget {
    if #available(iOS 16.1, *) {
      FootballMatchApp()
    }
  }
}

// We need to redefined live activities pipe
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState
  
  public struct ContentState: Codable, Hashable { }
  
  var id = UUID()
}

// Create shared default with custom group
let sharedDefault = UserDefaults(suiteName: "group.eqmonitor.widget")!

@available(iOSApplicationExtension 16.1, *)
struct FootballMatchApp: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      let matchName = sharedDefault.string(forKey: context.attributes.prefixedKey("matchName")) ?? ""
      
      let teamAName = sharedDefault.string(forKey: context.attributes.prefixedKey("teamAName")) ?? ""
      let teamAState = sharedDefault.string(forKey: context.attributes.prefixedKey("teamAState")) ?? ""
      let teamAScore = sharedDefault.integer(forKey: context.attributes.prefixedKey("teamAScore"))
      
      let teamBName = sharedDefault.string(forKey: context.attributes.prefixedKey("teamBName")) ?? ""
      let teamBState = sharedDefault.string(forKey: context.attributes.prefixedKey("teamBState")) ?? ""
      let teamBScore = sharedDefault.integer(forKey: context.attributes.prefixedKey("teamBScore"))
      
      let matchStartDate = Date(timeIntervalSince1970: sharedDefault.double(forKey: context.attributes.prefixedKey("matchStartDate")) / 1000)
      let matchEndDate = Date(timeIntervalSince1970: sharedDefault.double(forKey: context.attributes.prefixedKey("matchEndDate")) / 1000)
      let matchRemainingTime = matchStartDate...matchEndDate
      
      ZStack {
        LinearGradient(colors: [Color.black.opacity(0.5),Color.black.opacity(0.3)], startPoint: .topLeading, endPoint: .bottom)
        
        HStack {
          ZStack {
            VStack(alignment: .center, spacing: 2.0) {
              
              Spacer()
              
              Text(teamAName)
                .lineLimit(1)
                .font(.subheadline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
              
              Text(teamAState)
                .lineLimit(1)
                .font(.footnote)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            }
            .frame(width: 70, height: 120)
            .padding(.bottom, 8)
            .padding(.top, 8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            ZStack  {
         
            }
          }
          
          VStack(alignment: .center, spacing: 6.0) {
            HStack {
              Text("\(teamAScore)")
                .font(.title)
                .fontWeight(.bold)
              
              Text(":")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
              
              Text("\(teamBScore)")
                .font(.title)
                .fontWeight(.bold)
            }
            .padding(.horizontal, 5.0)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            HStack(alignment: .center, spacing: 2.0) {
              Text(timerInterval: matchRemainingTime, countsDown: true)
                .multilineTextAlignment(.center)
                .frame(width: 50)
                .monospacedDigit()
                .font(.footnote)
                .foregroundStyle(.white)
            }
            
            VStack(alignment: .center, spacing: 1.0) {
              Link(destination: URL(string: "eqmonitor://stats/")!) {
                Text("See stats 📊")
              }.padding(.vertical, 5).padding(.horizontal, 5)
              Text(matchName)
                .font(.footnote)
                .foregroundStyle(.white)
            }
          }
          .padding(.vertical, 6.0)
          
          ZStack {
            VStack(alignment: .center, spacing: 2.0) {
              
              Spacer()
              
              Text(teamBName)
                .lineLimit(1)
                .font(.subheadline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
              
              Text(teamBState)
                .lineLimit(1)
                .font(.footnote)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            }
            .frame(width: 70, height: 120)
            .padding(.bottom, 8)
            .padding(.top, 8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            ZStack {
            }
          }
        }
        .padding(.horizontal, 2.0)
      }.frame(height: 160)
    } dynamicIsland: { context in
      let matchName = sharedDefault.string(forKey: context.attributes.prefixedKey("matchName"))!
      
      let teamAName = sharedDefault.string(forKey: context.attributes.prefixedKey("teamAName"))!
      let teamAState = sharedDefault.string(forKey: context.attributes.prefixedKey("teamAState"))!
      let teamAScore = sharedDefault.integer(forKey: context.attributes.prefixedKey("teamAScore"))
      
      let teamBName = sharedDefault.string(forKey: context.attributes.prefixedKey("teamBName"))!
      let teamBState = sharedDefault.string(forKey: context.attributes.prefixedKey("teamBState"))!
      let teamBScore = sharedDefault.integer(forKey: context.attributes.prefixedKey("teamBScore"))
      
      let matchStartDate = Date(timeIntervalSince1970: sharedDefault.double(forKey: context.attributes.prefixedKey("matchStartDate")) / 1000)
      let matchEndDate = Date(timeIntervalSince1970: sharedDefault.double(forKey: context.attributes.prefixedKey("matchEndDate")) / 1000)
      let matchRemainingTime = matchStartDate...matchEndDate
      
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          VStack(alignment: .center, spacing: 2.0) {
            
            
            Spacer()
            
            Text(teamAName)
              .lineLimit(1)
              .font(.subheadline)
              .fontWeight(.bold)
              .multilineTextAlignment(.center)
            
            Text(teamAState)
              .lineLimit(1)
              .font(.footnote)
              .fontWeight(.bold)
              .multilineTextAlignment(.center)
          }
          .frame(width: 70, height: 120)
          .padding(.bottom, 8)
          .padding(.top, 8)
          
          
        }
        DynamicIslandExpandedRegion(.trailing) {
          VStack(alignment: .center, spacing: 2.0) {
            
            Spacer()
            
            Text(teamBName)
              .lineLimit(1)
              .font(.subheadline)
              .fontWeight(.bold)
              .multilineTextAlignment(.center)
            
            Text(teamBState)
              .lineLimit(1)
              .font(.footnote)
              .fontWeight(.bold)
              .multilineTextAlignment(.center)
          }
          .frame(width: 70, height: 120)
          .padding(.bottom, 8)
          .padding(.top, 8)
          
          
        }
        DynamicIslandExpandedRegion(.center) {
          VStack(alignment: .center, spacing: 6.0) {
            HStack {
              Text("\(teamAScore)")
                .font(.title)
                .fontWeight(.bold)
              
              Text(":")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
              
              Text("\(teamBScore)")
                .font(.title)
                .fontWeight(.bold)
            }
            .padding(.horizontal, 5.0)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            HStack(alignment: .center, spacing: 2.0) {
              Text(timerInterval: matchRemainingTime, countsDown: true)
                .multilineTextAlignment(.center)
                .frame(width: 50)
                .monospacedDigit()
                .font(.footnote)
                .foregroundStyle(.white)
            }
            
            VStack(alignment: .center, spacing: 1.0) {
              Link(destination: URL(string: "eqmonitor://stats")!) {
                Text("See stats 📊")
              }.padding(.vertical, 5).padding(.horizontal, 5)
              Text(matchName)
                .font(.footnote)
                .foregroundStyle(.white)
            }
            
          }
          .padding(.vertical, 6.0)
        }
      } compactLeading: {
        HStack {
          Text("\(teamAScore)")
            .font(.title)
            .fontWeight(.bold)
        }
      } compactTrailing: {
        HStack {
          Text("\(teamBScore)")
            .font(.title)
            .fontWeight(.bold)
        }
      } minimal: {
        ZStack {
        }
      }
    }
  }
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    return "\(id)_\(key)"
  }
}

@available(iOSApplicationExtension 16.2, *)
struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            LiveActivitiesAppAttributes(id: UUID()).previewContext(
                LiveActivitiesAppAttributes.ContentState()
                , viewKind: .dynamicIsland(.expanded))
        }
    }
}

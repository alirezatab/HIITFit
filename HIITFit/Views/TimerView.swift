/// Copyright (c) 2024 Kodeco LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

/// `CountdownView` displays `timeRemaining` in a large rounded system font,
/// surrounded by padding.
struct CountdownView: View {
  
  let date: Date
  @Binding var timeRemaining: Int
  let size: Double
  
  var body: some View {
    Text("\(timeRemaining)")
      .font(.system(size: size, design: .rounded))
      .padding()
    /// The `.onChange(of: date)` modifier in `CountdownView` updates
    /// `timeRemaining`, which also updates `timeRemaining` in `TimerView`.
      .onChange(of: date) { _ in
        timeRemaining -= 1
      }
  }
}

struct TimerView: View {
  
  @State private var timeRemaining: Int = 3
  @Binding var timerDone: Bool
  let size: Double
  
  var body: some View {
    /// You create a `TimelineView` with an
    /// `animation(minimumInterval:paused:)` schedule to update
    /// CountdownView every 1 second
    TimelineView(
      .animation(
        minimumInterval: 1.0,
        paused:  timeRemaining <= 0)) { context in
          /// The `Content` closure receives a TimelineView.
          /// `Context` that includes the date that triggered the update.
          /// You send this to `CountdownView` along with a binding
          /// to` timeRemaining`.
          CountdownView(
            date: context.date,
            timeRemaining: $timeRemaining,
            size: size)
        }
        .onChange(of: timeRemaining) { _ in
          if timeRemaining < 1 {
            ///When `timeRemaining` reaches 0, it sets `timerDone` to true.
            ///This enables the `Done` button in `ExerciseView`.
            timerDone = true
          }
        }
  }
}

#Preview {
  TimerView(timerDone: .constant(false), size: 90)
}

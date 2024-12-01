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
import Charts

struct BarChartWeekView: View {
  
  @EnvironmentObject var history: HistoryStore
  @State private var weekData: [ExerciseDay] = []
  @State private var isBarChart = true
  
  var body: some View {
    VStack {
      Text("History for Last Week")
        .font(.headline)
        .padding()
      // 1 - When you don’t need a separate ForEach, you can initialize Chart with the chart data. You use the first seven elements of exerciseDays. Seven is the maximum value, so if there aren’t seven elements in the array, only the available elements are used.
      //Chart(history.exerciseDays.prefix(7)) { day in
      /// The preview data only has four days of data, and these show from left to right in reverse date order. It’s usual to show week data with the last date on the trailing edge. The preview data skips a day, but the chart doesn’t show zero exercises on that day. You can ensure that the chart shows all days by choosing a unit.
      if isBarChart {
        Chart(weekData) { day in
          // For each day, you iterate through all the four exercise names. Exercise.names is a property in Exercise.swift. You accumulate the current exercises into the bar mark.
          ForEach(Exercise.names, id: \.self) { name in
            BarMark(
              x: .value("Date", day.date, unit: .day),
              y: .value("Total Count", day.countExercises(name)))
            // Instead of using a color to determine the style, you separate out the bar by exercise.
            .foregroundStyle(by: .value("Exercise", name))
            // customize the chart with different colors.
          }
        }
        .chartForegroundStyleScale([
          "Burpee": Color("chart-burpee"),
          "Squat": Color("chart-squat"),
          "Step Up": Color("chart-step-up"),
          "Sun Salute": Color("chart-sun-salute")
        ])
        .padding()
      } else {
        Chart(weekData) { day in
          LineMark(
            x: .value("Date", day.date, unit: .day),
            y: .value("Total Count", day.exercises.count))
          .symbol(.circle)
          .interpolationMethod(.catmullRom)
        }
        .padding()
      }
      Toggle("Bar Chart", isOn: $isBarChart)
        .padding()
    }
    .onAppear {
      // 1 - Find out the first date in history. If there isn’t one, use the current date.
      let firstDate = history.exerciseDays.first?.date ?? Date()
      // 2 - Set up an array using a method already created for you in DateExtension.swift.
      let dates = firstDate.previousSevenDays
      // 3 - Iterate through the array of dates and for each date, locate the first entry for that date. If there isn’t one, create a new blank ExerciseDay.
      weekData = dates.map { date in
        history.exerciseDays.first(
          where: { $0.date.isSameDay(as: date) }) ?? ExerciseDay(date: date)
      }
    }
  }
}

#Preview {
  BarChartWeekView()
    .environmentObject(HistoryStore(preview: true))
}

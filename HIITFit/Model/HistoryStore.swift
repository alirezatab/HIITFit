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

import Foundation

/// `ExerciseDay` conforms to `Identifiable`.
/// This protocol is useful for named types that you plan to use as elements of a collection, because you usually want to loop over these elements or display them in a list.
struct ExerciseDay: Identifiable {
  var id = UUID()
  var date: Date
  var exercises: [String] = []
}

class HistoryStore: ObservableObject {
  
  enum FileError: Error {
    case loadFailure
    case saveFailure
  }
  
  @Published var exerciseDays: [ExerciseDay] = []
  @Published var loadingError = false
  
  let result: (ExerciseDay) -> [Any] = { exerciseDay in
    [
      exerciseDay.id.uuidString,
      exerciseDay.date,
      exerciseDay.exercises
    ]
  }
    
  // You add the file name to the documents path. This gives you the full URL of the file to which you’ll write the history data.
  var dataURL: URL {
    URL.documentsDirectory.appendingPathComponent("history.plist")
  }
  
  init() {
    #if DEBUG
    // createDevData()
    #endif
    do {
      try load()
    } catch {
      loadingError = true
    }
  }
  
  func addDoneExercise(_ exerciseName: String) {
    let today = Date()
    /// The `date` of the first element of `exerciseDays` is the user’s most recent exercise day.
    /// If `today` is the same as this date, you append the current `exerciseName` to the `exercises`
    /// array of this `exerciseDay`.
    if let firstDate = exerciseDays.first?.date,
       today.isSameDay(as: firstDate) {
      print("Adding \(exerciseName)")
      exerciseDays[0].exercises.append(exerciseName)
    } else {
      /// If `today` is a new day, you create a new `ExerciseDay` object and insert it at the
      /// beginning of the `exerciseDays` array.
      exerciseDays.insert(
        ExerciseDay(date: today, exercises: [exerciseName]), at: 0)
    }
    do {
      try save()
    } catch {
      fatalError(error.localizedDescription)
    }
  }
  
  func load() throws {
    do {
      /// Read the data file into a byte buffer. This buffer is in the property list format.
      /// If `history.plist` doesn’t exist on disk, `Data(contentsOf:)` will throw an error. Throwing an error is not correct in this case, as there will be no history when your user first launches your app. You’ll fix this error at the end of this chapter.
      guard let data = try? Data(contentsOf: dataURL) else { return }
      
      /// Convert the property list format into a format that your app can read.
      let plistData = try PropertyListSerialization.propertyList(
        from: data,
        options: [],
        format: nil)
      
      /// When you serialize from a property list, the result is always of type Any. To cast to another type, you use the type cast operator `as?`. This will return `nil` if the type cast fails. Because you wrote `history.plist` yourself, you can be pretty sure about the contents, and you can cast `plistData` from type `Any` to the `[[Any]]` type that you serialized out to file. If for some reason history.plist isn’t of type [[Any]], you provide a fall-back of an empty array using the nil coalescing operator ??.
      let convertedPlistData = plistData as? [[Any]] ?? []
      
      /// With `convertedPlistData` cast to the expected type of `[[Any]]`, you use `map(_:)` to convert each element of `[Any]` back to `ExerciseDay`. You also ensure that the data is of the expected type and provide fall-backs if necessary.
      exerciseDays = convertedPlistData.map{
        ExerciseDay(
          date: $0[1] as? Date ?? Date(),
          exercises: $0[2] as? [String] ?? [])
      }
    } catch {
      throw FileError.loadFailure
    }
  }
  
  func save() throws {
    let plistData: [[Any]] = exerciseDays.map {
      [ $0.id.uuidString, $0.date, $0.exercises ]
    }
    
    do {
      // 1- You convert your history data to a serialized property list format. The result is a Data type, which is a buffer of bytes.
      let data = try PropertyListSerialization.data(
        fromPropertyList: plistData,
        format: .binary,
        options: .zero)
      // 2 - You write to disk using the URL you formatted earlier.
      try data.write(to: dataURL, options: .atomic)
    } catch {
      // 3 - The conversion and writing may throw errors, which you catch by throwing an error.
      throw FileError.saveFailure
    }
  }
}

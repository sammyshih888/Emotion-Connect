//
//  Records.swift
//  QuizGame (iOS)
//
//  Created by 
//

import SwiftUI

struct Records: View {
    
    
    
    var body: some View {
        VStack {
        }
        
    }
}

struct Records_Previews: PreviewProvider {
    static var previews: some View {
        Records()
    }
}

class Record : Codable, Identifiable {
    var id = UUID()
    var user : String = ""
    var star : Int  = 0
    var dateTime = Date.now
    
    init( user: String, star: Int) {
        self.user = user
        self.star = star
    }
}


class RecordStore : ObservableObject {
    
    @Published var recList = [Record]()
    
    
    let storeKey : String = "RecordList"
    
    
    init() {
        load()
    }
    
    func addRecord( username : String , nStar : Int) {
        recList.append( Record( user : username , star : nStar ))
    }
    
    func load() {
        
        guard let data = UserDefaults.standard.data(forKey: storeKey),
              let savedData = try? JSONDecoder().decode([Record].self, from: data) else { recList = []; return }
        
        
        recList = savedData
    }
    
    
    
    func save() {
        do {
            let data = try JSONEncoder().encode(recList)
            UserDefaults.standard.set(data, forKey: storeKey)
        } catch {
            print(error)
        }
    }
    
    func clear() {
        recList.removeAll()
        addRecord(username: "", nStar: 3)
        save()
    }
}

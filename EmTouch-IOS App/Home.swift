//
//  Home.swift
//  QuizGame (iOS)
//
//  Created by
//

import SwiftUI
import AVKit

struct Home: View {
    // MARK: Current Puzzle
    @State var currentPuzzle: Puzzle = (puzzles.randomElement() ?? puzzles[0])
    @State var selectedImgs: [String] = []
    @State var correctImgs: [String] = []
    @State var score: Int = 0 // todo:debug value change
    
    @State var startDate = Date.now
    @State var timeElapsed: Int = 0
    @State var switchQuiz: Bool = false
    @State var switchTime: Int = 0
    @State var heartSize = 1.5
    @State var recStore = RecordStore()
    @State var username: String=""
    @State private var disableTextField = false
    
    @State var pageState: Int=0
    @State var audioPlayer: AVAudioPlayer!
       
    
    @State var count: Int = 1
    @State var confirmClear: Bool=false
    
    init(){
        restartGame()
    }
    
    // 1
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        
            VStack{
                
                if pageState==1{
                    
                        HStack{
                            Button{
                                restartGame()
                                pageState=0
                            }label: {
                                Text("重新開始")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .frame(width:105)
                                    .background(Color("Gold"),in: RoundedRectangle(cornerRadius: 12))
                                    .padding()
                            }
                            
                            Text("榮譽榜").font(.largeTitle).frame(width: 150 , alignment: .center)
                            Button {
                                confirmClear = true
                            } label: {
                                Image(systemName: "trash")
                                    .font(.title3)
                                    .padding(10)
                                    .background(.gray,in: RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(.white)
                                    .frame(width: 110)
                            }.confirmationDialog("清除紀錄",
                                                 isPresented: $confirmClear) {
                                Button("確定要清除", role: .destructive) {
                                    self.recStore.clear()
                                }
                                Button("取消", role: .cancel){
                                    
                                }
                            }
                        }
                        Text("最佳紀錄").font(.title2).foregroundColor(.brown)
                        List {
                            let rec = self.recStore.recList.max(by: {a, b in a.star < b.star})!
                            HStack{
                                if rec.star >= 0 && rec.user.count>0{
                                    HStack{
                                        ForEach(0..<rec.star ,id: \.self){index in
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(.red).frame(width: 12)
                                            
                                        }
                                    }.frame(width: 120 , alignment: .leading)
                                    Text(rec.user+" ").frame(width: 140 , alignment: .leading)
                                    let dt = rec.dateTime.formatted(date: .numeric, time: .omitted)
                                    let tIdx = dt.lastIndex(of: "/")
                                    Text(dt[..<tIdx!])
                                }
                            }
                        }.frame(height: 100)
                        Text("成績紀錄").font(.title2).foregroundColor(.brown)
                        
                        Form {
                            ForEach(self.recStore.recList) {
                                rec in
                                if rec.star >= 0 && rec.user.count>0{
                                HStack{
                                    
                                        HStack{
                                            ForEach(0..<rec.star ,id: \.self){index in
                                                Image(systemName: "heart.fill")
                                                    .foregroundColor(.red).frame(width: 12)
                                                
                                            }
                                        }.frame(width: 120 , alignment: .leading)
                                        Text(rec.user+" ").frame(width: 140 , alignment: .leading)
                                        let dt = rec.dateTime.formatted(date: .numeric, time: .omitted)
                                        let tIdx = dt.lastIndex(of: "/")
                                        Text(dt[..<tIdx!])
                                    }
                                    
                                }
                            }
                        }
                }else if timeElapsed<60     {
                    
                    
                    HStack{
                        ForEach(0..<6,id: \.self){index in
                            //                    Image(systemName: "heart.fill")
                            Image(systemName: index<score ? "heart.fill": "heart")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                        
                    }.padding()
                    VStack{
                        
                        // MARK: Puzzle Image
                        Image(currentPuzzle.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                        HStack(spacing:20){
                            Text(currentPuzzle.text)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Button {
                                let sound = Bundle.main.path(forResource: currentPuzzle.media, ofType: currentPuzzle.ext)
                                self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
                                audioPlayer.play()
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title3)
                                    .padding(10)
                                    .background(Color("Blue"),in: Circle())
                                    .foregroundColor(.white)
                            }.onAppear(){
                                let sound = Bundle.main.path(forResource: currentPuzzle.media, ofType: currentPuzzle.ext)
                                self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
                                audioPlayer.play()
                            }
                        }
                        
                        // MARK: Puzzle Fill Blanks
                        HStack(spacing: 10){
                            
                            // Why Index?
                            // Bcz it will help to read the selected letters in order
                            // Shown later in the video
                            
                            
                            ForEach(0..<5,id: \.self){index in
                                ZStack{
                                    if index < correctImgs.count  {
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("Blue").opacity(1))
                                            .frame(height: 60)
                                        
                                        Image(correctImgs[index])
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .opacity(0.9)
                                            .scaleEffect(correctImgs.count==5 ? 1.2:1)
                                            .animation( .easeIn(duration: 2) , value: 20 )
                                        
                                        
                                        
                                    }else{
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("Blue").opacity(0.2))
                                            .frame(height: 60)
                                    }
                                }
                                
                            }
                        }
                        if correctImgs.count==5{
                            Button {
                            } label: {
                                Text("恭喜你！！ 挑戰下一個")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                                    .frame( maxWidth :.infinity)
                                    .background(Color("Blue"),in: RoundedRectangle(cornerRadius: 15))
                            }
                            .opacity(correctImgs.count<5 ? 0:1)
                            .animation( .easeIn , value: 40  )
                            .task {
                                await reset()
                            }
                        }
                    }
                    .padding()
                    .background(.white,in: RoundedRectangle(cornerRadius: 15))
                    
                    
                    
                    // MARK: Custom Honey Comb Grid View
                    HoneyCombGridView(items: currentPuzzle.imgOptions) { item in
                        // MARK: Hexagon Shape
                        ZStack{
                            HexagonShape()
                                .fill(isSelected(imgOpt: item) ? ( isMatched(imgOpt: item) ? Color("Gold"):.red.opacity(0.5)) : .white.opacity(0.3))
                                .aspectRatio(contentMode: .fit)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 10, y: 5)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: 8)
                            
                            if isSelected(imgOpt: item) && !(isMatched(imgOpt: item)){
                                Image(item)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(HexagonShape())
                                    .opacity(0.2)
                            }else{
                                Image(item)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(HexagonShape())
                                    .padding(3)
                            }
                            
                            
                        }
                        .contentShape(HexagonShape())
                        .onTapGesture {
                            // Adding the Current Letter
                            addImg(imgOpt: item)
                        }
                        
                        
                    }
                    
                    // MARK: Next Button
                    HStack(spacing: 20){
                        Text("\(60-timeElapsed) 秒")
                            .onReceive(timer) { firedDate in
                                
                                // print("timer fired")
                                // 3
                                timeElapsed = Int(firedDate.timeIntervalSince(startDate))
                                
                            }
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                            .frame(width: 150)
                            .background(Color("BG"),in: RoundedRectangle(cornerRadius: 15))
                        
                        
                        
                        
                        Button {
                            // Changing into next Puzzle
                            // generating letters for new Puzzle
                            generateOptImgs()
                        } label: {
                            Text("更多")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.vertical)
                                .frame(width:120)
                                .background(Color("Gold"),in: RoundedRectangle(cornerRadius: 15))
                        }
                        .disabled(false)
                        .opacity(1)
                        
                    }
                }else{
                    GifImage("trophy").frame(height : 250 )
                    HStack{
                        ForEach(0..<6 ,id: \.self){index in
                            if index < score {
                                GifImage("heart").scaledToFit()
                            }else{
                                Image(systemName: "heart")
                                    .foregroundColor(.red).scaledToFit()
                            }
                        }
                    }.padding(.vertical)
                    Text("~ 恭喜你 ~")
                        .font(.title.bold())
                        .foregroundColor(.red)
                        .frame( maxWidth :.infinity)
                        .onAppear(){
                            let sound = Bundle.main.path(forResource: "success", ofType: "mp3")
                            self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
                            audioPlayer.play()
                        }
                    HStack{
                        TextField("你的名字", text: $username, prompt : Text("你的名字").font(.title).foregroundColor(.gray.opacity(disableTextField ? 0.7:1)))
                            .disabled(disableTextField)
                            .frame(width : 200  )
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.asciiCapable)
                            .padding(.vertical)
                        Button {
                            if username.count>0 {
                                disableTextField = true
                                recStore.addRecord(username: username, nStar:score)
                                recStore.save()
                            }
                        } label: {
//                            Text("紀錄")
                            Label("保存", systemImage: "checkmark")
                                .frame( width :100 , height : 40 )
                                .foregroundColor(.white)
                                .background(.blue.opacity(disableTextField ? 0.2:1),in: RoundedRectangle(cornerRadius: 5))
                        }
                        .disabled(disableTextField)
                        .padding(.vertical)
                    }
                    Button {
                        restartGame()
                    } label: {
                        Text("重新開始")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(width:150)
                            .background(Color("Gold"),in: RoundedRectangle(cornerRadius: 15))
                    }.padding(.vertical)
         
                    Button{
                        pageState = 1
                    }label: {
                        Text("分數紀錄")
                            .font(.title)
                            .foregroundColor(.gray)
                            .frame(width: 150 ,height: 50 )
                            .padding()
                    }
                    
                    
                }
                
            }// end VStack
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
            .background(Color("BG"))
            .onAppear {
                // Generating Letters
                generateOptImgs()
            }
        
        
        
    }
    
    private func reset() async {
        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        resetQuiz()
    }
    
    func addImg(imgOpt: String){
        
        withAnimation{
            if isSelected(imgOpt: imgOpt){
                // Removing
                correctImgs.removeAll { currentImg in
                    return currentImg == imgOpt
                }
                selectedImgs.removeAll { currentImg in
                    return currentImg == imgOpt
                }
            }
            else{
                selectedImgs.append(imgOpt)
                if isMatched(imgOpt: imgOpt){
                    correctImgs.append(imgOpt)
                }
                
                if correctImgs.count == 5 && !switchQuiz {
                    score += 1
                    switchQuiz.toggle()
                    switchTime = timeElapsed
                    //resetQuiz()
                }
            }
        }
    }
    
    // Checking if there is one Already
    func isSelected(imgOpt: String)->Bool{
        return selectedImgs.contains { currentImg in
            return currentImg == imgOpt
        }
    }
    
    func isMatched(imgOpt: String)->Bool{
        return  imgOpt.hasPrefix( currentPuzzle.tag)
    }
    
    func generateOptImgs(){
        currentPuzzle.imgOptions.removeAll()
        for _ in 1...7 {
            var img = "\(emtypes.randomElement() ?? "H" )\(Int.random(in: 0...31))"
            while currentPuzzle.imgOptions.contains(img) || selectedImgs.contains(img){
                img = "\(emtypes.randomElement() ?? "H" )\(Int.random(in: 0...31))"
            }
            currentPuzzle.imgOptions.append(img  )
        }
    }
    
    func restartGame(){
        resetQuiz()
        score = 0
        //        timeElapsed = 0
        disableTextField = false
        startDate = Date.now
        timeElapsed = Int(Date.now.timeIntervalSince(startDate))
    }
    
    func resetQuiz(){
        selectedImgs.removeAll()
        correctImgs.removeAll()
        var tmpCurrentPuzzle = (puzzles.randomElement() ?? puzzles[0])
        while tmpCurrentPuzzle.imageName == currentPuzzle.imageName {
            tmpCurrentPuzzle = (puzzles.randomElement() ?? puzzles[0])
        }
        currentPuzzle = tmpCurrentPuzzle
        switchQuiz = false
        generateOptImgs()
    }
    
}




struct Home_Previews: PreviewProvider {

    static var previews: some View {
        Home()
    }
}

//
//  ContentView.swift
//  WordScrumble
//
//  Created by Roman on 10/31/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        
        VStack{
            
            Text("Word scrumble")
                .frame(width: 300, height: 50, alignment: .center)
                
                .font(.largeTitle.bold())
                
               
        NavigationView{
          
                    
                 
            List{
                
                
                Section("Enter your word"){
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                Section(){
                    ForEach(usedWords, id: \.self){
                        word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        
                            
                    }
                    
                }
            }.navigationTitle(rootWord)
                .onSubmit {addNewWord(word: newWord)}
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError){
                    Button("OK", role: .cancel){}
                    
                }message: {
                    Text(errorMessage)
                }
            }
        }
    }
    func startGame(){
        if let fileUrl =  Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let fileConents = try? String(contentsOf: fileUrl){
                let allWords = fileConents.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkwork"
                return
            }
        }
        fatalError("Could not load start.txt ")
            
    }
    
    func addNewWord(word: String){
        guard  word.utf16.count > 0 else {return}
        let trimmed = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard isOriginal(word: trimmed) else{
            wordError(title: "Word already used", message: "Be more original")
            return
        }
        guard isPossible(word: trimmed) else{
            wordError(title: "Word is not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        guard isReal(word: trimmed) else {
            wordError(title: "Word not recognized", message: "You can't just make them up")
            return
        }
        
        withAnimation{
            usedWords.insert(trimmed, at: 0)
        }
        
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var rootCopy = rootWord
        for char in word{
            if let i = rootCopy.firstIndex(of: char) {
                rootCopy.remove(at: i) // i is character index
            }else{
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
        
    }
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

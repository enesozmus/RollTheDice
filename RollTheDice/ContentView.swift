//
//  ContentView.swift
//  RollTheDice
//
//  Created by enesozmus on 14.04.2024.
//

import SwiftUI

struct ContentView: View {
    
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedRolls.json")
    @State private var savedResults = [Dice]()
    
    let diceOptions = [4, 6, 8, 10, 12, 20, 100]
    
    @AppStorage("diceSides") var diceSides = 6
    @AppStorage("rollAmount") var rollAmount = 1
    
    @State private var rollResult = Dice(type: 0, number: 0)
    
    let timer = Timer.publish(every: 0.1, tolerance: 0.1, on: .main, in: .common).autoconnect()
    @State private var stoppedDice = 0
    
    @State private var showingResult = false
    
    let columns: [GridItem] = [
        .init(.adaptive(minimum: 60))
    ]
    
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    @State private var feedback = UIImpactFeedbackGenerator(style: .rigid)
    
    // ...
    var body: some View {
        VStack {
            List {
                Section {
                    Picker("Dice type", selection: $diceSides) {
                        ForEach(diceOptions, id: \.self) { dice in
                            Text("D\(dice)")
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Stepper("Number of dice: \(rollAmount)", value: $rollAmount, in: 1...20)
                    
                } footer: {
                    LazyVGrid(columns: columns) {
                        ForEach(0..<rollResult.rolls.count, id: \.self) { rollNumber in
                            Text(String(rollResult.rolls[rollNumber]))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .foregroundColor(.black)
                                .background(.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                                .font(.title)
                                .padding(5)
                        }
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("Latest roll: \(rollResult.rolls.map(String.init).joined(separator: ", "))")
                
                if savedResults.isEmpty == false {
                    Section("Previous results") {
                        ForEach(savedResults) { result in
                            VStack(alignment: .leading) {
                                Text("\(result.number) x D\(result.type)")
                                    .font(.headline)
                                    .foregroundStyle(.teal)
                                Text(result.rolls.map(String.init).joined(separator: ", "))
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
            }
            .onAppear(perform: load)
            .onReceive(timer) { date in
                updateDice()
            }
            .navigationTitle("High Rollers")
            .disabled(stoppedDice < rollResult.rolls.count)
            if savedResults.isEmpty == false {
                Button("Clear", action: clear)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("\(rollResult.number) D\(rollResult.type), \(rollResult.rolls.map(String.init).joined(separator: ", "))")
        
        VStack {
            Button {
                diceRoll()
            } label: {
                Text("Roll the Dice!")
                Image(systemName: "dice.fill")
            }
        }
    }
    
    // ...
    // functions
    func updateDice() {
        guard stoppedDice < rollResult.rolls.count else { return }
        
        for i in stoppedDice..<rollAmount {
            if i < 0 { continue }
            rollResult.rolls[i] = Int.random(in: 1...diceSides)
        }
        feedback.impactOccurred()
        stoppedDice += 1
        
        if stoppedDice == rollAmount {
            savedResults.insert(rollResult, at: 0)
            save()
        }
    }
    
    func diceRoll() {
        rollResult = Dice(type: diceSides, number: rollAmount)
        showingResult = true
        if voiceOverEnabled { stoppedDice = rollAmount
            savedResults.insert(rollResult, at: 0)
            save()
        } else {
            stoppedDice = -20
        }
    }
    
    func load() {
        if let data = try? Data(contentsOf: savePath) {
            if let results = try? JSONDecoder().decode([Dice].self, from: data) {
                savedResults = results
            }
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(savedResults) {
            try? data.write(to: savePath, options: [.atomic, .completeFileProtection])
        }
    }
    
    func clear() {
        savedResults = []
    }
}

#Preview {
    ContentView()
}

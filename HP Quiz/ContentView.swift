//
//  ContentView.swift
//  HP Quiz
//
//  Created by Fernando Draghi on 13/11/2024.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject private var store: Store
    @EnvironmentObject private var game: GameViewModel
    @State private var audioPlayer: AVAudioPlayer!
    @State private var scalePlayButton = false
    @State private var moveBackgroundImage = false
    @State private var animateViewsIn = false
    @State private var showInstructions = false
    @State private var showSettings = false
    @State private var showGameplay = false

    var body: some View {
        GeometryReader { g in
            ZStack {
                Image("hogwarts")
                    .resizable()
                    .frame(width: g.size.width * 3, height: g.size.height)
                    .padding(.top, 3)
                    .offset(x: moveBackgroundImage ? g.size.width / 1.1 : -g.size.width / 1.1)
                    .onAppear() {
                        withAnimation(.linear(duration: 60).repeatForever()) {
                            moveBackgroundImage.toggle()
                        }
                    }
                
                VStack {
                    VStack {
                        if animateViewsIn {
                            VStack {
                                Image(systemName: "bolt.fill")
                                    .font(.largeTitle)
                                    .imageScale(.large)
                                
                                Text("HP")
                                    .font(.hpFont(size: 70))
                                    .padding(.bottom, -50)
                                
                                Text("Trivia")
                                    .font(.hpFont(size: 60))
                            }
                            .padding(.top, 70)
                            .transition(.move(edge: .top))
                        }
                    }
                    .animation(.easeOut(duration: 0.7).delay(2), value: animateViewsIn)
                    
                    Spacer()
                    VStack {
                        if animateViewsIn {
                            VStack {
                                Text("Recent Scores")
                                    .font(.title2)
                                Text("\(game.recentScores[0])")
                                Text("\(game.recentScores[1])")
                                Text("\(game.recentScores[2])")
                            }
                            .font(.title3)
                            .padding(.horizontal)
                            .foregroundStyle(.white)
                            .background(.black.opacity(0.7))
                            .clipShape(.rect(cornerRadius: 15))
                            .transition(.opacity)
                        }
                    }
                    .animation(.linear(duration: 1).delay(4), value: animateViewsIn)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        VStack {
                            if animateViewsIn {
                                Button {
                                    showInstructions.toggle()
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 5)
                                }
                                .transition(.offset(x: -g.size.width / 4))
                                .sheet(isPresented: $showInstructions) {
                                    InstructionsScreen()
                                }
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2.7), value: animateViewsIn)
                        Spacer()
                        VStack {
                            if animateViewsIn {
                                Button {
                                    filterQuestions()
                                    game.startGame()
                                    showGameplay.toggle()
                                    audioPlayer.stop()
                                } label: {
                                    Text("Play")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .padding(.vertical, 7)
                                        .padding(.horizontal, 50)
                                        .background(questionsAvailable ? .brown : .gray)
                                        .clipShape(.rect(cornerRadius: 5))
                                        .shadow(radius: 5)
                                }
                                .scaleEffect(scalePlayButton ? 1.2 : 1.0)
                                .onAppear() {
                                    withAnimation(.easeInOut(duration: 1.3).repeatForever()) {
                                        scalePlayButton.toggle()
                                    }
                                }
                                .transition(.offset(y: g.size.height / 3))
                                .fullScreenCover(isPresented: $showGameplay) {
                                    GameplayScreen()
                                        .environmentObject(game)
                                }
                                .disabled(!questionsAvailable)
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2), value: animateViewsIn)
                        
                        Spacer()
                        VStack {
                            if animateViewsIn {
                                Button {
                                    showSettings.toggle()
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 5)
                                }
                                .transition(.offset(x: g.size.width / 4))
                                .sheet(isPresented: $showSettings) {
                                    SettingsScreen()
                                }
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2.7), value: animateViewsIn)
                        
                        Spacer()
                    }
                    .frame(width: g.size.width)
                    VStack {
                        if animateViewsIn {
                            Text("No questions available, please go to settings to select at least one book.")
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                        }
                            
                    }
                    .opacity(questionsAvailable ? 0 : 1)
                    .frame(width: g.size.width * 0.8)
                    .padding(.top, 15)
                    .animation(.easeInOut.delay(3), value: animateViewsIn)
                    Spacer()
                }
            }
            .frame(width: g.size.width,
                   height: g.size.height)
        }
        .ignoresSafeArea()
        .onAppear() {
            animateViewsIn = true
            playAudio()
        }
    }

    var questionsAvailable: Bool {
        store.books.contains(.selected)
    }

    private func playAudio() {
        guard let sound = Bundle.main.path(forResource: "magic-in-the-air", ofType: "mp3") else {
            print("Audio file not found!")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(filePath: sound))
            
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch {
            print("Audioplayer failed: \(error)")
        }
    }
    
    private func filterQuestions() {
        var enabledBooks = [Int]()
        
        for (index, status) in store.books.enumerated() {
            if status == .selected {
                enabledBooks.append(index)
            }
        }
        
        game.filterQuestions(to: enabledBooks)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
        .environmentObject(Store())
}

//
//  GameplayScreen.swift
//  HP Quiz
//
//  Created by Fernando Draghi on 14/11/2024.
//

import SwiftUI
import AVKit

struct GameplayScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var game: GameViewModel
    @Namespace private var namespace
    @State private var animateViewsIn = false
    @State private var tappedCorrectAnswer = false
    @State private var hintWiggle = false
    @State private var scaleNextButton = false
    @State private var movePointsToScore = false
    @State private var revealHint = false
    @State private var revealBook = false
    @State private var tappedAnswers = [String]()
    @State private var musicPlayer: AVAudioPlayer!
    @State private var sfxPlayer: AVAudioPlayer!
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Image("hogwarts")
                    .resizable()
                    .frame(width: g.size.width * 3, height: g.size.height * 1.05)
                    .overlay {
                        Rectangle()
                            .foregroundStyle(.black.opacity(0.8))
                    }
                
                VStack {
                    // MARK: Top Controls
                    HStack {
                        Button("End Game") {
                            game.endGame()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red.opacity(0.5))
                        
                        Spacer()
                        
                        Text("Score: \(game.gameScore)")
                    }
                    .padding()
                    .padding(.vertical, 30)
                    
                    // MARK: Question
                    VStack {
                        if animateViewsIn {
                            Text(game.currentQuestion.question)
                                .font(.hpFont(size: 50))
                                .multilineTextAlignment(.center)
                                .padding()
                                .transition(.scale)
                                .opacity(tappedCorrectAnswer ? 0.1 : 1)
                        }
                    }
                    .animation(.easeInOut(duration: animateViewsIn ? 2 : 0), value: animateViewsIn)
                    
                    Spacer()
                    
                    // MARK: Hints
                    HStack {
                        VStack {
                            if animateViewsIn {
                                Button {
                                    withAnimation(.easeOut(duration: 1)) {
                                        revealHint = true
                                    }
                                    playFipSound()
                                    game.didUseHint()
                                } label: {
                                    Image(systemName: "questionmark.app.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100)
                                        .foregroundStyle(.cyan)
                                        .rotationEffect(hintWiggle ? .degrees(-15) : .degrees(-17))
                                        .padding()
                                        .padding(.leading, 20)
                                        .transition(.offset(x: -g.size.width / 2))
                                        .rotation3DEffect(.degrees(revealHint ? 1440 : 0), axis: (x: 0, y: 1, z: 0))
                                        .scaleEffect(revealHint ? 5 : 1)
                                        .opacity(revealHint ? 0 : 1)
                                        .offset(x: revealHint ? g.size.width / 2 : 0)
                                        .overlay(
                                            Text(game.currentQuestion.hint)
                                                .padding(.leading, 33)
                                                .minimumScaleFactor(0.5)
                                                .multilineTextAlignment(.center)
                                                .opacity(revealHint ? 1 : 0)
                                                .scaleEffect(revealHint ? 1.33 : 1)
                                        )
                                        .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                }
                                .disabled(tappedCorrectAnswer || revealHint)
                                .onAppear() {
                                    withAnimation(
                                        .easeInOut(duration: 0.1)
                                        .repeatCount(9)
                                        .delay(5)
                                        .repeatForever()) {
                                            hintWiggle = true
                                        }
                                }
                            }
                        }
                        .animation(.easeOut(duration: animateViewsIn ? 1.5 : 0).delay(animateViewsIn ? 2.1 : 0), value: animateViewsIn)
                        
                        Spacer()
                        VStack {
                            if animateViewsIn {
                                Button {
                                    withAnimation(.easeOut(duration: 1)) {
                                        revealBook = true
                                    }
                                    playFipSound()
                                    game.didUseHint()
                                } label: {
                                    Image(systemName: "book.closed")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50)
                                        .foregroundStyle(.black)
                                        .frame(width: 100, height: 100)
                                        .background(.cyan)
                                        .clipShape(.rect(cornerRadius: 20))
                                        .rotationEffect(hintWiggle ? .degrees(15) : .degrees(17))
                                        .padding()
                                        .padding(.trailing, 20)
                                        .transition(.offset(x: g.size.width / 2))
                                        .rotation3DEffect(.degrees(revealBook ? 1440 : 0), axis: (x: 0, y: 1, z: 0))
                                        .scaleEffect(revealBook ? 5 : 1)
                                        .opacity(revealBook ? 0 : 1)
                                        .offset(x: revealBook ? -g.size.width / 2 : 0)
                                        .overlay(
                                            Image("hp\(game.currentQuestion.book)")
                                                .resizable()
                                                .scaledToFit()
                                                .padding(.trailing, 33)
                                                .opacity(revealBook ? 1 : 0)
                                                .scaleEffect(revealBook ? 1.33 : 1)
                                        )
                                        .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                }
                                .disabled(tappedCorrectAnswer || revealBook)
                                .onAppear() {
                                    withAnimation(
                                        .easeInOut(duration: 0.1)
                                        .repeatCount(9)
                                        .delay(5)
                                        .repeatForever()) {
                                            hintWiggle = true
                                        }
                                }
                            }
                        }
                        .animation(.easeOut(duration: animateViewsIn ? 1.5 : 0).delay(animateViewsIn ? 2 : 0), value: animateViewsIn)
                    }
                    .padding(.bottom)
                    
                    // MARK: Answers
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(game.answers, id: \.self) { answer in
                            VStack {
                                if animateViewsIn {
                                    answerButton(answer,
                                                 isCorrectAnswer: game.correctAnswer == answer,
                                                 tappedWrong: tappedAnswers.contains(answer),
                                                 geometry: g)
                                    .disabled(tappedAnswers.contains(answer) || tappedCorrectAnswer)
                                }
                            }
                            .animation(.easeOut(duration: animateViewsIn ? 1 : 0).delay(animateViewsIn ? 1.5 : 0), value: animateViewsIn)
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: g.size.width, height: g.size.height)
                .foregroundStyle(.white)
                
                // MARK: Celebrations
                VStack {
                    Spacer()
                    
                    VStack {
                        if tappedCorrectAnswer {
                            Text("\(game.questionScore)")
                                .font(.largeTitle)
                                .padding(.top, 50)
                                .transition(.offset(y: -g.size.height / 4))
                                .offset(x: movePointsToScore ? g.size.width / 2.3 : 0,
                                        y: movePointsToScore ? -g.size.height / 13 : 0)
                                .opacity(movePointsToScore ? 0 : 1)
                                .onAppear() {
                                    withAnimation(.easeInOut(duration: 1).delay(3)) {
                                        movePointsToScore = true
                                    }
                                }
                        }
                    }
                    .animation(.easeInOut(duration: tappedCorrectAnswer ? 1 : 0).delay(tappedCorrectAnswer ? 2 : 0), value: tappedCorrectAnswer)
                    
                    Spacer()
                    VStack {
                        if tappedCorrectAnswer {
                            Text("Brilliant!")
                                .font(.hpFont(size: 100))
                                .transition(.scale.combined(with: .offset(y: -g.size.height / 2)))
                        }
                    }
                    .animation(.easeInOut(duration: tappedCorrectAnswer ? 1 : 0).delay(tappedCorrectAnswer ? 1 : 0), value: tappedCorrectAnswer)
                    Spacer()
                    VStack {
                        if tappedCorrectAnswer {
                            Text(game.correctAnswer)
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .padding(10)
                                .frame(width: g.size.width / 2.15, height: 80)
                                .background(.green.opacity(0.5))
                                .clipShape(.rect(cornerRadius: 25))
                                .scaleEffect(2)
                                .matchedGeometryEffect(id: "answer", in: namespace)
                        }
                    }
                    Group {
                        Spacer()
                        Spacer()
                    }
                    VStack {
                        if tappedCorrectAnswer {
                            Button {
                                animateViewsIn = false
                                tappedCorrectAnswer = false
                                revealBook = false
                                revealHint = false
                                movePointsToScore = false
                                tappedAnswers.removeAll()
                                game.newQuestion()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    animateViewsIn = true
                                }
                            } label: {
                                Text("Next Level>")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue.opacity(0.5))
                            .font(.largeTitle)
                            .transition(.offset(y: g.size.height / 3))
                            .scaleEffect(scaleNextButton ? 1.2 : 1.0)
                            .onAppear() {
                                withAnimation(.easeInOut(duration: 1.3).repeatForever()) {
                                    scaleNextButton.toggle()
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: tappedCorrectAnswer ? 2.7 : 0.5).delay(tappedCorrectAnswer ? 2.7 : 0.1), value: tappedCorrectAnswer)
                    Group {
                        Spacer()
                        Spacer()
                    }
                }
                .foregroundStyle(.white)
            }
            .frame(width: g.size.width, height: g.size.height)
            
        }
        .ignoresSafeArea()
        .onAppear() {
            animateViewsIn = true
            playMusic()
        }
    }
    
    @ViewBuilder
    private func answerButton(_ text: String,
                              isCorrectAnswer: Bool = false,
                              tappedWrong: Bool = false,
                              geometry g: GeometryProxy) -> some View {
        if isCorrectAnswer {
            if !tappedCorrectAnswer {
                Button {
                    withAnimation(.easeOut(duration: 0.5)) {
                        tappedCorrectAnswer = true
                    }
                    playCorrectSound()
                    giveCorrectAnswerFeedback()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        game.didAnswerCorrectly()
                    }
                } label: {
                    answerLabel(text, geometry: g)
                        .matchedGeometryEffect(id: "answer", in: namespace)
                }
                .transition(.asymmetric(insertion: .scale, removal: .scale(scale: 5).combined(with: .opacity.animation(.easeOut(duration: 0.5)))))
            }
        } else {
            Button {
                tappedAnswers.append(text)
                playWrongSound()
                giveWrongAnswerFeedback()
                game.didAnswerIncorrectly()
            } label: {
                answerLabel(text, tappedWrong: tappedWrong, geometry: g)
                    .scaleEffect(tappedWrong ? 0.8 : 1)
            }.transition(.scale)
                .opacity(tappedCorrectAnswer ? 0.1 : 1)
        }
    }
    
    private func answerLabel(_ text: String, tappedWrong: Bool = false, geometry g: GeometryProxy) -> some View {
        Text(text)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.center)
            .padding(20)
            .frame(width: g.size.width / 2.15, height: 80)
            .background(tappedWrong ? .red.opacity(0.5) : .green.opacity(0.5))
            .clipShape(.rect(cornerRadius: 25))
    }
    
    private func playMusic() {
        let songs = ["let-the-mystery-unfold",
                     "spellcraft",
                     "hiding-place-in-the-forest",
                     "deep-in-the-dell"]
        let r = Int.random(in: 0...3)
        let music = Bundle.main.path(forResource: songs[r], ofType: "mp3")
        
        musicPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: music!))
        musicPlayer.volume = 0.1
        musicPlayer.numberOfLoops = -1
        musicPlayer.play()
    }
    
    private func playFipSound() {
        let sound = Bundle.main.path(forResource: "page-flip", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))

        sfxPlayer.play()
    }
    
    private func playWrongSound() {
        let sound = Bundle.main.path(forResource: "negative-beeps", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))

        sfxPlayer.play()
    }
    
    private func playCorrectSound() {
        let sound = Bundle.main.path(forResource: "magic-wand", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))

        sfxPlayer.play()
    }
    
    private func giveWrongAnswerFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    private func giveCorrectAnswerFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    VStack {
        GameplayScreen()
            .environmentObject(GameViewModel())
    }
}

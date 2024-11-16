//
//  GameViewModel.swift
//  HP Quiz
//
//  Created by Fernando Draghi on 15/11/2024.
//

import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameScore = 0
    @Published private(set) var questionScore = 5
    @Published var recentScores = [0, 0, 0]
        
    private var allQuestions = [Question]()
    private var answeredQuestions = [Int]()
    private var unansweredQuestions = [Int]()
    private var savePath: URL {
        FileManager.documentsDirectory.appendingPathComponent("scores.json")
    }
    var filteredQuestions: [Question] = []
    
    var currentQuestion = Question.preview
    
    var answers = [String]()
    
    var correctAnswer: String {
        currentQuestion.answers.first { $0.value }!.key
    }
    
    init() {
        loadScores()
        decodeQuestions()
    }
    
    func startGame() {
        gameScore = 0
        questionScore = 5
        answeredQuestions.removeAll()
        newQuestion()
    }
    
    func filterQuestions(to books: [Int]) {
        filteredQuestions = allQuestions.filter { books.contains($0.book) }
        unansweredQuestions = filteredQuestions.map { $0.id }
    }
    
    func newQuestion() {
        guard !filteredQuestions.isEmpty,
              unansweredQuestions.count > 0,
              let nextQuestionID = unansweredQuestions.randomElement(),
              let nextQuestion = filteredQuestions.first (where: { $0.id == nextQuestionID })
        else { return }
        questionScore = 5
        currentQuestion = nextQuestion
        
        answers.removeAll()
        
        for answer in currentQuestion.answers.keys {
            answers.append(answer)
        }
        
        answers.shuffle()
    }
    
    func didAnswerCorrectly() {
        let id = currentQuestion.id
        answeredQuestions.append(id)
        unansweredQuestions.removeAll { $0 == id }
        withAnimation {
            gameScore += questionScore
        }
    }
    
    func didAnswerIncorrectly() {
        questionScore = max(0, questionScore - 1)
    }
    
    func didUseHint() {
        questionScore = max(0, questionScore - 1)
    }
    
    func endGame() {
        recentScores[2] = recentScores[1]
        recentScores[1] = recentScores[0]
        recentScores[0] = gameScore
        
        saveScores()
    }
    
    private func saveScores() {
        do {
            let data = try JSONEncoder().encode(recentScores)
            try data.write(to: savePath)
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    private func loadScores() {
        do {
            let data = try Data(contentsOf: savePath)
            recentScores = try JSONDecoder().decode([Int].self, from: data)
        } catch {
            print("Failed to load recent score data: \(error)")
            recentScores = [0, 0, 0]
        }
    }
    
    private func decodeQuestions() {
        if let url = Bundle.main.url(forResource: "trivia", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                allQuestions = try decoder.decode([Question].self, from: data)
                filteredQuestions = allQuestions
            } catch {
                print("Failed decoding trivia data: \(error)")
            }
        }
    }
}

//
//  ViewController.swift
//  WordScramble
//
//  Created by Shah, Shubham on 27/02/20.
//  Copyright © 2020 Shubham shah. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Change Word", style: .plain, target: self, action: #selector(startGame))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
            
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }

    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self,weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac,animated: true)
    }
    
    func submit(_ answer: String) {
        let loweranswer = answer.lowercased()
        guard let title = title else { return }
        if loweranswer != title {
            if isPossible(word: loweranswer) {
                if isOriginal(word: loweranswer) {
                    if isReal(word: loweranswer) {
                        
                        usedWords.insert(loweranswer, at: 0)
                        
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        
                        return
                    }
                    else {
                        showError(errorTitle: "Word not recognized", errorMessage: "You can't just make them up, you know!")
                    }
                }
                else {
                    showError(errorTitle: "Word already used", errorMessage: "Be more original!")
                }
            }
            else {
                showError(errorTitle: "Word not possible", errorMessage: "You can't spell that word from \(title.lowercased()).")
            }
        }
        else {
            showError(errorTitle: "Same Word, Come On", errorMessage: "The same word is not an acceptable answer")
        }
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempword = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempword.firstIndex(of: letter) {
                tempword.remove(at: position)
            }
            else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if word.count < 3 {
            return false
        }
        
        return misspelledRange.location == NSNotFound
    }
    
    
    func showError(errorTitle: String,errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac,animated: true)
    }
    
    
}


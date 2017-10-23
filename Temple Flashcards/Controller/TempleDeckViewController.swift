//
//  TempleDeckViewController.swift
//  Temple Flashcards
//
//  Created by Gavin Nitta on 10/16/17.
//  Copyright © 2017 Gavin Nitta. All rights reserved.
//

import UIKit

class TempleDeckViewController : UIViewController {
    
    // MARK: - Constants
    private struct Constants {
        static let height: CGFloat = 100
        static let width: CGFloat = 217
    }
    
    private struct Resize {
        static let larger = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        static let smaller = CGAffineTransform.init(scaleX: 0.90, y: 0.90)
    }
    
    private struct Storyboard {
        static let CardCellIdentifier = "TempleCell"
        static let TempleCellIdentifier = "TempleTableViewCell"
    }
    
    // MARK: - Properties
    var instance = TempleDeck.sharedInstance
    var selectedImage: String = ""
    var selectedName: String = ""
    var correct: Int = 0
    var incorrect: Int = 0
    var currentMode: Mode = Mode.match
    enum Mode: String {
        case match, study
    }
    
    // MARK: - Outlets
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet weak var modeButton: UIBarButtonItem!
    @IBOutlet weak var pointsCounter: UIStackView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var tableViewWidth: NSLayoutConstraint!
    @IBOutlet weak var templeCollectionView: UICollectionView!
    @IBOutlet weak var templeTableView: UITableView!
    
    // MARK: - Actions
    @IBAction func refreshTemples(_ sender: UIBarButtonItem) {
        resetAllData()
    }
    
    @IBAction func changeMode(_ sender: UIBarButtonItem) {
        if currentMode == Mode.match {
            // Go to study mode
            resetAllData(shuffle: false)
            currentMode = Mode.study
            
            instance.showLabel = true
            templeCollectionView.allowsSelection = false
            pointsCounter.isHidden = true
            refreshButton.isEnabled = false
            modeButton.title = "Match"
            tableViewWidth.constant = 0
            animateViews(.curveEaseIn)
        } else {
            // Go to match mode
            resetAllData()
            currentMode = Mode.match
            
            instance.showLabel = false
            templeCollectionView.allowsSelection = true
            pointsCounter.isHidden = false
            refreshButton.isEnabled = true
            modeButton.title = "Study"
            tableViewWidth.constant = Constants.width
            animateViews(.curveEaseOut)
        }
    }
    
    // MARK: - Private Function
    private func animateViews(_ animation: UIViewAnimationOptions) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: animation, animations: {
            self.tableView.layoutIfNeeded()
            self.templeCollectionView.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func reloadTables() {
        templeCollectionView.reloadData()
        templeTableView.reloadData()
    }
    
    private func resetAllData(shuffle: Bool = true) {
        TempleDeck.sharedInstance.generateTemples(shuffle: shuffle)
        reloadTables()
        resetScores()
        resetValues()
    }
    
    private func resetData() {
        reloadTables()
        resetValues()
    }
    
    private func resetScores() {
        correct = 0
        correctLabel.text = "Correct: \(correct)"
        incorrect = 0
        incorrectLabel.text = "Incorrect: \(incorrect)"
    }
    
    private func resetValues() {
        selectedName = ""
        selectedImage = ""
    }
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        templeCollectionView.allowsMultipleSelection = false
        templeTableView.allowsMultipleSelection = false
    }
}

// MARK: - Extensions
extension TempleDeckViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TempleCellIdentifier, for: indexPath)
        cell.textLabel?.text = instance.names[indexPath.row].capitalized
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instance.names.count
    }
}

extension TempleDeckViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let templeCell = tableView.cellForRow(at: indexPath) {
            templeCell.isHighlighted = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = instance.names[indexPath.row]
        if selectedImage != "" {
            if selectedName == selectedImage {
                correct += 1
                correctLabel.text = "Correct: \(correct)"
                instance.removeTemple(templeName: selectedName)
                self.showToast(message: "Correct!")
            } else {
                incorrect += 1
                incorrectLabel.text = "Incorrect: \(incorrect)"
                self.showToast(message: "Try Again...")
            }
            resetData()
        }
    }
}

extension TempleDeckViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return instance.temples.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Storyboard.CardCellIdentifier,
            for: indexPath)
        let temple = instance.temples[indexPath.row]
        
        if let templeCell = cell as? TempleCell {
            templeCell.templeCardView.temple = temple
            templeCell.templeCardView.transform = Resize.larger
            templeCell.templeCardView.layer.removeAllAnimations()
            templeCell.templeCardView.setNeedsDisplay()
        }
        
        return cell
    }
}


extension TempleDeckViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let templeCell = collectionView.cellForItem(at: indexPath) as? TempleCell {
            templeCell.templeCardView.transform = Resize.larger
            templeCell.templeCardView.layer.removeAllAnimations()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let templeCell = collectionView.cellForItem(at: indexPath) as? TempleCell {
            UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .autoreverse], animations: {
                templeCell.templeCardView.transform = Resize.smaller
            }, completion: { _ in
                UIView.animate(withDuration: 0.7) {
                    templeCell.templeCardView.transform = Resize.larger
                }
            })
            
            selectedImage = instance.temples[indexPath.row].name
            if selectedName != "" {
                if selectedName == selectedImage {
                    correct += 1
                    correctLabel.text = "Correct: \(correct)"
                    instance.removeTemple(templeName: selectedImage)
                    self.showToast(message: "Correct!")
                } else {
                    incorrect += 1
                    incorrectLabel.text = "Incorrect: \(incorrect)"
                    self.showToast(message: "Try Again...")
                }
                resetData()
            }
        }
    }
}

extension TempleDeckViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let image = UIImage(named: instance.temples[indexPath.row].filename)!
        let widthRatio = image.size.width / image.size.height
        var size = CGSize()
        size.height = Constants.height
        size.width = widthRatio * Constants.height
        return size
    }
}

extension UIViewController {
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

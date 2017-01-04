//
//  ViewController.swift
//  VoiceMemo
//
//  Created by Pasan Premaratne on 8/23/16.
//  Copyright © 2016 Treehouse Island, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(MemoCell.self, forCellReuseIdentifier: MemoCell.reuseIdentifier!)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Record", for: UIControlState())
        button.setTitleColor(UIColor.red, for: UIControlState())
        button.addTarget(self, action: #selector(ViewController.startRecording), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop", for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.addTarget(self, action: #selector(ViewController.stopRecording), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Hidden initially. Appears after the record button is tapped
        button.isHidden = true
        
        return button
    }()
    
    lazy var dataSource: TableViewDataSource = {
        return TableViewDataSource(tableView: self.tableView, results: [])
    }()
    
    lazy var dataProvider: DataProvider = {
        return DataProvider(delegate: self.dataSource)
    }()
    
    // MARK: - Audio Properties
    let sessionManager = MemoSessionManager.sharedInstance
    let recorder = MemoRecorder.sharedInstance
    let player = MemoPlayer.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        self.dataProvider.performQuery(type: .All)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        let headerView = UIView()
        headerView.backgroundColor = .black
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(recordButton)
        headerView.addSubview(stopButton)
        
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 120.0),
            headerView.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor),
            headerView.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor),
            headerView.centerXAnchor.constraint(equalTo: stopButton.centerXAnchor),
            headerView.centerYAnchor.constraint(equalTo: stopButton.centerYAnchor)
            ])
        
        let stackView = UIStackView(arrangedSubviews:  [headerView, tableView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            self.topLayoutGuide.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            view.rightAnchor.constraint(equalTo: stackView.rightAnchor),
            view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            // Header View
            headerView.rightAnchor.constraint(equalTo: stackView.rightAnchor),
            headerView.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            headerView.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            // Table View
            tableView.rightAnchor.constraint(equalTo: stackView.rightAnchor),
            tableView.leftAnchor.constraint(equalTo: stackView.leftAnchor)
            ])
    }
    
    @objc func startRecording() {
        toggleRecordButton(on: false)
        if (!self.sessionManager.permissionGranted) {
            self.sessionManager.requestPermission { permissonAllowed in
                if (!permissonAllowed) {
                    self.displayInsufficientPermissionsAlert()
                }
            }
        }
        self.recorder.start()
    }
    
    @objc func stopRecording() {
        toggleRecordButton(on: true)
        let outputURLString = self.recorder.stop()
        presentSaveMemoAlertController { title in
            let memo = Memo(id: nil, title: title, fileURLString: outputURLString)
            self.save(memo: memo)
        }
    }
    
    fileprivate func toggleRecordButton(on flag: Bool) {
        recordButton.isHidden = !flag
        stopButton.isHidden = flag
    }

    private func displayInsufficientPermissionsAlert() {
        let alertController = UIAlertController(title: "Insufficient permissions", message: "Can not record without permission", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentSaveMemoAlertController(completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Save memo", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = "New Memo"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { alertAction in
            guard let title = alertController.textFields?.first?.text else {
                let timestamp = NSDate().timeIntervalSince1970
                let title = "Memo_\(timestamp)"
                completion(title)
                return
            }
            completion(title)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func save(memo: Memo) {
        self.dataProvider.save(memo: memo)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memo = self.dataSource.objectAtIndexPath(indexPath: indexPath)
        guard let trackData = memo.track else {
            fatalError("Can not play file without the track")
        }
        self.player.play(track: trackData)
    }
}

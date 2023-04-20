//
//  ViewController.swift
//  AudioRecorderApp
//
//  Created by shafique dassu on 26/03/2023.
//
//set up recording session template containing:
// permission to record
// big red button to record - tap
// big square button to stop and then alert to save & end or resume - tap
// pause button to pause recording - tap
// put saved recording into list -> access recording x by tapping -> recording detail page

//DELETE: locate file, delete file

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var numberOfRecords: Int = 0
    var audioPlayer: AVAudioPlayer!
    var fileNameToDelete = ""
    var filePath: String = ""
    var filePaths: [String] = []
    var filePathInRecording: String?
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //recording session set up
        recordingSession = AVAudioSession.sharedInstance()
        
        let number: Int = UserDefaults.standard.integer(forKey: "myNumber")
            numberOfRecords = number
        
        
        recordingSession.requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("ACCEPTED")
            }
        }
    }
    
    //func that gets path to the directory
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
        
    //func to display alert
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "dismiss", style: .default))
        present(alert, animated: true)
    }
    
    //function to delete file
    func deleteFile(fileName: String) {
        let myPaths : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        if myPaths.count > 0 {
            let myPath = myPaths[0]
            filePath = myPath.appendingFormat("/" + fileNameToDelete)
            print("Local path = \(filePath)")
        } else {
            print("Could not find local directory to store file")
            return
        }
    }
    @IBAction func recordButtonTapped(_ sender: Any) {
        //check if recorder is active
        if audioRecorder == nil {
            numberOfRecords += 1
            let audioName = UUID().uuidString
            let fileName = getDirectory().appendingPathComponent("\(audioName).m4a")
            filePathInRecording = audioName
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //start audio recording
            do {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                recordButton.setTitle("Stop Recording", for: .normal)
            }
            catch {
                displayAlert(title: "Recording Failed", message: "Recording Had a Hicup")
            }
        }
        else {
            //stop audio recording
            audioRecorder.stop()
            audioRecorder = nil
            
          //  UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            if let audioName = filePathInRecording {
                filePaths.append(audioName)
            }
            myTableView.reloadData()
            
            recordButton.setTitle("Start Recording", for: .normal)
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filePaths.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        let audioName = filePaths[indexPath.row]
        cell.textLabel?.text = audioName + ".m4a"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            numberOfRecords -= 1
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            tableView.deleteRows(at: [indexPath], with: .automatic)
           // filePath.remove(at: indexPath.row)
        }
    }
    
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioName = filePaths[indexPath.row]
        let path = getDirectory().appendingPathComponent("\(audioName).m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        }
        catch {
            
        }
    }
}

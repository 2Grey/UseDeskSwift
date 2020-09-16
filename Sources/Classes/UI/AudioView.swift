//
//  AudioView.swift

import AVFoundation

protocol AudioDelegate: class {
    // -------------------------------------------------------------------------------------------------------------------------------------------------
    func didRecordAudio(_ path: String?)
}

class AudioView: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    private var isPlaying = false
    private var isRecorded = false
    private var isRecording = false
    private var timer: Timer?
    private var dateTimer: Date?
    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?

    weak var delegate: AudioDelegate?

    @IBOutlet private var labelTimer: UILabel!
    @IBOutlet private var buttonRecord: UIButton!
    @IBOutlet private var buttonStop: UIButton!
    @IBOutlet private var buttonDelete: UIButton!
    @IBOutlet private var buttonPlay: UIButton!
    @IBOutlet private var buttonSend: UIButton!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.title = "Audio"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.actionCancel))

        self.isRecording = false
        self.isRecorded = self.isRecording
        self.isPlaying = self.isRecorded

        self.updateButtonDetails()
    }

    // MARK: - Actions

    func actionStop() {
        if self.isPlaying {
            self.audioPlayerStop()
        }
        if self.isRecording {
            self.audioRecorderStop()
        }
    }

    @objc func actionCancel() {
        self.actionStop()

        self.dismiss(animated: true)
    }

    @IBAction func actionRecord(_ sender: Any) {
        self.audioRecorderStart()
    }

    @IBAction func actionStop(_ sender: Any) {
        self.actionStop()
    }

    @IBAction func actionDelete(_ sender: Any) {
        self.isRecorded = false
        self.updateButtonDetails()

        self.timerReset()
    }

    @IBAction func actionPlay(_ sender: Any) {
        self.audioPlayerStart()
    }

    @IBAction func actionSend(_ sender: Any) {
        self.dismiss(animated: true)

        self.delegate?.didRecordAudio(audioRecorder?.url.path)
    }

    // MARK: - Audio recorder methods

    func audioRecorderStart() {
        self.isRecording = true
        self.updateButtonDetails()
        self.timerStart()

        do {
            let audioSession = AVAudioSession.sharedInstance()
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSession.Category.playback)
            } else {
                AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSession.Category.playback)
            }
        } catch {}

        self.audioRecorder?.prepareToRecord()
        self.audioRecorder?.record()
    }

    func audioRecorderStop() {
        self.isRecording = false
        self.isRecorded = true
        self.updateButtonDetails()

        self.timerStop()

        self.audioRecorder?.stop()
    }

    // MARK: - Audio player methods

    func audioPlayerStart() {
        self.isPlaying = true
        self.updateButtonDetails()

        self.timerStart()

        AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSession.Category.playback)
        guard let url = self.audioRecorder?.url else { return }

        self.audioPlayer = try? AVAudioPlayer(contentsOf: url)
        self.audioPlayer?.delegate = self
        self.audioPlayer?.prepareToPlay()
        self.audioPlayer?.play()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isPlaying = false
        self.updateButtonDetails()

        self.timerStop()
    }

    func audioPlayerStop() {
        self.isPlaying = false
        self.updateButtonDetails()
        self.timerStop()
        self.audioPlayer?.stop()
    }

    // MARK: - Timer methods

    func timerStart() {
        self.dateTimer = Date()
        self.timer = Timer.scheduledTimer(timeInterval: 0.07, target: self, selector: #selector(self.timerUpdate), userInfo: nil, repeats: true)
    }

    @objc func timerUpdate() {
        guard let dateTimer = self.dateTimer else {
            self.timerReset()
            return
        }

        let interval: TimeInterval = Date().timeIntervalSince(dateTimer)
        let millisec = Int(interval * 100) % 100
        let seconds = Int(interval) % 60
        let minutes = Int(interval) / 60

        self.labelTimer.text = String(format: "%02d:%02d:%02d", minutes, seconds, millisec)
    }

    func timerStop() {
        self.timer?.invalidate()
        self.timer = nil
        self.dateTimer = nil
    }

    func timerReset() {
        self.labelTimer.text = "00:00:00"
    }

    // MARK: - Helper methods

    func updateButtonDetails() {
        self.buttonRecord.isHidden = self.isRecorded
        self.buttonStop.isHidden = (self.isPlaying == false) && (self.isRecording == false)
        self.buttonDelete.isHidden = (self.isPlaying == true) || (self.isRecorded == false)
        self.buttonPlay.isHidden = (self.isPlaying == true) || (self.isRecorded == false)
        self.buttonSend.isHidden = (self.isPlaying == true) || (self.isRecorded == false)
    }
}

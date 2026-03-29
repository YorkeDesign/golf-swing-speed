import AVFoundation
import UIKit

@Observable
final class AudioFeedbackManager {
    var mode: AudioFeedbackMode = .beep

    private let synthesizer = AVSpeechSynthesizer()
    private let hapticNotification = UINotificationFeedbackGenerator()
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)

    init() {
        configureAudioSession()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(
            .playback,
            mode: .voicePrompt,
            options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers, .allowBluetooth]
        )
        try? session.setActive(true)
    }

    // MARK: - Feedback Events

    func playerDetected() {
        switch mode {
        case .beep:
            playTone(frequency: 200, duration: 0.1)
            hapticImpact.impactOccurred()
        case .voice:
            speak("Player detected")
        case .off:
            break
        }
    }

    func ready() {
        switch mode {
        case .beep:
            playTone(frequency: 400, duration: 0.08)
            Task {
                try? await Task.sleep(for: .milliseconds(120))
                playTone(frequency: 600, duration: 0.08)
            }
            hapticNotification.notificationOccurred(.success)
        case .voice:
            speak("Ready")
        case .off:
            break
        }
    }

    func swingCaptured() {
        switch mode {
        case .beep:
            playTone(frequency: 800, duration: 0.15)
            hapticNotification.notificationOccurred(.success)
        case .voice:
            speak("Swing captured")
        case .off:
            break
        }
    }

    func speedResult(mph: Double, unit: SpeedUnit = .mph) {
        let converted = unit.convert(fromMph: mph)
        let formatted = String(format: "%.0f", converted)

        switch mode {
        case .beep:
            // Triple ascending beep then speak the number
            playTone(frequency: 500, duration: 0.06)
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                playTone(frequency: 700, duration: 0.06)
                try? await Task.sleep(for: .milliseconds(100))
                playTone(frequency: 900, duration: 0.06)
                try? await Task.sleep(for: .milliseconds(200))
                speak("\(formatted) \(unit.displayName)")
            }
            hapticNotification.notificationOccurred(.success)
        case .voice:
            speak("\(formatted) \(unit.displayName)")
        case .off:
            break
        }
    }

    func errorSwingNotDetected() {
        switch mode {
        case .beep:
            playTone(frequency: 600, duration: 0.1)
            Task {
                try? await Task.sleep(for: .milliseconds(150))
                playTone(frequency: 300, duration: 0.15)
            }
            hapticNotification.notificationOccurred(.error)
        case .voice:
            speak("Swing not detected, try again")
        case .off:
            break
        }
    }

    func errorTrackingLost() {
        switch mode {
        case .beep:
            for i in 0..<3 {
                Task {
                    try? await Task.sleep(for: .milliseconds(i * 100))
                    playTone(frequency: 500, duration: 0.05)
                }
            }
            hapticNotification.notificationOccurred(.warning)
        case .voice:
            speak("Tracking lost, please retry")
        case .off:
            break
        }
    }

    func adjustPosition() {
        switch mode {
        case .beep:
            playTone(frequency: 400, duration: 0.2)
            hapticNotification.notificationOccurred(.warning)
        case .voice:
            speak("Adjust position, stand in frame")
        case .off:
            break
        }
    }

    func calibrationComplete() {
        switch mode {
        case .beep:
            // Rising C-E-G chime
            playTone(frequency: 523, duration: 0.12)
            Task {
                try? await Task.sleep(for: .milliseconds(140))
                playTone(frequency: 659, duration: 0.12)
                try? await Task.sleep(for: .milliseconds(140))
                playTone(frequency: 784, duration: 0.2)
            }
            hapticNotification.notificationOccurred(.success)
        case .voice:
            speak("Calibration complete")
        case .off:
            break
        }
    }

    // MARK: - Core Audio

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }

    private func playTone(frequency: Double, duration: Double) {
        // Phase 1: Use system sound as placeholder
        // Phase 2: Replace with generated tones or bundled .wav files
        AudioServicesPlaySystemSound(SystemSoundID(1057))
    }
}

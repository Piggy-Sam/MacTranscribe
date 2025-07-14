import Foundation

class TranscriptionViewModel: ObservableObject {
    @Published var transcript: String = ""
    @Published var isTranscribing: Bool = false
    @Published var errorMessage: String? = nil

    private let transcriptionService: TranscriptionServiceProtocol

    init(transcriptionService: TranscriptionServiceProtocol = TranscriptionService()) {
        self.transcriptionService = transcriptionService
    }

    func transcribe(fileURL: URL, modelPath: String) async {
        isTranscribing = true
        errorMessage = nil
        do {
            let transcribedText = try await transcriptionService.transcribeAudioFile(fileURL: fileURL, modelPath: modelPath)
            await MainActor.run { // Ensure UI updates on MainActor
                self.isTranscribing = false
                self.transcript = transcribedText
            }
        } catch {
            await MainActor.run { // Ensure UI updates on MainActor
                self.isTranscribing = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

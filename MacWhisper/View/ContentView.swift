import SwiftUI

struct ContentView: View {
    @StateObject private var modelManager = ModelManagerViewModel()
    @StateObject private var transcriptionViewModel = TranscriptionViewModel()

    var body: some View {
        VStack {
            ModelSelectionView(modelManager: modelManager)
            TranscriptionView(viewModel: transcriptionViewModel)
        }
        .onAppear {
            modelManager.fetchModels()
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            guard let itemProvider = providers.first else { return false }
            itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                // This completion handler MUST be synchronous
                if let urlData = urlData as? Data, let fileURL = URL(dataRepresentation: urlData, relativeTo: nil) {
                    Task { @MainActor in // Launch a Task here for async operations
                        guard let modelPath = modelManager.selectedModelPath else {
                            transcriptionViewModel.errorMessage = "Please download and select a Whisper model first."
                            return
                        }
                        await transcriptionViewModel.transcribe(fileURL: fileURL, modelPath: modelPath)
                    }
                }
            }
            return true
        }
    }
}



import Foundation

class ModelManagerViewModel: ObservableObject {
    @Published var models: [WhisperModel] = []
    @Published var selectedModel: WhisperModel? {
        didSet {
            if let model = selectedModel, model.isDownloaded {
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                selectedModelPath = documentsUrl.appendingPathComponent(model.name).path
            } else {
                selectedModelPath = nil
            }
        }
    }
    @Published var selectedModelPath: String? = nil

    private let modelDownloader = ModelDownloaderService()

    func fetchModels() {
        // In a real app, you would fetch this from a remote JSON file.
        self.models = [
            WhisperModel(name: "ggml-base.bin", url: URL(string: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin")!),
            WhisperModel(name: "ggml-small.bin", url: URL(string: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin")!),
            WhisperModel(name: "ggml-medium.bin", url: URL(string: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin")!),
            WhisperModel(name: "ggml-large.bin", url: URL(string: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large.bin")!)
        ]
    }

    func downloadModel(_ model: WhisperModel) {
        modelDownloader.downloadModel(model: model) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    if let index = self?.models.firstIndex(where: { $0.id == model.id }) {
                        self?.models[index].isDownloaded = true
                        // Automatically select the downloaded model
                        self?.selectedModel = self?.models[index]
                    }
                    print("Model downloaded to: \(url)")
                case .failure(let error):
                    print("Error downloading model: \(error)")
                }
            }
        }
    }
}

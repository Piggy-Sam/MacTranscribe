import SwiftUI

struct ModelSelectionView: View {
    @ObservedObject var modelManager: ModelManagerViewModel

    var body: some View {
        List(modelManager.models) { model in
            HStack {
                Text(model.name)
                Spacer()
                if model.isDownloaded {
                    Button(action: {
                        modelManager.selectedModel = model
                    }) {
                        Text(modelManager.selectedModel?.id == model.id ? "Selected" : "Select")
                    }
                    .disabled(modelManager.selectedModel?.id == model.id)
                } else {
                    Button("Download") {
                        modelManager.downloadModel(model)
                    }
                }
            }
        }
    }
}

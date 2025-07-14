import SwiftUI

struct TranscriptionView: View {
    @ObservedObject var viewModel: TranscriptionViewModel

    var body: some View {
        VStack {
            TextEditor(text: $viewModel.transcript)
                .padding()
            if viewModel.isTranscribing {
                ProgressView()
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
    }
}

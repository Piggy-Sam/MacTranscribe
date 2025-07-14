import Foundation
import AVFoundation
import CoreMedia

protocol TranscriptionServiceProtocol {
    func transcribeAudioFile(fileURL: URL, modelPath: String) async throws -> String
}

enum TranscriptionError: Error, LocalizedError {
    case modelLoadFailed(String)
    case transcriptionFailed(String)
    case audioProcessingFailed(String)

    var errorDescription: String? {
        switch self {
        case .modelLoadFailed(let message):
            return "Failed to load Whisper model: \(message)"
        case .transcriptionFailed(let message):
            return "Transcription failed: \(message)"
        case .audioProcessingFailed(let message):
            return "Audio processing failed: \(message)"
        }
    }
}

class TranscriptionService: TranscriptionServiceProtocol {
    func transcribeAudioFile(fileURL: URL, modelPath: String) async throws -> String {
        guard let context = my_whisper_init_from_file_with_params(modelPath, my_whisper_context_default_params()) else {
            throw TranscriptionError.modelLoadFailed("Could not load model from path: \(modelPath)")
        }

        defer { my_whisper_free(context) }

        let asset = AVAsset(url: fileURL)
        guard let audioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
            throw TranscriptionError.audioProcessingFailed("No audio track found in file.")
        }

        let audioReaderSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMBitDepthKey: 32,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 16000
        ]

        do {
            let assetReader = try AVAssetReader(asset: asset)
            let assetReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioReaderSettings)
            assetReader.add(assetReaderOutput)

            assetReader.startReading()

            var audioSamples: [Float] = []

            while assetReader.status == .reading {
                if let sampleBuffer = assetReaderOutput.copyNextSampleBuffer() {
                    var audioBufferList = AudioBufferList()
                    var blockBuffer: CMBlockBuffer?
                    let status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
                        sampleBuffer,
                        bufferListSizeNeededOut: nil,
                        bufferListOut: &audioBufferList,
                        bufferListSize: MemoryLayout<AudioBufferList>.size,
                        blockBufferAllocator: nil,
                        blockBufferMemoryAllocator: nil,
                        flags: 0,
                        blockBufferOut: &blockBuffer
                    )

                    guard status == noErr else {
                        throw TranscriptionError.audioProcessingFailed("Failed to get audio buffer list: \(status)")
                    }

                    let abl = UnsafeMutableAudioBufferListPointer(&audioBufferList)
                    for audioBuffer in abl {
                        let frameCount = Int(audioBuffer.mDataByteSize) / MemoryLayout<Float>.size
                        let ptr = audioBuffer.mData?.assumingMemoryBound(to: Float.self)
                        if let ptr = ptr {
                            audioSamples.append(contentsOf: UnsafeBufferPointer(start: ptr, count: frameCount))
                        }
                    }
                }
            }

            if assetReader.status == .completed {
                var params = my_whisper_full_default_params(whisper_sampling_strategy(0))
                params.print_realtime = false
                params.print_progress = false
                params.print_timestamps = false
                params.print_special = false
                params.translate = false
                params.language = ("en" as NSString).utf8String

                let ret = my_whisper_full(context, params, audioSamples, Int32(audioSamples.count))

                if ret != 0 {
                    throw TranscriptionError.transcriptionFailed("whisper_full returned non-zero: \(ret)")
                }

                var fullText = ""
                let n_segments = my_whisper_full_n_segments(context)
                for i in 0..<n_segments {
                    if let text = my_whisper_full_get_segment_text(context, i) {
                        fullText += String(cString: text)
                    }
                }
                return fullText
            } else if let error = assetReader.error {
                throw TranscriptionError.audioProcessingFailed("Asset reader error: \(error.localizedDescription)")
            } else {
                throw TranscriptionError.audioProcessingFailed("Unknown asset reader status: \(assetReader.status.rawValue)")
            }

        } catch {
            throw TranscriptionError.audioProcessingFailed("Error creating asset reader: \(error.localizedDescription)")
        }
    }
}

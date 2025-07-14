import Foundation

struct WhisperModel: Identifiable, Codable {
    var id = UUID()
    let name: String
    let url: URL
    var isDownloaded: Bool = false
}

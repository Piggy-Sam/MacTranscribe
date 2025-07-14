import Foundation

class ModelDownloaderService {
    func downloadModel(model: WhisperModel, completion: @escaping (Result<URL, Error>) -> Void) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent(model.name)

        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(.success(destinationUrl))
            return
        }

        let downloadTask = URLSession.shared.downloadTask(with: model.url) { url, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let url = url else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                return
            }

            do {
                try FileManager.default.moveItem(at: url, to: destinationUrl)
                completion(.success(destinationUrl))
            } catch {
                completion(.failure(error))
            }
        }

        downloadTask.resume()
    }
}

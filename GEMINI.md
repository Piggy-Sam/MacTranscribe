# MacWhisper Clone Development Plan

This document outlines the architecture and development plan for a native macOS application that provides live and file-based audio transcription using `whisper.cpp`.

## 1. Core Technologies

*   **UI Framework:** SwiftUI
*   **App Lifecycle:** SwiftUI App
*   **Core Transcription Engine:** `whisper.cpp`
*   **Audio Handling:** `AVFoundation`
*   **System Audio Capture:** `ScreenCaptureKit`

## 2. Simplified Architecture (MVVM)

We will use a refined MVVM (Model-View-ViewModel) architecture.

*   **Model:**
    *   `TranscriptionSegment`: Represents a piece of transcribed text with timestamps.
    *   `WhisperModel`: Represents a downloadable Whisper model (name, URL, local path, status).

*   **View:**
    *   `ContentView`: The main application view.
    *   `TranscriptionView`: Displays the live transcript and handles user interaction.
    *   `ModelSelectionView`: Lists, downloads, and manages Whisper models.
    *   `SettingsView`: For app settings like audio input source.

*   **ViewModel:**
    *   `TranscriptionViewModel`: Manages the transcription state, interacts with the `TranscriptionService`, and updates the `TranscriptionView`.
    *   `ModelManagerViewModel`: Manages the list of available models, their download state, and selection.

*   **Services:**
    *   `TranscriptionService`: A protocol-based service responsible for all aspects of transcription. This will encapsulate the `whisper.cpp` interaction, audio capture (mic/file/system), and processing. This allows for easier testing and future expansion (e.g., adding a different transcription engine).
    *   `ModelDownloaderService`: Handles the downloading and storage of Whisper models.

## 3. Development Plan

### Phase 1: Project Setup & Core Transcription

1.  **Project Initialization:**
    *   Create a new SwiftUI project in Xcode.
    *   Establish the folder structure: `Model`, `View`, `ViewModel`, `Service`, `Whisper`.

2.  **`whisper.cpp` Integration:**
    *   Add `whisper.cpp` as a Git submodule.
    *   Create a `CMakeLists.txt` to build `whisper.cpp` as a static library.
    *   Develop a C++ wrapper to expose a simplified C API for `whisper.cpp`.
    *   Create an Objective-C++ bridging header to make the wrapper available to Swift.

3.  **Model Management:**
    *   Implement `ModelDownloaderService` to download models from a remote JSON file.
    *   Implement `ModelManagerViewModel` to manage the model list and selection.
    *   Create the `ModelSelectionView` to display and download models.

### Phase 2: Audio & UI

4.  **File-Based Transcription:**
    *   Implement the initial version of `TranscriptionService` to handle audio file transcription.
    *   Implement drag-and-drop functionality in `ContentView`.

5.  **Live Microphone Transcription:**
    *   Extend `TranscriptionService` to capture audio from the microphone using `AVFoundation`.
    *   Implement the UI controls (Start/Stop button) in `TranscriptionView`.

6.  **UI Implementation:**
    *   Build the main `ContentView` and `TranscriptionView` with an editable text area.
    *   Integrate the `ModelSelectionView`.

### Phase 3: Advanced Features & Refinements

7.  **System Audio Capture:**
    *   Integrate `ScreenCaptureKit` to capture system audio.
    *   Add the necessary UI elements in `SettingsView` to select the audio source.

8.  **UI/UX Refinement:**
    *   Ensure the application adheres to modern macOS design standards.
    *   Add progress indicators, error handling, and user feedback.
    *   Optimize for Apple Silicon.

9.  **Future Expansions:**
    *   Implement transcript export (TXT, VTT, SRT).
    *   Explore adding support for other transcription services.

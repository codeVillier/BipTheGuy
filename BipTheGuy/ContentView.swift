//
//  ContentView.swift
//  BipTheGuy
//
//  Created by Oscar De Villiers on 2026/01/23.
//

import SwiftUI
import AVFAudio
import PhotosUI

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer!
    @State private var isFullSize = true
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var bipImage = Image("clown")
    @AppStorage("savedImageData") private var savedImageData: Data?
    
    var body: some View {
        VStack {
            Spacer()
            
            bipImage
                .resizable()
                .scaledToFit()
                .scaleEffect(isFullSize ? 1.0 : 0.9)
                .onTapGesture {
                    playSound(soundName: "punchSound")
                    isFullSize = false // will immediately shrink using .scaleEffect to 90% of the size
                    withAnimation (.spring(response: 0.3, dampingFraction: 0.3)) {
                        isFullSize = true // will go from 90% to 100% size but using .spring animation
                    }
                }
                
            
            Spacer()
            
            PhotosPicker(selection: $selectedPhoto) {
                Label("Photo Library", systemImage: "photo.fill.on.rectangle.fill")
                    .font(.title2)
            }
            .buttonStyle(.glassProminent)
            .tint(.green.opacity(0.7))
            .onChange(of: selectedPhoto) {
                Task {
                    guard let selectedImage = try? await selectedPhoto?.loadTransferable(type: Image.self) else {
                        print("😡ERROR: Could not get Image from laodTransferable")
                        return
                    }
                    bipImage = selectedImage
                    
                    // Save the image data
                    if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                        savedImageData = data
                    }
                }
            }
        }
        .padding()
        .onAppear {
            loadSavedImage()
        }
    }
    
    func loadSavedImage() {
        guard let imageData = savedImageData else {
            return
        }
        
        #if os(iOS)
        if let uiImage = UIImage(data: imageData) {
            bipImage = Image(uiImage: uiImage)
        }
        #elseif os(macOS)
        if let nsImage = NSImage(data: imageData) {
            bipImage = Image(nsImage: nsImage)
        }
        #endif
    }
    
    func playSound(soundName: String) {
        
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 Could not read file named \(soundName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("😡 Error: \(error.localizedDescription) creating audioPlayer")
        }
    }
}

#Preview {
    ContentView()
}

//
//  RecordingsList.swift
//  VoiceRecorder
//
//  Created by Riaz Alim on 17/03/2023.
//


import SwiftUI
import CoreData
import AVFoundation

struct RecordingsList: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var audioPlayer: AudioPlayer
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recording.createdAt, ascending: true)],
        animation: .default)
    private var recordings: FetchedResults<Recording>
    
    var body: some View {
        List {
            ForEach(recordings, id: \.id) { recording in
                RecordingRow(audioPlayer: audioPlayer, recording: recording)
            }
                .onDelete(perform: delete)
        }
    }
    
    func delete(at offsets: IndexSet) {
        withAnimation {
            offsets.map { recordings[$0] }.forEach(moc.delete)

            do {
                try moc.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct RecordingRow: View {
    @ObservedObject var audioPlayer: AudioPlayer
    var recording: Recording
    
    var isPlayingThisRecording: Bool {
        audioPlayer.currentlyPlaying?.id == recording.id
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recording.name ?? "Recording")
                    .fontWeight(isPlayingThisRecording ? .bold : .regular)
                Group {
                    if let recordingData = recording.recordingData, let duration = getDuration(of: recordingData) {
                        Text(DateComponentsFormatter.positional.string(from: duration) ?? "0:00")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
            Spacer()
            Button {
                audioPlayer.startPlayback(recording: recording)
            } label: {
                Image(systemName: "play.circle.fill")
                    .imageScale(.large)
                    .symbolRenderingMode(.palette)
                   .foregroundStyle(.primary, .black)
            }
        }
        .tint(isPlayingThisRecording ? .green : .white)
    }
    
    func getDuration(of recordingData: Data) -> TimeInterval? {
        do {
            return try AVAudioPlayer(data: recordingData).duration
        } catch {
            print("Failed to get the duration for recording on the list: Recording Name - \(recording.name ?? "")")
            return nil
        }
    }
}

struct RecordingsList_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsList(audioPlayer: AudioPlayer())
    }
}

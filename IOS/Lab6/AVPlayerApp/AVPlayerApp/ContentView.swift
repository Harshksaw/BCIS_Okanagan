import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: VideoPlayerView()) {
                    Text("Play Video")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("AVPlayer Demo")
        }
    }
}

struct VideoPlayerView: View {
    var player: AVPlayer

    init() {
        // OPTION 1: Play Video from URL
        /*
        if let url = URL(string: "https://www.ebookfrenzy.com/ios_book/movie/movie.mov") {
            player = AVPlayer(url: url)
        } else {
            player = AVPlayer()
        }
        */
//        if let url = URL(string: "https://www.ebookfrenzy.com/ios_book/movie/movie.mov") {
//            player = AVPlayer(url: url)
//        } else {
//            player = AVPlayer()
//        }

//         OPTION 2: Play Local Video File
        if let path = Bundle.main.path(forResource: "mov_bbb", ofType: "mp4") {
            player = AVPlayer(url: URL(fileURLWithPath: path))
        } else {
            print("mov_bbb.mp4 not found")
            player = AVPlayer()
        }
    }

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.play()
            }
            .edgesIgnoringSafeArea(.all)
    }
}

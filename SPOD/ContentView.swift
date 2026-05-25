//
//  ContentView.swift
//  SPOD
//
//  Created by dylan on 5/24/26.
//

import SwiftUI
import AVKit
import UIKit

struct ContentView: View {
    @StateObject private var service = APODService()
    @State private var showShareSheet = false
    @State private var useHDImage = true

    var formattedDate: String {
        guard let apod = service.apod else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let date = formatter.date(from: apod.date) {
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }

        return apod.date
    }

    var imageURL: String {
        guard let apod = service.apod else { return "" }

        if useHDImage, let hd = apod.hdurl {
            return hd
        }

        return apod.url
    }

    var body: some View {
        NavigationView {

            ScrollView {
                VStack(spacing: 20) {

                    Text("Today's Space Picture")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top)

                    Toggle("Use HD Images", isOn: $useHDImage)
                        .padding(.horizontal)

                    if service.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(.top, 50)

                    } else if let apod = service.apod {

                        Group {
                            if apod.media_type == "image" {

                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()

                                } placeholder: {
                                    ProgressView()
                                        .frame(height: 250)
                                }

                            } else if apod.media_type == "video" {

                                if let videoURL = URL(string: apod.url) {
                                    VideoPlayer(player: AVPlayer(url: videoURL))
                                        .frame(height: 250)
                                        .cornerRadius(20)
                                }

                            } else {
                                VStack {
                                    Image(systemName: "questionmark.circle")
                                        .font(.largeTitle)

                                    Text("Unsupported media type")
                                }
                                .frame(height: 250)
                            }
                        }
                        .padding(.horizontal)

                        VStack(spacing: 8) {
                            Text(apod.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)

                            Text(formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        Text(apod.explanation)
                            .font(.body)
                            .padding(.horizontal)

                        HStack(spacing: 12) {

                            Button(action: {
                                service.fetchRandom()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "shuffle")
                                        .font(.headline)

                                    Text("Random")
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                            }

                            Button(action: {
                                saveImage()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.headline)

                                    Text("Save")
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                            }

                            Button(action: {
                                showShareSheet = true
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.headline)

                                    Text("Share")
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemBackground))
                                .foregroundColor(.blue)
                                .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal)

                    } else if let error = service.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding(.bottom, 30)
            }

            Text("Click \"Back\" to start!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

        }
        .onAppear {
            service.fetchToday()
        }
        .sheet(isPresented: $showShareSheet) {
            if let apod = service.apod {
                ShareSheet(activityItems: [apod.url])
            }
        }
    }

    func saveImage() {
        guard
            let url = URL(string: imageURL),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else {
            return
        }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

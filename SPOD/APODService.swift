//
//  APODService.swift
//  SPOD
//
//  Created by dylan on 5/24/26.
//

import Foundation

class APODService: ObservableObject {
    @Published var apod: APODResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiKey = "qlPRWuQNU1MEfx1obFHciSG5FvCJ4AanA2AdJ3he"

    func fetchToday() {
        fetchAPOD(from: buildURL())
    }

    func fetchRandom() {
        let currentYear = Calendar.current.component(.year, from: Date())

        let randomYear = Int.random(in: 1995...currentYear)
        let randomMonth = Int.random(in: 1...12)
        let randomDay = Int.random(in: 1...28)

        let dateString = String(
            format: "%04d-%02d-%02d",
            randomYear,
            randomMonth,
            randomDay
        )

        fetchAPOD(from: buildURL(date: dateString))
    }

    private func buildURL(date: String? = nil) -> URL {
        var urlString = "https://api.nasa.gov/planetary/apod?api_key=\(apiKey)"

        if let date = date {
            urlString += "&date=\(date)"
        }

        return URL(string: urlString)!
    }

    private func fetchAPOD(from url: URL) {
        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received."
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(APODResponse.self, from: data)

                DispatchQueue.main.async {
                    self.apod = decoded
                }

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode NASA response."
                }
            }
        }.resume()
    }
}

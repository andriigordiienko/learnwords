//
//  ContentView.swift
//  LearnWorlds
//
//  Created by red on 24.09.2024.
//

import SwiftUI
import AVFoundation

struct Item: Codable, Identifiable {
    let id = UUID()
    var original: String
    var translation: String
    var isOriginalDisplayed: Bool

    enum CodingKeys: String, CodingKey {
        case original
        case translation
    }

    init(original: String, translation: String) {
        self.original = original
        self.translation = translation
        self.isOriginalDisplayed = true
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        original = try container.decode(String.self, forKey: .original)
        translation = try container.decode(String.self, forKey: .translation)
        isOriginalDisplayed = true
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            TabOneView()
                .tabItem {
                    Label("Words", systemImage: "list.bullet")
                }
            TabTwoView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct TabOneView: View {
    @State private var items: [Item] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var searchText: String = "" // Текст поиска
    let speechSynthesizer = AVSpeechSynthesizer()

    // Получаем URL из UserDefaults (если сохранен) или берем дефолтный
    var dataURL: String {
        UserDefaults.standard.string(forKey: "dataURL") ?? "https://raw.githubusercontent.com/andriigordiienko/learnwords/refs/heads/main/learnwords.json"
    }

    var body: some View {
        VStack {
            // Строка поиска
            TextField("Search words...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if isLoading {
                Text("Loading data...")
                    .font(.title)
                    .padding()
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(filteredItems.indices, id: \.self) { index in
                    HStack {
                        Button(action: {
                            toggleText(for: filteredItems[index].id)
                        }) {
                            Text(displayText(for: filteredItems[index].id))
                                .font(.title2)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            playSound(for: filteredItems[index].id)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .padding()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            fetchData(from: dataURL)
        }
    }

    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.original.localizedCaseInsensitiveContains(searchText) || $0.translation.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func indexOfItem(withId id: UUID) -> Int? {
        return items.firstIndex { $0.id == id }
    }

    func displayText(for id: UUID) -> String {
        if let index = indexOfItem(withId: id) {
            return items[index].isOriginalDisplayed ? items[index].original : items[index].translation
        }
        return ""
    }

    func toggleText(for id: UUID) {
        if let index = indexOfItem(withId: id) {
            items[index].isOriginalDisplayed.toggle()
        }
    }

    func playSound(for id: UUID) {
        if let index = indexOfItem(withId: id), items[index].isOriginalDisplayed {
            let utterance = AVSpeechUtterance(string: items[index].original)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            speechSynthesizer.speak(utterance)
        }
    }

    func fetchData(from urlString: String) {
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL format"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data returned"
                    self.isLoading = false
                }
                return
            }

            do {
                let decodedItems = try JSONDecoder().decode([Item].self, from: data)
                DispatchQueue.main.async {
                    self.items = decodedItems
                    self.isLoading = false
                    self.errorMessage = nil // Clear error message on successful fetch
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Parsing error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

struct TabTwoView: View {
    @State private var url: String = UserDefaults.standard.string(forKey: "dataURL") ?? "https://raw.githubusercontent.com/andriigordiienko/learnwords/refs/heads/main/learnwords.json"

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Text("Enter URL for word data:")
                .font(.headline)
                .padding(.top)
            
            TextField("Enter URL", text: $url, onCommit: {
                saveURL() // Сохраняем URL при нажатии на return
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            Button("Save URL") {
                saveURL() // Сохраняем URL при нажатии на кнопку
            }
            .padding()
            
            
            Text("The expected JSON format is:")
                .font(.headline)
                .padding()
            
            Text("""
            [
             {"original": "obviously", "translation": "очевидно"}
            ]
            """)
            
            Spacer() // Добавляет отступ
            Text("For more information:")
                .font(.headline)
                .padding(.top)
            
            
            Link("View on GitHub", destination: URL(string: "https://github.com/andriigordiienko/learnwords")!)
                .font(.body)
                .foregroundColor(.blue)
                .padding(.top)
            Spacer()

            // Copyright text at the bottom
            Text("© 2024 AndriiGordiienko. All rights reserved.")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .padding()
    }

    // Функция для сохранения URL в UserDefaults
    func saveURL() {
        UserDefaults.standard.set(url, forKey: "dataURL")
        print("Saved URL: \(url)")
    }
}

#Preview {
    ContentView()
}

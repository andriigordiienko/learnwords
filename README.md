
# Learn Words App
![Uploading image.png…]()

This app allows users to search and display word translations between English and another language. Users can also set their own URL for the word data source and toggle between the original word and its translation with a simple click.

## Features

- **Search Functionality**: You can search for a specific word from the list, either by its original or translated value.
- **Dynamic URL Setting**: In the settings tab, you can provide a custom URL to load word data from, and the app will reload the list automatically after saving the URL.
- **Text-to-Speech**: Click on the speaker icon to hear the original word pronounced in English.
- **Persistent Settings**: The app saves your custom URL even after closing, using `UserDefaults`.
- **Two Tabs**: The app has two tabs: one for displaying and searching words, and one for configuring settings.

## How to Use

1. **Search for Words**:
   - On the main screen (Words tab), there is a search bar at the top.
   - Type the word or translation you want to search for, and the list will automatically filter to match the search query.

2. **Toggle Between Original and Translation**:
   - The list displays words in their original form.
   - Click on a word, and it will toggle between the original word and its translation.

3. **Play Sound**:
   - Next to each word, there is a speaker icon. When clicked, it will pronounce the original word using text-to-speech functionality.

4. **Change Data Source URL**:
   - Go to the **Settings** tab.
   - Enter a new URL for the JSON data source.
   - Press the 'Save URL' button or hit 'Enter' to save the URL.
   - The app will automatically reload the word list from the new URL.

## Data Source Format

The app expects the JSON data source to provide an array of objects, where each object has the following format:

```json
[
    {
        "original": "word in English",
        "translation": "translated word"
    },
    ...
]
```

## Error Handling

- If there is an error in the URL (e.g., it is invalid or the server is unreachable), the app will display an error message but will continue to function with the previous dataset.

## Settings Persistence

- The app uses `UserDefaults` to save the provided URL. Once the URL is saved, it will be loaded the next time the app launches.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Credits

This app was built using SwiftUI and AVFoundation for text-to-speech functionality.

---

© 2024 AndriiGordiienko. All rights reserved.

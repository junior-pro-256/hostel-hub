# Hostel Hub

## Maps

The Google Maps screen is enabled by default. The project does not contain a Google Maps API key yet, so Google map tiles will appear after a key is configured.

- Android: add `GOOGLE_MAPS_API_KEY=your-key` to your user Gradle properties (`~/.gradle/gradle.properties`).
- iOS: set the `GOOGLE_MAPS_API_KEY` build setting in the Runner Xcode project.
- To use the built-in campus map instead, run with `--dart-define=USE_GOOGLE_MAPS=false`.

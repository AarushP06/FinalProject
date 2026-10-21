# Final Project: Sky Tracker (working title)

**420-N52-LA Mobile Application Development 2: iOS**
Champlain College Saint-Lambert · Instructor: Morteza Khanjanzadeh

## Team members

- Aarush Patel (2330241)

## Project purpose

Space events like eclipses and meteor showers are easy to miss, and most people can't picture how the planets compare to Earth. This app gathers upcoming sky events and space news in one place, lets you explore the solar system in 3D, and keeps a personal log of the events you plan to watch and what you actually saw.

## Main features

1. **Sky Events:** upcoming eclipses and meteor showers with a countdown, where they're visible, and what happens. Filter by type and save events to My Sky.
2. **Space News:** the latest spaceflight articles from the Spaceflight News API, with pull to refresh.
3. **Solar System:** the eight planets, with a toggle to include Pluto. Each planet opens a 3D model you can rotate and zoom, plus insight cards (gravity, temperature, moons, day and year length).
4. **My Sky:** saved events with notes and reminders, and an observation log (create, edit, delete) linked to planets and events.

## Technologies used

- SwiftUI, MVVM, `@Observable` view models
- SwiftData with three related `@Model` types: `CelestialBody`, `SavedEvent`, `SkyObservation`
- `NavigationStack`, sheets, `TabView`
- SceneKit for the 3D planets
- URLSession, async/await, Codable (Spaceflight News API)
- Bundled JSON data for planets and sky events
- Planned: Swift Charts, Local Notifications, EventKit, Core Location, PhotosPicker

## Project structure

```
FinalProject/
├── App/            App entry point and the tab view
├── Models/         SwiftData models and Codable API/JSON types
├── ViewModels/     Logic for each screen (no business logic in views)
├── Views/
│   ├── Events/        Sky events, event detail, save sheet, news
│   ├── SolarSystem/   Planet grid, planet detail, 3D scene
│   ├── MySky/         Saved events, observations, forms
│   └── Components/    Small reusable views and helpers
├── Services/       API clients, JSON loading, seeding, notifications
└── Data/           planets.json and sky_events.json
```

## Run / setup instructions

1. Open `FinalProject.xcodeproj` in Xcode 16 or later.
2. Select the **FinalProject** target, go to **Signing & Capabilities**, and choose your team.
3. Pick an iPhone simulator (iOS 17 or later) and press **Run**.

The app works without any API keys. Planets and sky events come from the bundled JSON files, and the Spaceflight News API needs no key.

## API / AI setup instructions

| Service | Key needed | Used for |
|---|---|---|
| Spaceflight News API | No | News tab |
| Launch Library 2 (planned) | No (15 requests/hour) | Upcoming launches |
| Solar System OpenData (planned) | Yes, free by email | Extra planet data |
| Gemini API, free tier (optional) | Yes | AI feature |

To add a key:

1. Create `FinalProject/Secrets.plist` (it is already in `.gitignore`, so it is never committed).
2. Add a String entry per key, for example `SOLAR_SYSTEM_API_KEY` or `GEMINI_API_KEY`.
3. The app reads keys from this file at runtime. If the file is missing, those features fall back to the bundled data.

**Never commit API keys to GitHub.**

## Data sources

- Eclipse dates and visibility: NASA, Future Eclipses (science.nasa.gov/eclipses/future-eclipses)
- Meteor shower dates are approximate peak dates and should be checked each year.
- Planet values are rounded averages. Moon counts change as new moons are confirmed.
- News: Spaceflight News API by The Space Devs

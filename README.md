# Final Project: Sky Tracker (working title)

**420-N52-LA Mobile Application Development 2: iOS**
Champlain College Saint-Lambert · Instructor: Morteza Khanjanzadeh

## Team members

- Aarush Patel (2330241)

## Project purpose

Space events like eclipses and meteor showers are easy to miss, and most people can't picture how the planets compare to Earth. This app gathers upcoming sky events and space news in one place, lets you explore the solar system in 3D, and keeps a personal log of the events you plan to watch and what you actually saw.

## Main features

1. **Sky Events:** upcoming eclipses and meteor showers with a countdown, where they're visible, and what happens. Filter by type and save events to My Sky.
2. **Space News and Launches:** the latest spaceflight articles and upcoming launches, with pull to refresh. Launches are cached for one hour to limit API requests.
3. **Solar System:** the eight planets, with a toggle to include Pluto. Each planet opens a 3D model you can rotate and zoom, plus insight cards (gravity, temperature, moons, day and year length).
4. **My Sky:** saved events with notes and reminders, and an observation log (create, edit, delete) linked to planets and events.

## Technologies used

- SwiftUI, MVVM, `@Observable` view models
- SwiftData with three related `@Model` types: `CelestialBody`, `SavedEvent`, `SkyObservation`
- `NavigationStack`, sheets, `TabView`
- SceneKit for the 3D planets
- Swift Charts for Earth comparisons
- Local notifications for saved events (9 a.m. the day before)
- EventKit write-only access to add saved events as all-day calendar entries
- PhotosPicker and Core Location for observation photos and coordinates
- URLSession, async/await, Codable (Spaceflight News API)
- Launch Library 2 v2.3.0 (upcoming launches, one-hour JSON cache)
- Bundled JSON data for planets and sky events

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
├── Services/       API clients, JSON loading, seeding, notifications, calendar
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
| Launch Library 2 | No (15 requests/hour) | Upcoming launches |
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
- Launches: Launch Library 2 by The Space Devs

## Planet texture maps

The nine planet textures in `FinalProject/Assets.xcassets` (`mercury_texture` through
`pluto_texture`) were procedurally generated for this project with a custom Python script
(NumPy + Pillow), written with help from Claude (Anthropic). Each is a 2048 × 1024
equirectangular map whose left and right edges match, so it wraps seamlessly around the
3D sphere. They are stylized and scientifically inspired, not real imagery (for example,
Earth's continents are invented). Saturn's rings are drawn by the app, so its texture is the
planet only. If an image is missing, the planet falls back to its color.

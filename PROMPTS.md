# Build Prompts

Send these one at a time from the project folder. After each one: build, run it in the simulator, read what changed, then commit.

The starter already has: the three tabs, all three SwiftData models with relationships, bundled planets and sky events, news from the Spaceflight News API, a spinning 3D planet you can zoom, and full create / edit / delete for saved events and observations. Each `TODO (Prompt N)` in the code matches a prompt below.

---

## Prompt 0: Context (send this first)

```
This is my iOS final project for 420-N52-LA. Read README.md and the code in FinalProject/ first.
Rules for every change:
- SwiftUI, MVVM, SwiftData, iOS 17+. Business logic goes in ViewModels or Services, not in Views.
- Keep views small and reusable. Use clear names and brief comments.
- Handle errors and never block the main thread (async/await for network calls).
- Never put API keys in code. Keys go in FinalProject/Secrets.plist, which is gitignored.
- After each change, explain in a few sentences what you changed and why, so I can explain it in my demo.
Don't change anything yet. Summarize the architecture back to me.
```

## Prompt 1: Build check

```
Build the project for an iPhone simulator and fix any compile errors or warnings.
Don't add features. Tell me what you had to fix.
```

## Prompt 2: Charts on the planet screen

```
In PlanetDetailView, replace the "TODO (Prompt 2)" with a Swift Charts bar chart comparing
the selected planet to Earth on gravity, radius and length of day (as a ratio, Earth = 1).
Put the data preparation in SolarSystemViewModel (a function returning chart rows), and make
the chart its own small view in Views/SolarSystem/.
```

## Prompt 3: Real planet textures and Saturn's rings

```
In PlanetSceneView, add support for a texture image per planet. Add an optional textureName
to CelestialBody (fall back to the color if no image exists). Look for an image named
"<planet name lowercased>_texture" in Assets. Add flat rings for Saturn using an SCNTube or
SCNPlane with transparency. Tell me where to download free planet texture maps and what
license credit to put in the README.
```

## Prompt 4: Event insights

```
On EventDetailView, add:
1) a live countdown (days, hours, minutes) that updates every minute,
2) a "next event" highlight card at the top of the Sky Events list using EventsViewModel.nextEvent,
3) a search bar on the Sky Events list that filters by title.
Keep the filtering logic in EventsViewModel.
```

## Prompt 5: Upcoming launches (Launch Library 2)

```
Add a third section "Launches" to the Events tab using the Launch Library 2 API
(upcoming launches endpoint, no key; check thespacedevs.com/llapi for the current version).
The free limit is 15 requests per hour, so cache the response to a JSON file in the Caches
directory and only refetch if the cache is older than 1 hour. Create LaunchService in
Services/, a Codable Launch model in Models/, a LaunchesViewModel, and a LaunchesListView.
Show name, provider, date, status and image. Handle loading and error states.
```

## Prompt 6: Reminders (Local Notifications)

```
Implement NotificationService: request permission, schedule a reminder at 9 a.m. the day
before a SavedEvent (identifier = eventID), and cancel it. Call it from MySkyViewModel in
saveEvent, updateSavedEvent and deleteSavedEvent (the TODOs are there). If permission is
denied, show a short message instead of failing silently.
```

## Prompt 7: Add to Calendar (EventKit)

```
In SavedEventFormView, add an "Add to Calendar" button using EventKit with write-only access
(the usage description is already in the build settings). Put the EventKit code in a new
CalendarService in Services/ and call it from MySkyViewModel. Show a confirmation or error alert.
```

## Prompt 8: Photo and location on observations

```
In ObservationFormView, add a PhotosPicker that saves the image into Observation.photoData,
and a "Use my location" button that fills latitude and longitude with Core Location
(the usage description is already set). Put the location code in a LocationService in
Services/. Show the photo thumbnail in ObservationRow and on the form when editing.
```

## Prompt 9: Related news on an event

```
On EventDetailView, replace the "TODO (Prompt 9)" with a "Related news" section that calls
SpaceNewsService.fetchLatest(search:) with a keyword from the event (e.g. "eclipse" or
"meteor"). Show up to 3 articles with NewsRow. Add the loading logic to a small
EventDetailViewModel, not the view.
```

## Prompt 10: Extra planet data from Solar System OpenData (optional)

```
Add SolarSystemService that calls https://api.le-systeme-solaire.net/rest/bodies/{id} with a
Bearer key read from Secrets.plist (key name SOLAR_SYSTEM_API_KEY). Add a "Refresh from API"
button on PlanetDetailView that updates moonCount and adds mass and density to the insight
cards. If the key or network is missing, keep the bundled values and show a short message.
Add a Secrets.example.plist with an empty value so others know the format.
```

## Prompt 11: AI feature with Gemini (optional)

```
Add a voice-or-text "Quick log" on My Sky: the user says or types something like
"saw Jupiter and two of its moons last night around 11, really clear, 5 stars",
and Gemini (free tier, key from Secrets.plist as GEMINI_API_KEY) returns JSON with title,
date, planet name, rating and notes. Prefill ObservationFormView with the result so the user
confirms before saving. Use Speech framework for voice input. Put the API call in
GeminiService and the parsing in a ViewModel. It must work as part of the logging workflow,
not as a chatbot.
```

## Prompt 12: Polish and final check

```
Go through the app against the assignment rubric (Architecture 25, UI/UX 20, Functionality 25,
Code Quality 15, Creativity 15). Fix inconsistent spacing, missing empty states, missing
error messages, and anything that breaks MVVM. Then update README.md so the features,
technologies and setup steps match what the app actually does now.
```

## Prompt 13: Pitch deck outline

```
Write an outline for a 10-slide PowerPoint pitch: problem, idea, target users, main features,
data model diagram, technologies, screenshots/demo flow, challenges, outcomes, next steps.
List which screenshot to take for each slide.
```

---

## Git checklist

- `git init`, first commit with the starter, push to a **public** GitHub repo.
- Commit after every prompt with a clear message, e.g. `Add Swift Charts comparison to planet detail`.
- Check that `Secrets.plist` never shows up in `git status`.

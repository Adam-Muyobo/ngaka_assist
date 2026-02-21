# NgakaAssist (Smart EMR - Voice-First Clinical Assistant)

Flutter MVP UI + client scaffolding for clinicians in Botswana public hospitals.

- Mobile + Web: Flutter Android + Flutter Web
- Material 3, tablet-friendly layouts, large touch targets
- Clean architecture folder structure
- Mock data mode ON by default (app runs without backend)

## Run

### Mobile (Android)

```bash
flutter pub get
flutter run
```

### Web

```bash
flutter pub get
flutter run -d chrome
```

## Mock Mode

Mock mode is controlled in `lib/core/constants.dart`:

- Default: `kUseMockData = true`
- Override at runtime:

```bash
flutter run --dart-define=NGAKA_USE_MOCK=false --dart-define=NGAKA_API_BASE_URL=https://your-backend.example
```

Notes:
- In mock mode, transcripts / SOAP drafts / ICD-10 suggestions are locally generated and persisted in Hive (`mock_cache`).
- Consultation mode now accesses the device microphone and uses platform speech-to-text via Flutter (`speech_to_text`).

## Backend Alignment (Client Scaffolding)

API paths live in `lib/data/api/api_paths.dart`:

- `POST /auth/login`
- `GET /patients?query=`
- `POST /patients`
- `GET /patients/{id}`
- `POST /encounters`
- `POST /encounters/{id}/audio` (multipart)
- `GET /encounters/{id}/transcript`
- `POST /encounters/{id}/transcript/nlp` (submit in-app transcription text for NLP)
- `GET /encounters/{id}/soap_draft`
- `PUT /encounters/{id}/soap_draft`
- `GET /encounters/{id}/icd10_suggestions`
- `POST /encounters/{id}/sign`


## Voice Transcription Flow

- Consultation mode uses the **device microphone** and Flutter's speech-to-text plugin.
- Record, pause/resume, stop, or delete before transcription.
- After stop/pause, the app transcribes locally in-app and sends only transcript text to backend NLP.

## Clean Architecture Map

- `lib/app/` app config, router, theme
- `lib/core/` constants, result types, helpers, storage wrappers
- `lib/domain/` entities + repository contracts + usecases
- `lib/data/` dio client, datasources (remote/mock), repository implementations, local Hive queue
- `lib/presentation/` screens, widgets, Riverpod controllers/providers

## Beginner Walkthrough

If you are new to Flutter, think of this app in **5 layers**:

1. **`main.dart` (entry point)**
   - Starts Flutter, initializes local storage (Hive), then launches the app widget tree.
2. **`lib/app/` (app shell)**
   - Sets up routing (which screen to show) and theme (how things look).
3. **`lib/presentation/` (UI + state)**
   - Screens/widgets the user sees.
   - Riverpod controllers keep UI state predictable and testable.
4. **`lib/domain/` (business meaning)**
   - Plain entities like Patient/Encounter and repository contracts.
   - This layer does **not** depend on Flutter widgets.
5. **`lib/data/` (data access)**
   - Calls remote APIs or mock data sources and maps data back to domain models.

### Typical Request Flow

When a clinician searches for a patient:

`Screen` → `Riverpod Controller` → `Use Case / Repository Contract` → `Repository Implementation` → `Remote or Mock Data Source`

That result comes back through the same path to update the UI.

### Why this structure helps beginners

- You can change UI without breaking API code.
- You can run locally with mock mode before backend is ready.
- You can test logic in domain/data layers separately from widgets.

## TODO Roadmap (Planned Modules)

- [ ] Real audio recorder integration (mobile + web), permissions, chunked upload
- [ ] Transcript streaming + diarization
- [ ] Offline-first conflict resolution for SOAP + signing
- [ ] Diagnosis engine ranking UI + guideline links
- [ ] Lab suggestions UI
- [ ] Medication prescribing UI
- [ ] Allergy capture UI
- [ ] Audit log viewer (admin)
- [ ] Role-based access control UI rules
- [ ] Encryption-at-rest hardening for local cache
- [ ] Multi-facility support
- [ ] Setswana language pack (i18n)
- [ ] FHIR export / integration
- [ ] Public health analytics dashboard

## Notes

This repo contains frontend only (Flutter). No backend code is generated here.

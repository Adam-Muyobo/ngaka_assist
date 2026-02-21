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
- Audio recording is a UI placeholder; a dummy upload action exists to show where real recording + multipart upload will plug in.

## Backend Alignment (Client Scaffolding)

API paths live in `lib/data/api/api_paths.dart`:

- `POST /auth/login`
- `GET /patients?query=`
- `POST /patients`
- `GET /patients/{id}`
- `POST /encounters`
- `POST /encounters/{id}/audio` (multipart)
- `GET /encounters/{id}/transcript`
- `GET /encounters/{id}/soap_draft`
- `PUT /encounters/{id}/soap_draft`
- `GET /encounters/{id}/icd10_suggestions`
- `POST /encounters/{id}/sign`

## Clean Architecture Map

- `lib/app/` app config, router, theme
- `lib/core/` constants, result types, helpers, storage wrappers
- `lib/domain/` entities + repository contracts + usecases
- `lib/data/` dio client, datasources (remote/mock), repository implementations, local Hive queue
- `lib/presentation/` screens, widgets, Riverpod controllers/providers

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

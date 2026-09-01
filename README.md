# Affiliate — MyStake iOS App

A clean, premium SwiftUI iOS companion app for **[mystake.com](https://mystake.com)**. It ships with a **Check URL** tool, a live in-app browser for the MyStake content (served from [mystake.great-site.net](https://mystake.great-site.net/)), and a demo *Chicken* crash game — all styled with a custom MyStake-inspired color system and original branding.

---

## Features

| Tab | What it does |
| --- | --- |
| **Home** | Hero dashboard with quick actions, brand stats and feature shortcuts |
| **Check URL** | Paste any MyStake / affiliate link and verify it is live and reachable, with a persistent local history |
| **Game** | A play-money *Chicken* crash game (cash out before it crashes) — demo credits only |
| **Live** | In-app browser loading the real MyStake content from `https://mystake.great-site.net/` |
| **Profile** | Partner profile, stats, settings, support and about |

### Check URL
- Normalises input (adds `https://` when missing)
- Only permits approved MyStake domains (`mystake.com`, `mystake.great-site.net`)
- Performs a `HEAD` request (falls back to `GET`) and reports `HTTP` status
- Friendly messages for offline / timeout / certificate errors
- Keeps the last 50 checks stored locally on the device

### Demo Game
- Fully offline crash-game engine (multiplier, cash-out, crash point)
- Quick bet chips (5 / 10 / 25 / 50)
- Demo balance of 1,000 EUR — **virtual credits only, no real money**

---

## Project structure

```
Affiliate.xcodeproj/          Xcode project (Affiliate target, Affiliate scheme)
Affiliate/
  AffiliateApp.swift          App entry point
  Info.plist                  App configuration (ATS, launch screen)
  Theme/Theme.swift           Colors, gradients, typography, haptics
  Models/AppModels.swift      Shared models
  Services/
    AffiliateConfig.swift     Brand + URL constants
    URLCheckerService.swift   Link validation engine
    HistoryStore.swift        Local persistence of check history
  Game/ChickenGame.swift      Demo crash-game engine
  Views/
    RootView.swift            Tab bar
    HomeView.swift
    URLCheckerView.swift
    GameView.swift
    LiveWebView.swift
    ProfileView.swift
  Assets.xcassets/            App icon, logo, mascot, hero + colors
design/                       Original generated artwork (source files)
brand/                        Copy of the brand assets for reference
bitrise.yml                   Bitrise CI workflow (build_ipa)
```

---

## Requirements

- **Xcode 14+** (project format is compatible; built with the SwiftUI lifecycle)
- **iOS 16.0+** deployment target
- No third-party dependencies — pure SwiftUI + WebKit + Network

## Build locally

```bash
open Affiliate.xcodeproj
```

Select the **Affiliate** scheme and run. To build from the command line:

```bash
xcodebuild -project Affiliate.xcodeproj -scheme Affiliate \
  -configuration Release -destination "generic/platform=iOS" \
  -archivePath /tmp/Affiliate.xcarchive \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO archive
```

---

## Bitrise CI

The `bitrise.yml` at the repo root defines a `build_ipa` workflow that:

1. Clones the repo (`git-clone@8`)
2. Archives the **Affiliate** scheme with code signing disabled
3. Packages the `.app` into an unsigned `Affiliate.ipa`
4. Uploads it to Bitrise (`deploy-to-bitrise-io@2`)

```
BITRISE_PROJECT_PATH: Affiliate.xcodeproj
BITRISE_SCHEME:       Affiliate
stack:                osx-xcode-26.5.x
machine_type_id:      g2.mac.large
```

> To distribute to devices / TestFlight, add a signing step with your Apple
> Developer certificates — the unsigned IPA is ready for that workflow.

---

## Brand

- **Colors** — deep navy background `#0B0E15`, emerald green `#00D084`, gold `#F6C445`
- **Typography** — SF rounded for headings, SF mono for odds/numbers
- **Iconography** — SF Symbols only (premium system icons, no emoji)
- **Artwork** — AI-generated logo, app icon, chicken mascot and hero (see `design/`)

---

## Disclaimer

Affiliate is an **unofficial** companion application for the MyStake platform. All game credits are virtual and for entertainment only; this app does not offer real-money gambling. The in-app browser displays third-party content from `mystake.great-site.net`, which is owned and operated by its respective provider.

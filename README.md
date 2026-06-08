# 🌾 FarmLog

> An offline crop management diary for Nigerian smallholder farmers.

---

## Overview

FarmLog is a mobile application built to solve a real problem faced by smallholder farmers across Nigeria — the absence of a structured, accessible way to track planting seasons, monitor crop growth, log input costs, and measure profitability per harvest season. The app works entirely offline, making it practical for farmers in rural areas with limited or no internet access.

---

## Screenshots

> _Add screenshots to this section after building the APK._

---

## The Problem

Most smallholder farmers in Nigeria manage their farm records mentally or on paper. This makes it difficult to:
- Know exactly how much was spent on seeds, fertiliser and labour
- Track whether a season ended in profit or loss
- Plan better for the next planting season based on past data

FarmLog addresses this by putting a simple, structured farm diary in every farmer's pocket.

---

## Features

- 🌱 Log crops with name, location, farm size (hectares) and planting date
- 📅 Set expected harvest dates with a live countdown
- 🔄 Track growth stages: Planted → Growing → Ready to Harvest → Harvested
- 💰 Log input costs by category (Seeds, Fertiliser, Labour, Pesticides, Equipment, Other)
- 📦 Record harvest quantity (kg) and estimated sale value (₦)
- 📊 Real-time Profit & Loss summary per crop season
- 🗂️ Filter crops by growth stage
- 📴 100% offline — all data stored locally on device
- ✏️ Edit and delete crop records at any time
- ℹ️ About screen with app credits

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart |
| Local Storage | shared_preferences |
| Charts | fl_chart |
| Date Formatting | intl |
| ID Generation | uuid |

---

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── crop.dart                  # Crop + InputCost models, enums, JSON serialisation
├── services/
│   └── farm_service.dart          # CRUD operations with SharedPreferences
└── screens/
    ├── home_screen.dart            # Dashboard, summary cards, stage filter, crop list
    ├── add_crop_screen.dart        # Add and edit crop form
    ├── crop_detail_screen.dart     # Cost logging, harvest logging, P&L view
    └── about_screen.dart           # App info and credits
```

---

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio (for Android SDK and emulator)
- VS Code with Flutter extension

### Installation

```bash
# 1. Create a new Flutter project
flutter create farmlog_app

# 2. Replace the lib/ folder and pubspec.yaml with the files from this repository

# 3. Install dependencies
cd farmlog_app
flutter pub get

# 4. Run on emulator or connected device
flutter run
```

### Build APK

```bash
flutter build apk --release
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Architecture

FarmLog follows a clean layered architecture:

- **Model** — defines `Crop` and `InputCost` data structures with full JSON serialisation, enum-based growth stages, and computed properties (profit/loss, days since planting, harvest countdown)
- **Service** — handles all local storage operations, abstracting SharedPreferences reads and writes from the UI layer
- **Screens** — stateful widgets managing UI logic and navigation
  - `HomeScreen` — overview dashboard with summary metrics and stage filtering
  - `AddCropScreen` — form-based crop creation and editing with date pickers
  - `CropDetailScreen` — cost logging via bottom sheet modals, harvest recording, P&L breakdown
  - `AboutScreen` — credits and feature summary

---

## Data Model

### Crop
| Field | Type | Description |
|---|---|---|
| id | String (UUID) | Unique identifier |
| name | String | Crop name (e.g. Maize, Cassava) |
| location | String | Farm location |
| farmSizeHectares | double | Farm area in hectares |
| plantedDate | DateTime | Date of planting |
| expectedHarvestDate | DateTime? | Optional expected harvest |
| stage | GrowthStage | Enum: planted, growing, ready, harvested |
| costs | List\<InputCost\> | List of logged input costs |
| harvestQuantityKg | double? | Recorded yield in kg |
| estimatedSaleValueNaira | double? | Expected revenue in ₦ |
| notes | String | Free-text notes |

### InputCost
| Field | Type | Description |
|---|---|---|
| id | String (UUID) | Unique identifier |
| category | String | Seeds / Fertiliser / Labour / Pesticides / Equipment / Other |
| description | String | Free-text description |
| amount | double | Cost in Naira (₦) |
| date | DateTime | Date cost was incurred |

---

## Computed Properties

- **totalCosts** — sum of all input cost amounts
- **profitLoss** — `estimatedSaleValueNaira - totalCosts`
- **daysSincePlanting** — days elapsed from planting date to today
- **daysToHarvest** — days remaining until expected harvest (negative = overdue)

---

## Developer

**Israel Olukayode**
Built with Flutter & Dart
© 2025 Israel Olukayode. All rights reserved.

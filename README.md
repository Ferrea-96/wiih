# WIIH

WIIH is a Flutter app for managing your wine cellar.

## Features
- Dashboard with cellar stats and totals
- Add, edit, and delete wines
- Track wine details: name, type, winery, country, grape, vintage, price, bottles, image
- Country view to browse wines by origin
- Export cellar data as CSV from the More tab

## Data storage and sync
- Local: wines are stored on-device using SharedPreferences for quick offline access.
- Cloud: when signed in, wines are synced to Firebase Firestore.
- Images: bottle images are stored in Firebase Storage and referenced by URL.
- Save behavior: updates are saved after add/edit/delete and when sorting or filtering changes the list.

## Export
- Export creates a CSV that includes: id, name, type, winery, country, grapeVariety, year, price, bottleCount, imageUrl.
- Mobile/desktop: CSV is written to a temporary file and shared via the system share sheet.
- Web: CSV is copied to the clipboard.

## Planned
- Import from CSV (round-trip for backups and migration)
- Additional filters and scanning options

## Possible goals
- Use as a wine journal and cellar database
- Expand later with filtering, export, sync, or barcode scan

Place welcome assets here.

Required for the Welcome screen:
- `welcome_hero.png` (the beige hero image with the 3 chore cards)

Image quality note:
- Your current file is quite small (e.g. ~400px wide), so it will look blurry when Flutter scales it up on Retina/web.
- For crisp results, add resolution variants (same filename) and Flutter will pick them automatically:
	- `assets/2.0x/welcome_hero.png` (about 2× the base pixels)
	- `assets/3.0x/welcome_hero.png` (about 3× the base pixels)

Suggested sizes (rough guide):
- Base: ~400×400
- 2.0x: ~800×800
- 3.0x: ~1200×1200

After adding the file, run from repo root:
- `./flutterw run -d chrome`

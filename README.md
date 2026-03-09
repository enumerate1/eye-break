# EyeBreak

A native macOS break reminder app. Follows the **20-20-20 rule** — every 20 minutes, look at something 20 feet away for 20 seconds.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![Dependencies](https://img.shields.io/badge/dependencies-0-green)

## Features

- Menu bar app with countdown timer and eye icon
- Fullscreen overlay on all monitors during breaks
- Skip (button or Esc), Pause, Resume, Postpone controls
- Configurable break interval, duration, and pre-break warning
- Sound notifications (Glass on break start, Ping on break end)
- Settings apply immediately
- Smooth fade in/out animations

## Requirements

- macOS 14.0+
- Swift 5.9+ (Xcode CommandLineTools)

## Build & Run

```bash
./build.sh && open .build/EyeBreak.app
```

## Usage

EyeBreak lives in your **menu bar**. Click the eye icon to pause, skip, postpone breaks, or open Settings.

## License

MIT

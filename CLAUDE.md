# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository state

Prosper ("Metal Dashboard") is an Android app, but the repository currently holds only three tracked
files: `.gitignore`, `README.md`, and `android/app/build.gradle`. There is no Gradle wrapper, no
`settings.gradle`, no root `build.gradle`, no `AndroidManifest.xml`, no `proguard-rules.pro` (despite
`build.gradle` referencing it), and no source or resource directories.

Practical consequence: the build commands in `README.md` do not run as-is. Before any Gradle command
works, the surrounding scaffolding has to exist. When asked to "build" or "run tests", check for these
files first rather than assuming a broken toolchain.

## Non-standard module layout

The app module lives at `android/app/`, not the Gradle Android default of `app/`. A `settings.gradle`
added here must account for that, e.g.:

```groovy
include ':app'
project(':app').projectDir = file('android/app')
```

Getting this wrong is the most likely cause of a "project not found" failure.

## Build and test commands

Once the wrapper and settings files exist (per `README.md`):

```bash
./gradlew build                      # full build
./gradlew bundleRelease              # signed AAB for Play Store distribution
./gradlew assembleDebug              # debug APK
./gradlew test                       # JVM unit tests (JUnit 4)
./gradlew connectedAndroidTest       # instrumented tests (Espresso, needs device/emulator)
```

Single test:

```bash
./gradlew :app:testDebugUnitTest --tests 'com.diamondedgemetals.prosper.SomeTest'
./gradlew :app:testDebugUnitTest --tests 'com.diamondedgemetals.prosper.SomeTest.someMethod'
./gradlew :app:connectedDebugAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.class=com.diamondedgemetals.prosper.SomeInstrumentedTest
```

Adjust `:app` to whatever path `settings.gradle` assigns the module.

## Release signing

`android/app/build.gradle` wires the `release` signing config entirely to environment variables:

| Variable | Purpose |
| --- | --- |
| `KEYSTORE_PATH` | Path to the keystore file |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Signing key alias |
| `KEY_PASSWORD` | Key password |

Nothing supplies defaults, so any release task (`bundleRelease`, `assembleRelease`) fails without all
four set in the environment. Debug builds are unaffected. Keep credentials in the environment — the
build file is written so none of them are ever committed.

## Project coordinates

- Application ID and namespace: `com.diamondedgemetals.prosper`
- `compileSdk` / `targetSdk` 34, `minSdk` 24
- Java source/target compatibility 1.8 — no Kotlin plugin is applied, so new code is Java by default
- `versionCode 1`, `versionName "1.0.0"` — bump both in `android/app/build.gradle` for Play releases
- UI stack: AppCompat, Material Components, ConstraintLayout
- `minifyEnabled false` on release; ProGuard rules are referenced but the file does not exist yet

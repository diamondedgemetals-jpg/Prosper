# Prosper — MetalBot

Android app bundle (AAB) for the Diamond Edge Metals dashboard.

- **Application ID:** `com.diamondedgemetals.metalbot`
- **minSdk:** 24 · **targetSdk / compileSdk:** 36
- **Shell:** native `MainActivity` hosting a `WebView`, serving the dashboard
  from app assets over a virtual `https://appassets.androidplatform.net` origin
  (`WebViewAssetLoader`), so `localStorage` and `fetch` behave as they do in a browser.

## Project layout

```
android/                       Gradle root
  settings.gradle
  build.gradle                 AGP 8.13.2
  gradlew                      Gradle 8.14.3 wrapper
  app/
    build.gradle
    src/main/
      AndroidManifest.xml
      java/com/diamondedgemetals/metalbot/MainActivity.java
      res/                     themes, icons, layout
      assets/public/           web payload  <-- your build goes here
```

## Build

Requires JDK 17+ and an Android SDK with `platforms;android-36`.

```bash
cd android
export ANDROID_HOME=/path/to/android-sdk
./gradlew bundleRelease      # -> app/build/outputs/bundle/release/app-release.aab
./gradlew bundleDebug        # debug-signed, installable for testing
./gradlew assembleDebug      # plain APK
```

Without a keystore in the environment the release bundle builds **unsigned** —
useful for CI and local checks, but Play will not accept it until it is signed.

## Signing

Release signing is driven entirely by environment variables; no key material
lives in this repo. Create an upload key once and keep it somewhere safe:

```bash
keytool -genkeypair -v \
  -keystore upload.jks -alias metalbot \
  -keyalg RSA -keysize 4096 -validity 10000
```

Then build with:

```bash
export KEYSTORE_PATH=/absolute/path/to/upload.jks
export KEYSTORE_PASSWORD=...
export KEY_ALIAS=metalbot
export KEY_PASSWORD=...
cd android && ./gradlew bundleRelease
```

**Losing this key means you can no longer update the app on Play.** Back it up.

## CI

`.github/workflows/android.yml` builds the AAB on every push and uploads it as
a workflow artifact. To get a *signed* bundle out of CI, add four repository
secrets (Settings → Secrets and variables → Actions):

| Secret | Value |
| --- | --- |
| `KEYSTORE_BASE64` | `base64 -w0 upload.jks` |
| `KEYSTORE_PASSWORD` | keystore password |
| `KEY_ALIAS` | `metalbot` |
| `KEY_PASSWORD` | key password |

`versionCode` is taken from the workflow run number so each CI build is
uploadable to Play; `versionName` defaults to `1.0.0` and can be overridden
with the `VERSION_NAME` environment variable.

## Replacing the placeholder dashboard

`assets/public/` currently holds a self-contained placeholder page. To ship the
real web app, build it and copy the output in:

```bash
npm run build
rm -rf android/app/src/main/assets/public/*
cp -r dist/* android/app/src/main/assets/public/
cd android && ./gradlew bundleRelease
```

Vite must emit relative URLs for this to work — set `base: './'` in
`vite.config.ts`, otherwise absolute `/assets/...` paths will not resolve
against the asset loader.

That directory is the same path Capacitor syncs into, so moving to Capacitor
later does not change the layout.

# Publishing Royal CV Maker on Google Play

Guide for this Flutter app: `applicationId` / `package` **`com.alaa.cv_app`**, on-device name **Royal CV Maker**, version in **`pubspec.yaml`** as `versionName+versionCode` (e.g. `1.0.0+1`).

---

## Prerequisites

| Item | Notes |
|------|--------|
| **Play Console** | [play.google.com/console](https://play.google.com/console) — one-time **$25** developer fee. |
| **Signing** | Release uses `upload-keystore.jks` (see `android/app/build.gradle.kts`). Enable **Play App Signing**; upload AABs; keep the keystore and passwords **backed up offline** and out of public repos. |
| **Privacy policy URL** | Host `docs/privacy_policy.html` (or equivalent) on **`https://…`**; Play often requires a link. |
| **Secrets** | Do not commit keystore passwords. Prefer `key.properties` (gitignored) or CI secrets; rotate if exposed. |

**Publisher (your records):** Digital Frontier Applications Studio — **jaeereyreedeso@gmail.com**

---

## Store listing (what to prepare)

- **App name (≤30 chars):** e.g. *Royal CV Maker*
- **Short description (≤80 chars):** one line; e.g. *Build a professional CV, preview it, and export to PDF with multiple templates.*
- **Full description (≤4000 chars):** sign-in, CV editor, EN/AR, PDF templates, preview/print, etc.
- **Category:** e.g. **Productivity** or **Business**
- **Contact email:** one you monitor (e.g. above)
- **Graphics:** high-res **icon** (512×512 for Play), **feature graphic** 1024×500, **phone screenshots** (at least 2; 6–8 is better)
- **Phone / website:** optional; policy URL is the critical link

---

## What to declare in Play (this codebase)

Use this for **Data safety**, **content rating**, and support — keep it aligned with `docs/privacy_policy.html`.

| Area | In this app |
|------|----------------|
| **Account** | Email/password via **Firebase Auth**; password reset by email. |
| **Network** | **INTERNET** in `android/app/src/main/AndroidManifest.xml` (required for release). |
| **Local** | **SharedPreferences** — CV data on device (`app_provider.dart`). |
| **Optional** | Profile name/photo; photo may go to **Firebase Storage** and `photoURL` on the user. |
| **PDF** | `pdf` + `printing` (preview/print; fonts may load as part of the library). |
| **Firestore** | Listed in `pubspec.yaml` but **not used in `lib/`** — remove later if unused; do not claim Firestore in Data safety if you do not use it. |

**Data safety (typical choices):** collection **yes** for account identifiers, email, name, optional photos; purpose **app functionality** / **account management**; **encryption in transit** yes (HTTPS to Firebase); **shared with** service providers (Google Firebase) as required by the form.

---

## Build a release AAB

```bash
cd /path/to/cv-app
flutter clean
flutter pub get
flutter build appbundle --release
```

- Output: **`build/app/outputs/bundle/release/app-release.aab`**
- Before each new Play upload, bump **`pubspec.yaml`**: `version: x.y.z+code` — **code** (after `+`) must **increase** every time.

---

## Play Console flow (order may vary)

1. **Create app** — default language, name, app type, declarations.
2. **Required policies** — App access, ads (no ads → say no), **Data safety**, **Privacy policy** URL, content rating, target audience, etc.
3. **Store listing** — texts, graphics, contact, category.
4. **Release** — **Testing** (internal closed/open) or **Production**; upload the `.aab`, release notes, review, roll out.

Prefer **internal testing** first: install from Play, test login, PDF, and updates before production.

---

## After go-live

- Watch **Android vitals** and reviews.
- Each update: new **versionCode**, new AAB, same quality checks.
- If you add analytics, ads, or new data: update **Data safety** and the **privacy policy** together.

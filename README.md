# رياحين الجنان - دليل الإعداد الكامل

## 📁 هيكل الملفات المُسلَّمة

```
riyaheen_aljinan/          ← اسم مشروعك في Android Studio
├── pubspec.yaml            ← استبدله بالكامل
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml   ← استبدله بالكامل
└── lib/
    ├── main.dart           ← استبدله بالكامل
    ├── core/
    │   ├── constants/
    │   │   ├── app_colors.dart
    │   │   ├── app_strings.dart
    │   │   └── app_dimensions.dart
    │   ├── theme/
    │   │   └── app_theme.dart
    │   └── widgets/
    │       ├── section_card.dart
    │       ├── custom_app_bar.dart
    │       └── coming_soon_body.dart
    └── features/
        ├── home/
        │   └── home_page.dart
        ├── quran/pages/quran_page.dart
        ├── tasmee3/pages/tasmee3_page.dart
        ├── azkar/pages/azkar_page.dart
        ├── tafsir/pages/tafsir_page.dart
        ├── fiqh/pages/fiqh_page.dart
        ├── library/pages/library_page.dart
        ├── audio/pages/audio_page.dart
        ├── quiz/pages/quiz_page.dart
        ├── favorites/pages/favorites_page.dart
        └── settings/pages/settings_page.dart
```

---

## 🔤 الخطوة 1: تحميل الخطوط

### خط Scheherazade New (للنصوص العامة)
1. افتح: https://fonts.google.com/specimen/Scheherazade+New
2. انقر Download family
3. من ملف ZIP احتفظ بـ:
   - `ScheherazadeNew-Regular.ttf`
   - `ScheherazadeNew-Bold.ttf`
4. ضعهما في: `assets/fonts/`

### خط UthmanicHafs (للقرآن)
1. افتح: https://www.noorsoft.org/ar/software/view/4
   أو: https://tanzil.net (قسم الخطوط)
2. حمّل خط UthmanicHafs1 Regular
3. أعد تسميته إلى: `UthmanicHafs.ttf`
4. ضعه في: `assets/fonts/`

### النتيجة المطلوبة:
```
assets/fonts/
├── ScheherazadeNew-Regular.ttf   ✅
├── ScheherazadeNew-Bold.ttf      ✅
└── UthmanicHafs.ttf              ✅
```

---

## 📦 الخطوة 2: تثبيت الحزم

افتح Terminal في Android Studio (View → Tool Windows → Terminal):

```bash
flutter pub get
```

---

## 🗂️ الخطوة 3: نسخ الملفات

انسخ كل الملفات من المجلد المضغوط إلى مشروعك **مع الحفاظ على نفس المسارات**.

> ⚠️ تأكد أن اسم المشروع لا يزال `riyaheen_aljinan` ولم يتغير

---

## ▶️ الخطوة 4: تشغيل التطبيق

```bash
flutter run
```

أو من Android Studio: اضغط زر التشغيل الأخضر ▶️

---

## 🐛 حل المشكلات الشائعة

### مشكلة: خطأ في الخط
```
Unable to load asset: assets/fonts/UthmanicHafs.ttf
```
**الحل:** تأكد أن الملف موجود في `assets/fonts/` وأن pubspec.yaml محفوظ صحيحاً

### مشكلة: Gradle Build Failed
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### مشكلة: SDK Version
في `android/app/build.gradle` تأكد:
```gradle
minSdk = 21
targetSdk = 34
compileSdk = 34
```

### مشكلة: flutter_animate لا يعمل
```bash
flutter pub upgrade flutter_animate
```

---

## 🔨 بناء APK للتوزيع

```bash
flutter build apk --release
```
الملف سيكون في: `build/app/outputs/flutter-apk/app-release.apk`

### APK لكل معمارية (أصغر حجماً):
```bash
flutter build apk --split-per-abi --release
```

---

## 📋 قائمة التحقق قبل التشغيل

- [ ] `pubspec.yaml` استُبدل بالكامل
- [ ] `flutter pub get` نُفِّذ بنجاح
- [ ] الخطوط الثلاثة في `assets/fonts/`
- [ ] `AndroidManifest.xml` استُبدل
- [ ] جميع ملفات `lib/` في مكانها الصحيح
- [ ] لا توجد أخطاء حمراء في Android Studio

---

## 🗺️ خارطة التطوير القادمة

| المرحلة | المحتوى |
|---------|---------|
| 2 | قسم القرآن الكامل (SQLite + قراءة) |
| 3 | نظام التسميع الذكي |
| 4 | الأذكار + مؤقت التسبيح |
| 5 | التفسير + الفقه |
| 6 | المكتبة الصوتية |
| 7 | الاختبارات + الإعدادات |

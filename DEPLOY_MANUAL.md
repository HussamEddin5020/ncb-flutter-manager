# تعليمات Deploy يدوي - Manager Web

## الطريقة 1: استخدام GitHub Pages (الأسهل)

### الخطوات:

1. **بناء المشروع:**
```bash
flutter build web --base-href "/ncb-flutter-manager/" --release
```

2. **إنشاء مجلد docs:**
```bash
# في مجلد المشروع
mkdir docs
```

3. **نسخ الملفات المبنية:**
```bash
# Windows PowerShell
Copy-Item -Path "build\web\*" -Destination "docs\" -Recurse -Force

# أو يدوياً: انسخ جميع الملفات من build/web/ إلى docs/
```

4. **إضافة و commit:**
```bash
git add docs/
git commit -m "Deploy to GitHub Pages"
git push
```

5. **تفعيل GitHub Pages:**
   - اذهب إلى: https://github.com/HussamEddin5020/ncb-flutter-manager/settings/pages
   - في **Source**: اختر **Deploy from a branch**
   - **Branch**: `main`
   - **Folder**: `/docs`
   - احفظ

6. **الانتظار:**
   - انتظر بضع دقائق حتى يتم نشر الموقع
   - الموقع سيكون على: `https://hussameddin5020.github.io/ncb-flutter-manager/`

---

## الطريقة 2: استخدام GitHub Actions (تلقائي)

### الخطوات:

1. **تفعيل GitHub Pages:**
   - اذهب إلى: https://github.com/HussamEddin5020/ncb-flutter-manager/settings/pages
   - في **Source**: اختر **GitHub Actions**
   - احفظ

2. **Push أي تغيير:**
```bash
git add .
git commit -m "Trigger deployment"
git push
```

3. **متابعة Build:**
   - اذهب إلى تبويب **Actions** في الريبوزوتوري
   - ستجد workflow يعمل تلقائياً
   - بعد اكتمال Build، سيتم نشر الموقع تلقائياً

---

## الطريقة 3: Deploy على Render/Vercel/Netlify

### Render:

1. اذهب إلى: https://render.com
2. أنشئ **Static Site** جديد
3. اربطه بالريبوزوتوري
4. Build Command: `flutter build web --release`
5. Publish Directory: `build/web`

### Vercel:

1. اذهب إلى: https://vercel.com
2. Import Project من GitHub
3. Build Command: `flutter build web --release`
4. Output Directory: `build/web`

### Netlify:

1. اذهب إلى: https://netlify.com
2. New site from Git
3. Build command: `flutter build web --release`
4. Publish directory: `build/web`

---

## ملاحظات مهمة:

- **Base href**: مهم جداً! يجب أن يكون `/ncb-flutter-manager/` للـ GitHub Pages
- **CORS**: تأكد من أن API backend يسمح بالطلبات من domain الموقع
- **Environment**: تأكد من أن `baseUrl` في `api_service.dart` صحيح


# دليل Deploy السريع - Manager Web

## ✅ تم بناء المشروع بنجاح!

الملفات المبنية موجودة في:
- `build/web/` - الملفات المبنية
- `docs/` - نسخة للنشر على GitHub Pages

---

## 🚀 خطوات Deploy على GitHub Pages:

### 1. تفعيل GitHub Pages:

1. اذهب إلى: **https://github.com/HussamEddin5020/ncb-flutter-manager/settings/pages**
2. في قسم **Source**:
   - اختر **Deploy from a branch**
   - **Branch**: `main`
   - **Folder**: `/docs`
3. اضغط **Save**

### 2. انتظار النشر:

- انتظر 1-2 دقيقة
- اذهب إلى: **https://hussameddin5020.github.io/ncb-flutter-manager/**

---

## 🔄 لتحديث الموقع بعد التعديلات:

### الطريقة 1: Build يدوي

```bash
# 1. بناء المشروع
flutter build web --base-href "/ncb-flutter-manager/" --release

# 2. نسخ الملفات
Remove-Item -Path docs -Recurse -Force
mkdir docs
Copy-Item -Path "build\web\*" -Destination "docs\" -Recurse -Force

# 3. Push
git add docs/
git commit -m "Update deployment"
git push
```

### الطريقة 2: استخدام GitHub Actions (تلقائي)

1. تأكد من تفعيل GitHub Actions في Settings > Pages
2. أي push إلى `main` سيؤدي إلى build ونشر تلقائي

---

## 📝 ملاحظات:

- **Base href**: `/ncb-flutter-manager/` (مهم جداً!)
- **CORS**: تأكد من أن API يسمح بالطلبات من `hussameddin5020.github.io`
- **URL**: `https://hussameddin5020.github.io/ncb-flutter-manager/`

---

## 🛠️ حل المشاكل:

### المشكلة: الموقع لا يعمل
- تحقق من أن GitHub Pages مفعل
- تحقق من أن مجلد `docs/` موجود ويحتوي على الملفات
- تحقق من Base href في `index.html`

### المشكلة: CORS Error
- تأكد من أن API backend يسمح بالطلبات من domain GitHub Pages
- أضف `hussameddin5020.github.io` إلى CORS allowed origins في Node.js backend

### المشكلة: الصور لا تظهر
- تحقق من أن `assets/` موجودة في `docs/`
- تحقق من المسارات في `pubspec.yaml`


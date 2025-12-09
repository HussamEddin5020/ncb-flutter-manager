# تعليمات نشر المشروع على GitHub Pages

## الخطوات

### 1. تفعيل GitHub Pages

1. اذهب إلى الريبوزوتوري على GitHub: https://github.com/HussamEddin5020/ncb-flutter-manager
2. اضغط على **Settings**
3. في القائمة الجانبية، اضغط على **Pages**
4. في قسم **Source**:
   - اختر **GitHub Actions** كـ source
5. احفظ التغييرات

### 2. انتظار Build الأول

- بعد push أي commit، سيتم تشغيل GitHub Actions workflow تلقائياً
- يمكنك متابعة التقدم من تبويب **Actions** في الريبوزوتوري
- بعد اكتمال Build، سيتم نشر الموقع تلقائياً

### 3. الوصول إلى الموقع

بعد تفعيل GitHub Pages، سيكون الموقع متاحاً على:
```
https://hussameddin5020.github.io/ncb-flutter-manager/
```

### 4. Build يدوي (اختياري)

إذا أردت عمل build يدوياً:

```bash
flutter build web --base-href "/ncb-flutter-manager/" --release
```

الملفات المبنية ستكون في `build/web/`

## ملاحظات مهمة

- **Base href**: تم تعيين `--base-href "/ncb-flutter-manager/"` لأن المشروع موجود في subdirectory على GitHub Pages
- **CORS**: تأكد من أن API backend يسمح بالطلبات من domain GitHub Pages
- **Authentication**: المشروع يستخدم SharedPreferences لحفظ حالة تسجيل الدخول، لذا عند refresh الصفحة سيتم التحقق من token المحفوظ

## تحديث الموقع

عند عمل أي push إلى branch `main`، سيتم عمل build ونشر تلقائي للموقع.


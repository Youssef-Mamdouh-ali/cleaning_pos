# Cleaning POS - هيكلة MVVM

المشروع اتقسّم بالكامل بنمط **MVVM** (Model - View - ViewModel) مع فصل الويدجت
والألوان والأنماط في طبقات مستقلة، بحيث أي تعديل مستقبلي (شاشة جديدة، تغيير
تصميم، تغيير مصدر البيانات) يبقى محصور في مكان واحد وواضح.

## الهيكل العام

```
lib/
├── main.dart                     # نقطة البداية - تجهيز الـ Repositories وحقنها في الـ ViewModels
│
├── core/                         # كل حاجة عامة مالهاش علاقة بشاشة معينة
│   ├── theme/
│   │   ├── app_colors.dart       # كل ألوان التطبيق (لون واحد يتغير من هنا)
│   │   ├── app_text_styles.dart  # أنماط النصوص المشتركة
│   │   └── app_theme.dart        # ThemeData الموحد (أزرار، حقول، نوافذ...)
│   ├── constants/
│   │   └── app_dimensions.dart   # مسافات وانحناءات موحدة بدل الأرقام السايبة
│   └── utils/
│       ├── result.dart           # شكل موحد لنتيجة أي عملية (نجاح/فشل)
│       └── validators.dart       # كل قواعد التحقق من صحة المدخلات
│
├── data/                         # كل حاجة ليها علاقة بمصدر البيانات (Model)
│   ├── models/
│   │   ├── product.dart
│   │   └── invoice.dart
│   ├── database/
│   │   └── database_helper.dart  # التعامل الخام مع SQLite
│   └── repositories/
│       ├── product_repository.dart   # وسيط بين ViewModel وقاعدة البيانات
│       └── invoice_repository.dart
│
├── viewmodels/                   # منطق كل شاشة (State + Business Logic)
│   ├── pos_view_model.dart       # منطق السلة والباركود والدفع
│   ├── products_view_model.dart  # منطق إضافة/تعديل/حذف/بحث المنتجات
│   └── invoices_view_model.dart  # منطق تحميل الفواتير ومبيعات اليوم
│
└── views/                        # الواجهات فقط (View) - بلا أي منطق أعمال
    ├── shared/
    │   ├── home_shell.dart       # القالب الرئيسي + شريط التنقل
    │   └── widgets/              # ويدجت مشتركة بين كل الشاشات
    │       ├── app_card.dart
    │       ├── app_icon_badge.dart
    │       ├── app_action_icon_button.dart
    │       ├── app_empty_state.dart
    │       └── app_form_field.dart
    ├── pos/
    │   ├── pos_screen.dart
    │   └── widgets/               # كل ويدجت شاشة البيع منفصلة في ملفها
    │       ├── barcode_scan_field.dart
    │       ├── cart_error_banner.dart
    │       ├── cart_header.dart
    │       ├── cart_item_tile.dart
    │       └── order_summary_panel.dart
    ├── products/
    │   ├── products_screen.dart
    │   └── widgets/
    │       ├── product_row.dart
    │       ├── product_table_header.dart
    │       ├── product_form_dialog.dart
    │       └── delete_product_dialog.dart
    └── invoices/
        ├── invoices_screen.dart
        └── widgets/
            ├── today_sales_banner.dart
            ├── invoice_row.dart
            └── invoice_details_dialog.dart

test/
└── validators_test.dart          # اختبارات وحدة لدوال التحقق (Validators)
```

## ليه اتقسم كده؟

### 1. الفصل بين الطبقات (Model / ViewModel / View)
- **Model** (`data/`): موديلات البيانات + قاعدة البيانات + Repositories.
- **ViewModel** (`viewmodels/`): كل منطق الشاشة (state, حسابات, قرارات) في كلاس
  `ChangeNotifier` واحد. الشاشة (View) بتستدعي دواله بس ومتعرفش تفاصيله.
- **View** (`views/`): واجهات بحتة، بترسم البيانات اللي جاية من الـ ViewModel
  وتستدعي دواله عند أي تفاعل (زرار، إدخال...). مفيهاش أي استدعاء مباشر
  لقاعدة البيانات.

### 2. Repository Layer
بدل ما الـ ViewModel يكلم `DatabaseHelper` مباشرة، فيه `ProductRepository` و
`InvoiceRepository` في النص. الفايدة: لو حبيت تضيف مزامنة سحابية بعدين، أو
حتى تستبدل SQLite بمصدر تاني، هتغيّر جوه الـ Repository بس، والـ ViewModels
والشاشات هتفضل شغالة زي ما هي.

### 3. Result بدل Exceptions المباشرة
كل عملية في الـ Repository بترجع `Result<T>` (إما `Success` أو `Failure` مع
رسالة واضحة بالعربي)، بدل ما نرمي `Exception` ونمسكها بـ `try/catch` في كل
شاشة. الـ ViewModel بيقرأ النتيجة ويحط رسالة الخطأ في `errorMessage`، والشاشة
بتعرضها زي ما هي.

### 4. Validators منفصلة
كل قواعد التحقق (اسم المنتج مطلوب، السعر لازم يكون رقم موجب...) موجودة في
`core/utils/validators.dart`. النماذج (Forms) بتستخدمها بس، فلو غيّرت قاعدة
(مثلاً: أقل سعر مسموح به) هتغيرها في مكان واحد.

### 5. Dependency Injection بسيط عن طريق provider
في `main.dart`، بيتم إنشاء الـ Repositories مرة واحدة، وحقنها في الـ
ViewModels عن طريق `MultiProvider` + `ChangeNotifierProvider`. مفيش أي شاشة
بتعمل `DatabaseHelper()` أو `ProductRepository()` بنفسها.

### 6. فصل الويدجت
كل شاشة كبيرة (نقطة البيع، المنتجات، الفواتير) اتقسّمت لملفات ويدجت صغيرة في
مجلد `widgets/` جنبها. الملف الرئيسي للشاشة (`*_screen.dart`) بقى صغير وسهل
القراءة، وبيربط بين الويدجت والـ ViewModel بس.

### 7. اختبارات وحدة (Unit Tests)
فيه اختبارات لـ `Validators` في `test/validators_test.dart` لأنها دوال Dart
خالصة (مش محتاجة قاعدة بيانات أو واجهة)، فبتشتغل بسرعة وبتضمن إن قواعد
التحقق شغالة صح. شغّلها بـ:
```
flutter test
```

## إضافة شاشة جديدة (مثال توضيحي)
لو حبيت تضيف شاشة جديدة (مثلاً "تقارير")، الخطوات:
1. أضف Repository لو محتاج مصدر بيانات جديد (`data/repositories/`).
2. أضف `ReportsViewModel extends ChangeNotifier` في `viewmodels/`.
3. سجّله في `main.dart` جوه `MultiProvider`.
4. أضف مجلد `views/reports/` فيه `reports_screen.dart` + `widgets/` لأي
   ويدجت خاصة بيها.
5. أضف الشاشة في `home_shell.dart` جنب باقي الشاشات.

## التشغيل
نفس خطوات المشروع الأصلي:
```
flutter pub get
flutter run -d windows
```

لتشغيل الاختبارات:
```
flutter test
```

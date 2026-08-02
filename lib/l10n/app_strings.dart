import 'package:rategold/l10n/app_language.dart';
import 'package:rategold/l10n/currency_names.dart';
import 'package:rategold/models/rates_snapshot.dart';
import 'package:rategold/models/sync_status.dart';

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  String currencyName(String code) => CurrencyNames.name(code, language);

  String goldUnitLabel(String code) {
    return switch (language) {
      AppLanguage.zh => switch (code) {
          'INR' => '24K / 10克',
          _ => '24K / 克',
        },
      AppLanguage.ar => switch (code) {
          'INR' => '24K / 10 جم',
          _ => '24K / جم',
        },
      AppLanguage.hi => switch (code) {
          'INR' => '24K / 10g',
          _ => '24K / g',
        },
      AppLanguage.id => switch (code) {
          'INR' => '24K / 10g',
          _ => '24K / g',
        },
      AppLanguage.en => switch (code) {
          'INR' => '24K / 10g',
          _ => '24K / g',
        },
    };
  }

  // Navigation
  String get tabBoard => _t('Board', '看板', 'لوحة', 'बोर्ड', 'Papan');
  String get tabConvert => _t('Convert', '换算', 'تحويل', 'रूपांतरण', 'Konversi');
  String get tabSettings => _t('Settings', '设置', 'الإعدادات', 'सेटिंग्स', 'Pengaturan');

  // Board
  String get appTitle => 'RateGold';
  String get goldToday => _t('GOLD TODAY', '今日金价', 'ذهب اليوم', 'आज का सोना', 'EMAS HARI INI');
  String get goldMarketsTitle =>
      _t('Gold markets', '金价市场', 'أسواق الذهب', 'सोने के बाज़ार', 'Pasar emas');
  String get goldInrUnitNote => _t(
        'India retail gold is quoted per 10g (local convention).',
        '印度金价按 10 克报价，为当地行业惯例。',
        'الذهب في الهند يُسعَّر لكل 10 جم (عرف محلي).',
        'भारत में सोना आमतौर पर 10g के हिसाब से होता है।',
        'Emas India biasanya per 10g (konvensi lokal).',
      );
  String goldSpotUsd(double usdPerOz) => _t(
        'Spot · USD ${usdPerOz.toStringAsFixed(2)}/oz',
        '现货 · USD ${usdPerOz.toStringAsFixed(2)}/盎司',
        'Spot · USD ${usdPerOz.toStringAsFixed(2)}/oz',
        'Spot · USD ${usdPerOz.toStringAsFixed(2)}/oz',
        'Spot · USD ${usdPerOz.toStringAsFixed(2)}/oz',
      );
  String goldSourceLabel(String source) => _t(
        'Source: $source',
        '来源：$source',
        'المصدر: $source',
        'स्रोत: $source',
        'Sumber: $source',
      );
  String get seeAll => _t('See all', '查看全部', 'عرض الكل', 'सभी देखें', 'Lihat semua');
  String myRates(String base) => _t(
        'MY RATES · Base: $base',
        '我的汇率 · 基准: $base',
        'أسعاري · الأساس: $base',
        'मेरी दरें · आधार: $base',
        'KURS SAYA · Dasar: $base',
      );
  String get goldUnavailable => _t(
        'Gold prices unavailable',
        '金价暂不可用',
        'أسعار الذهب غير متاحة',
        'सोने की कीमत उपलब्ध नहीं',
        'Harga emas tidak tersedia',
      );
  String get goldUnavailableHint => _t(
        'Pull to refresh when online',
        '联网后下拉刷新',
        'اسحب للتحديث عند الاتصال',
        'ऑनलाइन होने पर रीफ्रेश करें',
        'Tarik untuk segarkan saat online',
      );
  String get emptyFavoritesTitle => _t(
        'Add currencies you check most',
        '添加常用货币',
        'أضف العملات التي تتابعها',
        'अपनी मुख्य मुद्राएँ जोड़ें',
        'Tambah mata uang favorit',
      );
  String get emptyFavoritesHint => _t(
        'Pull to sync or manage your favorites',
        '下拉同步或管理收藏',
        'اسحب للمزامنة أو إدارة المفضلة',
        'सिंक करें या पसंदीदा प्रबंधित करें',
        'Tarik untuk sinkron atau kelola favorit',
      );
  String get addCurrency => _t('Add currency', '添加货币', 'إضافة عملة', 'मुद्रा जोड़ें', 'Tambah mata uang');
  String get staleCaption => _t(
        'Gold spot not updated in 24h',
        '金价现货超过 24 小时未更新',
        'لم يُحدَّث سعر الذهب منذ 24 ساعة',
        '24 घंटे से सोने की कीमत अपडेट नहीं',
        'Harga spot emas belum diperbarui 24 jam',
      );
  String get ratesStaleCaption => _t('Rates may be outdated', '汇率可能已过期', 'قد تكون الأسعار قديمة', 'दरें पुरानी हो सकती हैं', 'Kurs mungkin sudah usang');
  String goldTapMessage(String market, String unit, String price) => _t(
        '$market · $unit · $price · indicative only',
        '$market · $unit · $price · 仅供参考',
        '$market · $unit · $price · إرشادي فقط',
        '$market · $unit · $price · केवल संकेत',
        '$market · $unit · $price · hanya indikatif',
      );

  // Convert
  String get convertTitle => _t('Convert', '换算', 'تحويل', 'रूपांतरण', 'Konversi');
  String get fromLabel => _t('FROM', '从', 'من', 'से', 'DARI');
  String get toLabel => _t('TO', '到', 'إلى', 'को', 'KE');
  String get fromCurrency => _t('From currency', '源货币', 'عملة المصدر', 'स्रोत मुद्रा', 'Mata uang asal');
  String get toCurrency => _t('To currency', '目标货币', 'عملة الهدف', 'लक्ष्य मुद्रा', 'Mata uang tujuan');
  String get selectCurrency => _t('Select currency', '选择货币', 'اختر العملة', 'मुद्रा चुनें', 'Pilih mata uang');
  String get searchCurrency => _t('Search code or name', '搜索代码或名称', 'ابحث بالرمز أو الاسم', 'कोड या नाम खोजें', 'Cari kode atau nama');
  String get noCurrenciesFound => _t('No currencies found', '未找到货币', 'لم يتم العثور على عملات', 'कोई मुद्रा नहीं मिली', 'Mata uang tidak ditemukan');
  String get ratesUnavailable => _t('Rates unavailable', '汇率不可用', 'الأسعار غير متاحة', 'दरें उपलब्ध नहीं', 'Kurs tidak tersedia');
  String get ratesUnavailableHint => _t(
        'Connect to sync or open Board to load saved rates',
        '请联网同步或在看板加载已保存汇率',
        'اتصل للمزامنة أو افتح اللوحة',
        'सिंक करें या बोर्ड खोलें',
        'Sinkronkan atau buka Papan',
      );
  String get enterValidAmount => _t('Enter a valid amount', '请输入有效金额', 'أدخل مبلغاً صالحاً', 'वैध राशि दर्ज करें', 'Masukkan jumlah valid');
  String rateUnavailableFor(String from, String to) => _t(
        'Rate unavailable for $from → $to',
        '$from → $to 汇率不可用',
        'السعر غير متاح لـ $from → $to',
        '$from → $to के लिए दर उपलब्ध नहीं',
        'Kurs tidak tersedia untuk $from → $to',
      );
  String get indicativeOnly => _t(
        'Indicative only · Not a bank quote',
        '仅供参考 · 非银行报价',
        'إرشادي فقط · ليس عرض بنك',
        'केवल संकेत · बैंक कोट नहीं',
        'Hanya indikatif · Bukan kutipan bank',
      );
  String get copyResult => _t('Copy result', '复制结果', 'نسخ النتيجة', 'परिणाम कॉपी करें', 'Salin hasil');
  String get copiedToClipboard => _t('Copied to clipboard', '已复制到剪贴板', 'تم النسخ', 'क्लिपबोर्ड पर कॉपी', 'Disalin');

  // Settings
  String get settingsTitle => _t('Settings', '设置', 'الإعدادات', 'सेटिंग्स', 'Pengaturan');
  String get preferences => _t('PREFERENCES', '偏好', 'التفضيلات', 'प्राथमिकताएँ', 'PREFERENSI');
  String get dataSection => _t('DATA', '数据', 'البيانات', 'डेटा', 'DATA');
  String get languageSetting => _t('Language', '语言', 'اللغة', 'भाषा', 'Bahasa');
  String get baseCurrency => _t('Base currency', '基准货币', 'العملة الأساسية', 'आधार मुद्रा', 'Mata uang dasar');
  String get manageFavorites => _t('Manage favorites', '管理收藏', 'إدارة المفضلة', 'पसंदीदा प्रबंधित करें', 'Kelola favorit');
  String get syncNow => _t('Sync now', '立即同步', 'مزامنة الآن', 'अभी सिंक करें', 'Sinkronkan');
  String get lastSync => _t('Last sync', '上次同步', 'آخر مزامنة', 'अंतिम सिंक', 'Sinkron terakhir');
  String get brandSlogan => _t(
        'Rates & gold. Offline when it matters.',
        '汇率与金价，离线也可靠。',
        'أسعار وذهب. دون اتصال عند الحاجة.',
        'दरें और सोना। ऑफलाइन भी काम आए.',
        'Kurs & emas. Offline saat penting.',
      );
  String get aboutSection => _t('ABOUT', '关于', 'حول', 'के बारे में', 'TENTANG');
  String get privacyPolicy => _t('Privacy policy', '隐私政策', 'سياسة الخصوصية', 'गोपनीयता नीति', 'Kebijakan privasi');
  String get dataSourcesDisclaimer =>
      _t('Data sources & disclaimer', '数据来源与免责声明', 'مصادر البيانات وإخلاء المسؤولية', 'डेटा स्रोत और अस्वीकरण', 'Sumber data & disclaimer');
  String versionLabel(String version) => _t(
        'Version $version',
        '版本 $version',
        'الإصدار $version',
        'संस्करण $version',
        'Versi $version',
      );
  String get disclaimerTitle =>
      _t('Disclaimer', '免责声明', 'إخلاء مسؤولية', 'अस्वीकरण', 'Disclaimer');
  String get disclaimerBody => _t(
        'Exchange rates and gold prices are for general information only. They are not investment advice, bank quotes, remittance rates, or offers to buy or sell gold or currency. Always confirm with your bank or jeweller before transacting.\n\nSources: FX from Frankfurter (ECB reference data). Gold from bundled reference data updated at sync time.',
        '汇率与金价仅供参考，非投资建议、银行报价或汇款汇率，亦不构成买卖黄金或外币要约。交易前请向银行或金店确认。\n\n数据来源：Frankfurter（欧洲央行参考汇率）；金价来自同步时更新的内置参考数据。',
        'أسعار الصرف والذهب للمعلومات العامة فقط. ليست نصيحة استثمارية ولا عروض بنكية أو حوالات. أكّد مع بنكك أو goldsmith قبل التعامل.\n\nالمصادر: Frankfurter (ECB). الذهب من بيانات مرجعية مدمجة.',
        'विनिमय दर और सोने की कीमतें केवल सामान्य जानकारी हैं। निवेश सलाह, बैंक कोट या remittance दर नहीं। लेनदेन से पहले बैंक/ज्वैलर से पुष्टि करें।\n\nस्रोत: Frankfurter (ECB)। सोना: सिंक पर अपडेट bundled डेटा।',
        'Kurs dan harga emas hanya untuk informasi umum. Bukan saran investasi, kutipan bank, atau kurs remitansi. Konfirmasi ke bank/tokok emas sebelum transaksi.\n\nSumber: Frankfurter (ECB). Emas: data referensi bundled saat sinkron.',
      );
  String get privacyLinkFailed => _t(
        'Could not open privacy policy',
        '无法打开隐私政策',
        'تعذر فتح سياسة الخصوصية',
        'गोपनीयता नीति नहीं खुल सकी',
        'Tidak dapat membuka kebijakan privasi',
      );
  String baseCurrencySet(String code) => _t(
        'Base currency set to $code',
        '基准货币已设为 $code',
        'تم تعيين العملة الأساسية إلى $code',
        'आधार मुद्रा $code पर सेट',
        'Mata uang dasar: $code',
      );

  // Favorites
  String get manageFavoritesTitle => _t('Manage favorites', '管理收藏', 'إدارة المفضلة', 'पसंदीदा', 'Kelola favorit');
  String get done => _t('Done', '完成', 'تم', 'हो गया', 'Selesai');
  String favoritesCount(int current, int max) => _t(
        '$current/$max on your board',
        '看板 $current/$max',
        '$current/$max على لوحتك',
        'बोर्ड पर $current/$max',
        '$current/$max di papan',
      );
  String get addCurrencySection => _t('ADD CURRENCY', '添加货币', 'إضافة عملة', 'मुद्रा जोड़ें', 'TAMBAH MATA UANG');
  String get searchToAdd => _t('Search to add', '搜索添加', 'ابحث للإضافة', 'जोड़ने के लिए खोजें', 'Cari untuk menambah');
  String get allCurrenciesAdded => _t('All currencies added', '已添加全部货币', 'تمت إضافة كل العملات', 'सभी मुद्राएँ जोड़ी गईं', 'Semua mata uang ditambahkan');
  String get noMatches => _t('No matches', '无匹配', 'لا توجد نتائج', 'कोई मेल नहीं', 'Tidak ada cocok');
  String get keepOneFavorite => _t('Keep at least one favorite', '至少保留一个收藏', 'احتفظ بمفضلة واحدة على الأقل', 'कम से कम एक पसंदीदा रखें', 'Simpan minimal satu favorit');
  String maxFavoritesMessage(int max) => _t(
        'Maximum $max favorites',
        '最多 $max 个收藏',
        'الحد الأقصى $max مفضلة',
        'अधिकतम $max पसंदीदा',
        'Maksimal $max favorit',
      );

  // Sync messages
  String get syncSuccess => _t('Rates updated', '汇率已更新', 'تم تحديث الأسعار', 'दरें अपडेट', 'Kurs diperbarui');
  String get syncThrottled => _t(
        'Updated recently — try again in 15 min',
        '刚刚更新过 — 15 分钟后再试',
        'تم التحديث مؤخراً — حاول بعد 15 دقيقة',
        'हाल में अपडेट — 15 मिनट बाद',
        'Baru diperbarui — coba lagi 15 menit',
      );
  String get syncOffline => _t(
        'Offline · showing saved rates',
        '离线 · 显示已保存汇率',
        'دون اتصال · عرض الأسعار المحفوظة',
        'ऑफलाइन · सहेजी दरें',
        'Offline · kurs tersimpan',
      );
  String get syncFailed => _t(
        'Sync failed · showing saved rates',
        '同步失败 · 显示已保存汇率',
        'فشلت المزامنة · عرض المحفوظ',
        'सिंक विफल · सहेजी दरें',
        'Sinkron gagal · kurs tersimpan',
      );

  // First sync
  String get firstSyncTitle => _t(
        'Syncing rates for the first time…',
        '首次同步汇率中…',
        'مزامنة الأسعار لأول مرة…',
        'पहली बार सिंक हो रहा है…',
        'Sinkronisasi pertama…',
      );
  String get firstSyncHint => _t(
        'Or use bundled data if offline',
        '离线时将使用内置数据',
        'أو استخدم البيانات المدمجة دون اتصال',
        'ऑफलाइन हो तो बंडल डेटा',
        'Atau data bundled jika offline',
      );

  // Sync status bar
  String syncStatusLabel(SyncStatus status) {
    final time = _formatStatusTime(status.lastUpdated);
    return switch (status.connection) {
      SyncConnectionState.online when status.isStale => _t(
          'Online · Updated $time · may be outdated',
          '在线 · 更新于 $time · 可能已过期',
          'متصل · محدّث $time · قديم',
          'ऑनलाइन · $time · पुराना',
          'Online · $time · mungkin usang',
        ),
      SyncConnectionState.online => _t(
          'Online · Updated $time ${status.timezoneLabel}',
          '在线 · 更新于 $time ${status.timezoneLabel}',
          'متصل · محدّث $time',
          'ऑनलाइन · $time',
          'Online · $time',
        ),
      SyncConnectionState.offline => _t(
          'Offline · Rates as of $time',
          '离线 · 汇率截至 $time',
          'دون اتصال · أسعار $time',
          'ऑफलाइन · दरें $time तक',
          'Offline · kurs per $time',
        ),
      SyncConnectionState.syncFailed => syncFailed,
    };
  }

  String lastSyncLabel(DateTime? time) {
    if (time == null) {
      return _t('Never', '从未', 'أبداً', 'कभी नहीं', 'Belum pernah');
    }
    final local = time.toLocal();
    final now = DateTime.now();
    final hm = _formatHm(local);
    if (_isSameDay(local, now)) {
      return _t('Today $hm', '今天 $hm', 'اليوم $hm', 'आज $hm', 'Hari ini $hm');
    }
    if (_isSameDay(local, now.subtract(const Duration(days: 1)))) {
      return _t('Yesterday $hm', '昨天 $hm', 'أمس $hm', 'कल $hm', 'Kemarin $hm');
    }
    return _formatDateTime(local);
  }

  String asOfLabel(DateTime? time) {
    if (time == null) {
      return _t('Rate unavailable', '汇率不可用', 'السعر غير متاح', 'दर उपलब्ध नहीं', 'Kurs tidak tersedia');
    }
    return _t(
      'As of ${lastSyncLabel(time)}',
      '截至 ${lastSyncLabel(time)}',
      'اعتباراً من ${lastSyncLabel(time)}',
      '${lastSyncLabel(time)} तक',
      'Per ${lastSyncLabel(time)}',
    );
  }

  String syncResultMessage(SyncResult result) => switch (result) {
        SyncResult.success => syncSuccess,
        SyncResult.throttled => syncThrottled,
        SyncResult.offline => syncOffline,
        SyncResult.failed => syncFailed,
      };

  String _t(String en, String zh, String ar, String hi, String id) {
    return switch (language) {
      AppLanguage.en => en,
      AppLanguage.zh => zh,
      AppLanguage.ar => ar,
      AppLanguage.hi => hi,
      AppLanguage.id => id,
    };
  }

  String _formatHm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatStatusTime(DateTime dt) {
    const monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthsZh = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    final local = dt.toLocal();
    final hm = _formatHm(local);
    return switch (language) {
      AppLanguage.zh => '${local.day}${monthsZh[local.month - 1]} $hm',
      _ => '${local.day} ${monthsEn[local.month - 1]} $hm',
    };
  }

  String _formatDateTime(DateTime local) {
    const monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hm = _formatHm(local);
    if (language == AppLanguage.zh) {
      return '${local.year}年${local.month}月${local.day}日 · $hm';
    }
    return '${local.day} ${monthsEn[local.month - 1]} ${local.year} · $hm';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

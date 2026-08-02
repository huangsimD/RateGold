import 'package:rategold/l10n/app_language.dart';

abstract final class CurrencyNames {
  static const codes = [
    'USD', 'CNY', 'AED', 'PHP', 'INR', 'IDR', 'SAR', 'EUR', 'GBP', 'SGD',
    'MYR', 'THB', 'BDT', 'PKR', 'NPR', 'LKR',
  ];

  static String name(String code, AppLanguage language) {
    final map = switch (language) {
      AppLanguage.en => _en,
      AppLanguage.zh => _zh,
      AppLanguage.ar => _ar,
      AppLanguage.hi => _hi,
      AppLanguage.id => _id,
    };
    return map[code] ?? code;
  }

  static const _en = {
    'USD': 'US Dollar',
    'CNY': 'Chinese Yuan',
    'AED': 'UAE Dirham',
    'PHP': 'Philippine Peso',
    'INR': 'Indian Rupee',
    'IDR': 'Indonesian Rupiah',
    'SAR': 'Saudi Riyal',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'SGD': 'Singapore Dollar',
    'MYR': 'Malaysian Ringgit',
    'THB': 'Thai Baht',
    'BDT': 'Bangladeshi Taka',
    'PKR': 'Pakistani Rupee',
    'NPR': 'Nepalese Rupee',
    'LKR': 'Sri Lankan Rupee',
  };

  static const _zh = {
    'USD': '美元',
    'CNY': '人民币',
    'AED': '阿联酋迪拉姆',
    'PHP': '菲律宾比索',
    'INR': '印度卢比',
    'IDR': '印尼盾',
    'SAR': '沙特里亚尔',
    'EUR': '欧元',
    'GBP': '英镑',
    'SGD': '新加坡元',
    'MYR': '马来西亚林吉特',
    'THB': '泰铢',
    'BDT': '孟加拉塔卡',
    'PKR': '巴基斯坦卢比',
    'NPR': '尼泊尔卢比',
    'LKR': '斯里兰卡卢比',
  };

  static const _ar = {
    'USD': 'دولار أمريكي',
    'CNY': 'يوان صيني',
    'AED': 'درهم إماراتي',
    'PHP': 'بيسو فلبيني',
    'INR': 'روبية هندية',
    'IDR': 'روبية إندونيسية',
    'SAR': 'ريال سعودي',
    'EUR': 'يورو',
    'GBP': 'جنيه إسترليني',
    'SGD': 'دولار سنغافوري',
    'MYR': 'رينغيت ماليزي',
    'THB': 'بات تايلندي',
    'BDT': 'تاка بنغلاديشي',
    'PKR': 'روبية باكستانية',
    'NPR': 'روبية نيبالية',
    'LKR': 'روبية سريلانكية',
  };

  static const _hi = {
    'USD': 'अमेरिकी डॉलर',
    'CNY': 'चीनी युआन',
    'AED': 'संयुक्त अरब अमीरात दिर्हाम',
    'PHP': 'फिलीपino peso',
    'INR': 'भारतीय रुपया',
    'IDR': 'इंडोनेशियाई रुपिया',
    'SAR': 'सऊदी रियाल',
    'EUR': 'यूरो',
    'GBP': 'ब्रिटिश पाउंड',
    'SGD': 'सिंगापुर डॉलर',
    'MYR': 'मलेशियाई रिंगgit',
    'THB': 'थाई baht',
    'BDT': 'बांग्लादेशी taka',
    'PKR': 'पाकिस्तानी रुपया',
    'NPR': 'नेपाली रुपया',
    'LKR': 'श्रीलंkai rupee',
  };

  static const _id = {
    'USD': 'Dolar AS',
    'CNY': 'Yuan Tiongkok',
    'AED': 'Dirham UEA',
    'PHP': 'Peso Filipina',
    'INR': 'Rupee India',
    'IDR': 'Rupiah Indonesia',
    'SAR': 'Riyal Saudi',
    'EUR': 'Euro',
    'GBP': 'Pound Sterling',
    'SGD': 'Dolar Singapura',
    'MYR': 'Ringgit Malaysia',
    'THB': 'Baht Thailand',
    'BDT': 'Taka Bangladesh',
    'PKR': 'Rupee Pakistan',
    'NPR': 'Rupee Nepal',
    'LKR': 'Rupee Sri Lanka',
  };
}

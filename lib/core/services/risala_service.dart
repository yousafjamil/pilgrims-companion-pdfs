import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class RisalaService {
  static final RisalaService _instance = RisalaService._internal();
  factory RisalaService() => _instance;
  RisalaService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(minutes: 5),
    receiveTimeout: const Duration(minutes: 10),
    sendTimeout: const Duration(minutes: 5),
    followRedirects: true,
    maxRedirects: 15,
    validateStatus: (s) => s != null && s < 500,
    headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) '
          'AppleWebKit/605.1.15 (KHTML, like Gecko) '
          'Mobile/15E148',
      'Accept': 'application/pdf,application/octet-stream,*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Referer': 'https://risala.prh.gov.sa/',
    },
  ));

  CancelToken? _cancelToken;

  // ── BOOKS DATA: 563 PDFs across 52 languages ──────
  static const Map<String, List<RisalaBook>> booksByLanguage = {
  // ── English (en) ── 21 books ──────────────────────────
  'en': [
    RisalaBook(id: '114_en', title: 'Explanation and Clarification of Numerous Issues about Hajj,', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/114/en-attahqiq_walidoh_2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/114'),
    RisalaBook(id: '117_en', title: 'Manner of Performing ‘Umrah', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/117/en_sifat-umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/117'),
    RisalaBook(id: '81_en', title: 'A Glimpse into the Islamic Creed (Explanation of', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/81/en-nubzah_fil_aqidah-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/81'),
    RisalaBook(id: '118_en', title: 'The Prophet\'s Manner of Prayer (May Allah\'s peace', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/118/en-kaifiyah_solat-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/118'),
    RisalaBook(id: '940_en', title: 'How to do Umrah', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/940/en_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/940'),
    RisalaBook(id: '382_en', title: 'The Three Fundamental Principles of Islam and Their', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/382/en_thalathauthool.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/382'),
    RisalaBook(id: '612_en', title: 'Rulings on Sacrificial Animals, Offerings, and Slaughtering', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/612/en-ahkam_hadyi-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/612'),
    RisalaBook(id: '115_en', title: 'The Important Lessons for the General Ummah', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/115/en-addurus_almuhimmah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/115'),
    RisalaBook(id: '511_en', title: 'What A Muslim Must Know', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/511/en_malaa_yasaa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/511'),
    RisalaBook(id: '553_en', title: 'A Treatise on Women’s Natural Types of Bleeding', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/553/en-risalah_fi_dima-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/553'),
    RisalaBook(id: '646_en', title: 'Merit of the First Ten Days of Dhul-Hijjah', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/646/EN_fadhlu_ashr_dhilhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/646'),
    RisalaBook(id: '398_en', title: 'The Sound Creed and What is Contrary to', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/398/en-aqidah_sohihah-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/398'),
    RisalaBook(id: '108_en', title: 'The Beneficial Means To A Happy Life', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/108/en-alwasail_almufidah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/108'),
    RisalaBook(id: '499_en', title: 'The Messenger of Islam, Muhammad (may Allah’s peace', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/499/en_rasulislam-v1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/499'),
    RisalaBook(id: '483_en', title: 'The Sound Creed', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/483/en_alaqida_alhsahihah_new.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/483'),
    RisalaBook(id: '397_en', title: 'Safeguarding Tawhīd (monotheism)', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/397/en-hirasah_tauhid-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/397'),
    RisalaBook(id: '401_en', title: 'The ruling on magic and divination and related', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/401/en-hukm_sihr-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/401'),
    RisalaBook(id: '257_en', title: 'Two Concise Treatises on Zakah and Fasting', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/257/en-risalatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/257'),
    RisalaBook(id: '187_en', title: 'fasting ramadan', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/187/en_fast.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/187'),
    RisalaBook(id: '415_en', title: 'Some Rulings on Fasting', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/415/en_minahkam_assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/415'),
    RisalaBook(id: '572_en', title: 'Who created the universe? And who created me?', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/572/en-man_kholaqo-alkaun-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/572'),
  ],

  // ── Arabic (ar) ── 44 books ──────────────────────────
  'ar': [
    RisalaBook(id: '209_ar', title: 'التحقيق والإيضاح لكثير من مسائل الحج والعمرة والزيارة', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/209/ar-attahqiq_walidoh-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/209'),
    RisalaBook(id: '63_ar', title: 'صفة العمرة', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/63/ar-sifat_umrah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/63'),
    RisalaBook(id: '749_ar', title: 'فضائل وآداب المسجد النبوي وأحكام زيارة قبر النبي', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/749/ar-fadail_adab_masjid_nabawi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/749'),
    RisalaBook(id: '779_ar', title: 'صفة الحج', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/779/ar_sifat_alhajj_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/779'),
    RisalaBook(id: '381_ar', title: 'نبذة في العقيدة الإسلامية [ شرح أصول الإيمان', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/381/ar-nubzah_fil_aqidah-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/381'),
    RisalaBook(id: '106_ar', title: 'كيفية صلاة النبي ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/106/ar-kaifiyah_solat_nabi-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/106'),
    RisalaBook(id: '780_ar', title: 'صفة العمرة', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/780/ar_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/780'),
    RisalaBook(id: '66_ar', title: 'صفة الحج والعمرة والزيارة ويلية من جوامع الدعاء', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/66/ar_sifat_alhajj_wa_doaa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/66'),
    RisalaBook(id: '65_ar', title: 'الحج خطوة بخطوة', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/65/ar_alhajj_khatwoah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/65'),
    RisalaBook(id: '489_ar', title: 'ثلاثة الأصول وأدلتها', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/489/ar-tsalatsatul_usul-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/489'),
    RisalaBook(id: '244_ar', title: 'أحكام الهدي والأضاحي والتذكية', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/244/ar_ahkamhadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/244'),
    RisalaBook(id: '247_ar', title: 'الدروس المهمة لعامة الأمة', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/247/ar-addurus_almuhimmah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/247'),
    RisalaBook(id: '246_ar', title: 'تلخيص كتاب أحكام الأضحية والذكاة', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/246/ar_ahkam-udhiyah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/246'),
    RisalaBook(id: '70_ar', title: 'الدعاء من الكتاب والسنة', description: '', category: 'Supplications', icon: '📿', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/70/ar_aldoaa_mn_alkitab.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/70'),
    RisalaBook(id: '208_ar', title: 'الدعاء ويليه العلاج بالرقى من الكتاب والسنة', description: '', category: 'Supplications', icon: '📿', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/208/ar_addua.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/208'),
    RisalaBook(id: '767_ar', title: 'الدعاء المستطاب عند ختم آيات الكتاب', description: '', category: 'Supplications', icon: '📿', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/767/ar_aldoaa_almostab.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/767'),
    RisalaBook(id: '770_ar', title: 'الدعاء', description: '', category: 'Supplications', icon: '📿', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/770/ar_aldoaa_haramain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/770'),
    RisalaBook(id: '251_ar', title: 'ما لا يسع المسلم جهله', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/251/ar-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/251'),
    RisalaBook(id: '766_ar', title: 'أذكار المسلم', description: '', category: 'Supplications', icon: '📿', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/766/ar_azkar_almuslim.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/766'),
    RisalaBook(id: '265_ar', title: 'المنهج لمريد العمرة والحج', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/265/ar_manhajlimurid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/265'),
    RisalaBook(id: '342_ar', title: 'رسالة في الدماء الطبيعية للنساء', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/342/ar-risalah_fi_dima-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/342'),
    RisalaBook(id: '245_ar', title: 'فضل عشر ذي الحجة', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/245/ar_fadlashrzulhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/245'),
    RisalaBook(id: '227_ar', title: 'أخطاء يرتكبها بعض الحجاج', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/227/ar_akhta-hujjaj.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/227'),
    RisalaBook(id: '67_ar', title: 'الإبهاج في أحكام المعتمر والزائر والحاج', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/67/ar_alebhajj.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/67'),
    RisalaBook(id: '1_ar', title: 'رسالة موجزة عن الإسلام كما جاء في القرآن', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/1/ar-risalah_mujazah_mushtamilah-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/1'),
    RisalaBook(id: '324_ar', title: 'مختصر صفة صلاة العيدين', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/324/ar_sifatsolateid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/324'),
    RisalaBook(id: '234_ar', title: 'العقيدة الصحيحة وما يضادها', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/234/ar_alakedah_alsaheha.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/234'),
    RisalaBook(id: '57_ar', title: 'الوسائل المفيدة للحياة السعيدة', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/57/ar_alwasail-almufidah_2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/57'),
    RisalaBook(id: '51_ar', title: 'حصن المسلم من أذكار الكتاب والسنة', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/51/ar_hisnulmuslim.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/51'),
    RisalaBook(id: '481_ar', title: 'العقيدة الصحيحة', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/481/ar-aqidah_sohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/481'),
    RisalaBook(id: '482_ar', title: 'أحكام الجنائز', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/482/ar_ahkamjanaiz.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/482'),
    RisalaBook(id: '262_ar', title: 'من الأحكام الفقهية في الطهارة والصلاة والجنائز', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/262/ar_min-ahkam-toharah-solat_2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/262'),
    RisalaBook(id: '107_ar', title: 'حراسة التوحيد', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/107/ar-hirasah_tauhid-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/107'),
    RisalaBook(id: '781_ar', title: 'عقيدة المسلم', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/781/ar_akidat_almuslim.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/781'),
    RisalaBook(id: '236_ar', title: 'حكم السحر والكهانة وما يتعلق بها', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/236/ar_hokm_alsahr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/236'),
    RisalaBook(id: '174_ar', title: 'رسالتان موجزتان في الزكاة والصيام', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/174/ar-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/174'),
    RisalaBook(id: '762_ar', title: 'أحكام الطهارة والصلاة', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/762/ar_a7kam_altaharah_wa_alsalah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/762'),
    RisalaBook(id: '176_ar', title: 'الصيام', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/176/ar_fast.PDF', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/176'),
    RisalaBook(id: '252_ar', title: 'من أحكام الصيام', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/252/ar_minahkamsiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/252'),
    RisalaBook(id: '351_ar', title: 'الصيام ومجموعة أسئلة في أحكامه', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/351/ar_assiyam-wa-ahkamih.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/351'),
    RisalaBook(id: '758_ar', title: 'أحكام الزكاة والصيام', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/758/ar_a7kam_alzakah_wa_alsayam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/758'),
    RisalaBook(id: '777_ar', title: 'دليل زكاة الفطر', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/777/ar_dalel_zakat_alfirt.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/777'),
    RisalaBook(id: '775_ar', title: 'دليل المعتكف', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/775/ar_dalel_almo3takef.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/775'),
    RisalaBook(id: '214_ar', title: 'المختصر في أحكام زكاة الفطر وصلاة العيد', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/214/ar_ahkam_zakat_alfitr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/214'),
  ],

  // ── Urdu (ur) ── 23 books ──────────────────────────
  'ur': [
    RisalaBook(id: '178_ur', title: 'حج وعمرہ اور زیارت کے بہت سے مسائل', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/178/ur_tahqiq_waliidohv3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/178'),
    RisalaBook(id: '112_ur', title: 'عمرہ کا طریقہ', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/112/ur_sifat-umrah_v2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/112'),
    RisalaBook(id: '48_ur', title: 'اسلامى عقيده كا مختصر تعارف  (شرح اصولِ ایمان)', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/48/ur-nubzah_fil_aqidah-1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/48'),
    RisalaBook(id: '113_ur', title: 'نبی صلى الله عليه وسلم کی نماز کا', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/113/ur_kaifiyah-solat_v2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/113'),
    RisalaBook(id: '933_ur', title: 'عمرے کا طریقہ', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/933/ur_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/933'),
    RisalaBook(id: '43_ur', title: 'تین بنیادی باتیں اور ان کے دلائل', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/43/ur-tsalatsatul_usul-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/43'),
    RisalaBook(id: '577_ur', title: 'ہدِی، قربانی اور ذبح کے احکام', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/577/ur-ahkam_hadyi-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/577'),
    RisalaBook(id: '60_ur', title: 'عام مسلمانوں کے لیے اہم اسباق', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/60/ur_addurus-almuhimmah_2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/60'),
    RisalaBook(id: '316_ur', title: 'کتاب [قربانی اورجانور کے احکام ومسائل] کا خلاصہ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/316/ur_talkhisahkmadhiah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/316'),
    RisalaBook(id: '345_ur', title: 'دعا اور رُقیہ کے ذریعہ علاج کتاب وسنت', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/345/ur_duawailaj.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/345'),
    RisalaBook(id: '510_ur', title: 'وہ بنیادی باتیں جن سے لاعلم رہنا کسی', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/510/ur-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/510'),
    RisalaBook(id: '552_ur', title: 'عورتوں کے طبعی خون کے احکام', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/552/ur-risalah_fi_dima-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/552'),
    RisalaBook(id: '642_ur', title: 'عشرۂ ذی الحجہ کی فضیلت', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/642/ur-fadl_ashr_zulhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/642'),
    RisalaBook(id: '268_ur', title: 'بعض حجاج کرام سے سرزد ہونے والی غلطیاں', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/268/ur_akhtayartakibuha.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/268'),
    RisalaBook(id: '264_ur', title: 'صحیح عقیدہ اور اس کے منافی امور', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/264/ur-aqidah_sohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/264'),
    RisalaBook(id: '86_ur', title: 'خوشگوار زندگی کے مفید وسائل', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/86/ur-alwasail_almufidah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/86'),
    RisalaBook(id: '42_ur', title: 'رسولِ اسلام محمدﷺ', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/42/ur-rasul_islam-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/42'),
    RisalaBook(id: '173_ur', title: 'حفاظتِ توحيد', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/173/ur-hirasah_tauhid-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/173'),
    RisalaBook(id: '669_ur', title: 'جادو، کہانت اور اس سے متعلق امور کا', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/669/ur-hukm_sihr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/669'),
    RisalaBook(id: '211_ur', title: 'زکوٰۃ اور روزے سے متعلق دو مختصر رسائل', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/211/ur-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/211'),
    RisalaBook(id: '191_ur', title: 'روزے کے احکام', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/191/ur_fast.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/191'),
    RisalaBook(id: '231_ur', title: 'روزے کے بعض احکام', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/231/ur-min_ahkam_siyam-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/231'),
    RisalaBook(id: '80_ur', title: 'کائنات کو کس نے بنایا؟ مجھے کس نے', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/80/ur-man_kholaqo_alkaun-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/80'),
  ],

  // ── Indonesian (id) ── 23 books ──────────────────────────
  'id': [
    RisalaBook(id: '120_id', title: 'Panduan Praktis Tentang Haji, Umrah, dan Ziarah Berdasarkan', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/120/id-attahqiq_walidoh_.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/120'),
    RisalaBook(id: '165_id', title: 'TATA CARA UMRAH', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/165/id-sifat_umrah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/165'),
    RisalaBook(id: '539_id', title: 'RINGKASAN AKIDAH ISLAM', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/539/id-nubzah_fil_aqidah-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/539'),
    RisalaBook(id: '166_id', title: 'TATA CARA SALAT NABI ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/166/id-kaifiyah_solat_nabi-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/166'),
    RisalaBook(id: '941_id', title: 'TATA CARA UMRAH', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/941/id_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/941'),
    RisalaBook(id: '175_id', title: 'TIGA ASAS AGAMA BESERTA DALILNYA', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/175/id-tsalatsatul_usul-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/175'),
    RisalaBook(id: '276_id', title: 'HUKUM-HUKUM TERKAIT HADYU, KURBAN, DAN PENYEMBELIHAN', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/276/id_ahkam-hadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/276'),
    RisalaBook(id: '119_id', title: 'PELAJARAN PENTING BAGI SETIAP MUSLIM', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/119/id-addurus_almuhimmah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/119'),
    RisalaBook(id: '340_id', title: 'KUMPULAN DOA SERTA PENGOBATAN DAN RUQYAH DARI AL-QURAN', description: '', category: 'Supplications', icon: '📿', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/340/id_duawailaj.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/340'),
    RisalaBook(id: '116_id', title: 'HAL-HAL YANG WAJIB DIKETAHUI SEORANG MUSLIM', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/116/id-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/116'),
    RisalaBook(id: '25_id', title: 'AKU SEORANG MUSLIM', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/25/id-ana_muslim-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/25'),
    RisalaBook(id: '570_id', title: 'DARAH KEBIASAAN WANITA', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/570/id_risalah_fidimaa_attobiiyyah_v3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/570'),
    RisalaBook(id: '277_id', title: 'KEUTAMAAN SEPULUH HARI PERTAMA ZULHIJAH', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/277/id-fadl_ashr_zulhijjah-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/277'),
    RisalaBook(id: '328_id', title: 'AKIDAH YANG BENAR VERSUS AKIDAH BATIL', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/328/id_alaqeedah_assohihah_v4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/328'),
    RisalaBook(id: '190_id', title: 'PETUNJUK PRAKTIS HIDUP BAHAGIA', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/190/id-alwasail_almufidah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/190'),
    RisalaBook(id: '437_id', title: 'Akidah Yang Benar', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/437/id_alaqida_alhsahihah_new.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/437'),
    RisalaBook(id: '500_id', title: 'Rasul Islam Muhammad Ṣallallāhu \'Alaihi wa Sallam', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/500/id-rasul_islam-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/500'),
    RisalaBook(id: '186_id', title: 'MENJAGA KEMURNIAN TAUHID', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/186/id_menjaga_kemurnian_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/186'),
    RisalaBook(id: '331_id', title: 'HUKUM SIHIR, PERDUKUNAN, DAN HAL-HAL YANG BERKAITAN DENGANNYA', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/331/id_hukum_sihir_walkahanah_v4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/331'),
    RisalaBook(id: '201_id', title: 'DUA RISALAH RINGKAS TERKAIT ZAKAT DAN PUASA', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/201/id-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/201'),
    RisalaBook(id: '188_id', title: 'PUASA', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/188/id_fast.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/188'),
    RisalaBook(id: '215_id', title: 'BEBERAPA HUKUM  TERKAIT PUASA', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/215/id_minahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/215'),
    RisalaBook(id: '540_id', title: 'SIAPA YANG MENCIPTAKAN ALAM SEMESTA? SIAPA YANG MENCIPTAKANKU?', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/540/id_mankhalakakaun_v2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/540'),
  ],

  // ── Turkish (tr) ── 16 books ──────────────────────────
  'tr': [
    RisalaBook(id: '213_tr', title: 'Umre Rehberi', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/213/tr-sifat_umrah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/213'),
    RisalaBook(id: '795_tr', title: 'İslâm Akidesinin Temel İlkeleri', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/795/tr-nubzah_fil_aqidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/795'),
    RisalaBook(id: '210_tr', title: 'Peygamber Efendimiz -sallallahu aleyhi ve sellem-\'in Namaz Kılma', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/210/tr-kaifiyah_solat_nabi-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/210'),
    RisalaBook(id: '936_tr', title: 'Umre’nin Yapılış Şekli', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/936/tr_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/936'),
    RisalaBook(id: '858_tr', title: 'MÜSLÜMANIN KESİN OLARAK BİLMESİ GEREKEN KONULAR', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/858/tr-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/858'),
    RisalaBook(id: '620_tr', title: 'Ben Müslümanım', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/620/tr-ana_muslim-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/620'),
    RisalaBook(id: '610_tr', title: 'HANIMLARA MAHSUS ÖZEL HALLER İLMİHALİ', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/610/tr-risalah_fi_dima-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/610'),
    RisalaBook(id: '346_tr', title: 'ZİLHİCCE AYININ İLK ON  GÜNÜNÜN FAZİLETİ', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/346/tr_fadhlu_ashri_dhilhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/346'),
    RisalaBook(id: '99_tr', title: 'Doğru İnanç ve Ona Aykırı Olan Şeyler', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/99/tr_alaqeedah_assohihah_v4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/99'),
    RisalaBook(id: '54_tr', title: 'Mutlu Bir Hayat İçin Faydalı Yollar', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/54/tr-alwasail_almufidah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/54'),
    RisalaBook(id: '87_tr', title: 'İslâm\'ın peygamberi Muhammed sallallahu aleyhi ve sellem', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/87/tr-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/87'),
    RisalaBook(id: '739_tr', title: 'Tevhidin Korunması', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/739/tr_hirasah_tawhidv4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/739'),
    RisalaBook(id: '742_tr', title: 'Büyü, Kâhinlik ve Bunlarla İlgili Hususların Hükmü', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/742/tr_hukmu_assihri_walkahanah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/742'),
    RisalaBook(id: '475_tr', title: 'Zekât ve Oruç Hakkında Veciz İki Risale', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/475/tr-risalatan_mujizatan.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/475'),
    RisalaBook(id: '206_tr', title: 'Oruç', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/206/tr_Oruc.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/206'),
    RisalaBook(id: '811_tr', title: 'Oruca Dair Bazı Hükümler', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/811/tr-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/811'),
  ],

  // ── French (fr) ── 16 books ──────────────────────────
  'fr': [
    RisalaBook(id: '151_fr', title: 'La description de la \'Oumrah', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/151/fr-sifat_umrah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/151'),
    RisalaBook(id: '132_fr', title: 'Comment était la prière du Prophète ﷺ ?', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/132/fr-kaifiyah_solat_nabi-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/132'),
    RisalaBook(id: '946_fr', title: 'Description de la Oumra', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/946/fr_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/946'),
    RisalaBook(id: '154_fr', title: 'Les trois fondements et leurs preuves', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/154/fr-tsalatasatul_usul-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/154'),
    RisalaBook(id: '611_fr', title: 'Décrets concernant le sacrifice (Al Hadyi), les bêtes', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/611/fr-ahkam_hadyi-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/611'),
    RisalaBook(id: '88_fr', title: 'Les leçons importantes pour le commun des musulmans', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/88/fr-addurus_almuhimmah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/88'),
    RisalaBook(id: '75_fr', title: 'Ce qu’il ne convient pas au Musulman d’ignorer', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/75/fr_almuslim_gahluh.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/75'),
    RisalaBook(id: '557_fr', title: 'Épître concernant les sangs naturels des femmes', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/557/fr-risalah_fi_dima-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/557'),
    RisalaBook(id: '715_fr', title: 'La croyance authentique et ce qui s\'y oppose', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/715/fr_alaqeedah_assohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/715'),
    RisalaBook(id: '131_fr', title: 'Les moyens utiles pour une vie bienheureuse', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/131/fr-alwasail_almufidah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/131'),
    RisalaBook(id: '502_fr', title: 'le Messager de l\'Islam Mouḥammad (qu’Allah le couvre', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/502/fr-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/502'),
    RisalaBook(id: '714_fr', title: 'La sauvegarde du tawḥīd', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/714/fr-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/714'),
    RisalaBook(id: '718_fr', title: 'Le jugement sur la sorcellerie, la divination et', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/718/fr_hukum_assihri.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/718'),
    RisalaBook(id: '513_fr', title: 'Deux épîtres concises sur l\'impôt légal purificateur (Az-Zakâh)', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/513/fr-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/513'),
    RisalaBook(id: '818_fr', title: 'Parmi les jugements religieux relatifs au jeûne', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/818/fr_minahkam_Assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/818'),
    RisalaBook(id: '77_fr', title: 'Qui a créé l\'Univers ? Qui m\'a créé', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/77/fr-man_kholaqo_alkaun-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/77'),
  ],

  // ── Bengali (bn) ── 25 books ──────────────────────────
  'bn': [
    RisalaBook(id: '91_bn', title: 'হজ্জ, ‘উমরাহ এবং যিয়ারাতের বিভিন্ন মাসআলা সম্পর্কে কুরআন', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/91/bn-attahqiq_walidoh-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/91'),
    RisalaBook(id: '143_bn', title: 'উমরার বিবরণ', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/143/bn-sifat_umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/143'),
    RisalaBook(id: '509_bn', title: 'ইসলামী আক্বীদার সংক্ষিপ্ত বিবরণ', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/509/bn_nubzahfilaqeedahsaheehah_v1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/509'),
    RisalaBook(id: '123_bn', title: 'নবী সাল্লাল্লাহু ‘আলাইহি ওয়াসাল্লামের সালাত আদায়ের পদ্ধতি', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/123/bn_kaifiyyahsolah_v2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/123'),
    RisalaBook(id: '942_bn', title: 'উমরা আদায়ের পদ্ধতি', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/942/bn_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/942'),
    RisalaBook(id: '156_bn', title: 'তিনটি মূলনীতি ও তার দলীলসমূহ', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/156/bn-tsalatsatul_usul-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/156'),
    RisalaBook(id: '299_bn', title: 'হাদী, কুরবানী ও যবেহ করার বিধি-বিধান', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/299/bn_ahkamhadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/299'),
    RisalaBook(id: '47_bn', title: 'মুসলিম উম্মতের সর্বসাধারণের জন্য গুরুত্বপূর্ণ দার্সসমূহ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/47/bn-addurus_almuhimmah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/47'),
    RisalaBook(id: '549_bn', title: 'কুরবানী ও যবেহ সম্পর্কিত বিধানসম্বলিত কিতাবের সারসংক্ষেপ', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/549/bn_talkhisadhiahwazakat.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/549'),
    RisalaBook(id: '348_bn', title: 'একজন মুসলিমের জন্য যা জানা অত্যাবশ্যকীয়', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/348/bn-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/348'),
    RisalaBook(id: '548_bn', title: 'উমরাহ ও হজে গমনিচ্ছুকদের পথনির্দেশিকা', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/548/bn_almanhajlimuridalumrahwalhaj.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/548'),
    RisalaBook(id: '568_bn', title: 'নারীদের ঋতুস্রাব বিষয়ে একটি সংক্ষিপ্ত পুস্তিকা', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/568/bn-risalah_fi_dima-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/568'),
    RisalaBook(id: '301_bn', title: 'যিলহজের প্রথম দশকের ফযীলত', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/301/bn-fadl_ashr_zulhijjah-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/301'),
    RisalaBook(id: '300_bn', title: 'হাজীদের দ্বারা সংঘটিত কিছু ভুল-ত্রুটি', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/300/bn_akhta-hujjaj.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/300'),
    RisalaBook(id: '530_bn', title: 'বিশুদ্ধ আকিদা এবং এর পরিপন্থী বিষয়সমূহ', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/530/bn-aqidah_sohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/530'),
    RisalaBook(id: '53_bn', title: 'সৌভাগ্যময় জীবনের জন্য উপকারী উপায়সমূহ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/53/bn-alwasail_almufidah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/53'),
    RisalaBook(id: '44_bn', title: 'কুরআন-সুন্নাহ’র যিকির সংবলিত হিসনুল মুসলিম [মুসলিমের দুর্গ]', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/44/bn_hisn_almuslim.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/44'),
    RisalaBook(id: '501_bn', title: 'ইসলামের রাসূল মুহাম্মাদ সাল্লাল্লাহু আলাইহি ওয়াসাল্লাম', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/501/bn-rasul_islam-1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/501'),
    RisalaBook(id: '629_bn', title: 'পবিত্রতা, সালাত এবং জানাযা সম্পর্কিত ফিকহী বিধানসমূহ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/629/bn-min_ahkam_fiqhiyyah-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/629'),
    RisalaBook(id: '522_bn', title: 'তাওহীদের রক্ষণাবেক্ষণ', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/522/bn-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/522'),
    RisalaBook(id: '533_bn', title: 'যাদু ও জ্যোতিষ শাস্ত্রের হুকুম এবং এর সাথে', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/533/bn-hukm_sihr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/533'),
    RisalaBook(id: '177_bn', title: 'যাকাত ও সাওম বিষয়ক দু’টি সংক্ষিপ্ত পুস্তিকা', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/177/bn-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/177'),
    RisalaBook(id: '192_bn', title: 'ছিয়াম', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/192/bn_fast.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/192'),
    RisalaBook(id: '254_bn', title: 'সিয়ামের কতিপয় বিধি-বিধান', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/254/bn_minahkam_assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/254'),
    RisalaBook(id: '550_bn', title: 'কে মহাবিশ্ব সৃষ্টি করেছেন? কে আমাকে সৃষ্টি করেছেন?', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/550/bn_mankhalakalkaun_v2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/550'),
  ],

  // ── Hindi (hi) ── 20 books ──────────────────────────
  'hi': [
    RisalaBook(id: '225_hi', title: 'हज्ज, उमरा तथा ज़ियारत के अधिकांश मसलों का', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/225/hi-attahqiq_walidoh-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/225'),
    RisalaBook(id: '136_hi', title: 'उमरा का तरीका', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/136/hi_sifat-umrah_v2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/136'),
    RisalaBook(id: '224_hi', title: 'इस्लामी अक़ीदा (आस्था) संक्षिप्त में', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/224/hi-nubzah_fil_aqidah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/224'),
    RisalaBook(id: '137_hi', title: 'अल्लाह के नबी सल्लल्लाहु अलैहि व सलल्म की', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/137/hi_kaifiyyahsolat_v2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/137'),
    RisalaBook(id: '947_hi', title: 'उमरा का तरीका', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/947/hi_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/947'),
    RisalaBook(id: '155_hi', title: 'तीन मूल सिद्धान्त और उनके प्रमाण', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/155/hi_tsalatsatul-usul.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/155'),
    RisalaBook(id: '3_hi', title: 'महत्वपूर्ण पाठ उम्मत के सामान्य लोगों के लिए', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/3/hi-addurus_almuhimmah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/3'),
    RisalaBook(id: '130_hi', title: 'वह बातें जिनसे कोई मुसलमान अनभिज्ञ नहीं रह', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/130/hi-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/130'),
    RisalaBook(id: '666_hi', title: 'ऐसे व्यक्ति की पथभ्रष्टता और कुफ्र का बयान,', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/666/hi_bayan_kufri_wadholal.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/666'),
    RisalaBook(id: '632_hi', title: 'स्त्रियों के प्राकृतिक रक्तों से संबंधित पत्रिका', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/632/hi-risalah_fi_dima.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/632'),
    RisalaBook(id: '101_hi', title: 'शुद्ध अक़ीदा और उसके विरुद्ध चीज़ें', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/101/hi_alaqeedah_assohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/101'),
    RisalaBook(id: '90_hi', title: 'सौभाग्यशाली जीवन के उपयोगी साधन', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/90/hi-alwasail_almufidah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/90'),
    RisalaBook(id: '134_hi', title: 'हिस्न अल-मुस्लिम (क़ुरआन एवं हदीस की दुआएँ)', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/134/hi_hisnul-muslim_4.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/134'),
    RisalaBook(id: '337_hi', title: 'शुद्ध अक़ीदा', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/337/hi_alaqida_alhsahihah_new.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/337'),
    RisalaBook(id: '495_hi', title: 'इस्लाम के रसूल मुहम्मद सल्लल्लाहु अलैहि व सल्लम', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/495/hi-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/495'),
    RisalaBook(id: '135_hi', title: 'तौहीद की हिफाज़त', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/135/hi_hirasah_tawheed.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/135'),
    RisalaBook(id: '663_hi', title: 'जादू, ग़ैब की बात बताने और इससे संबंधित', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/663/hi_hukum_sihir_walkahanah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/663'),
    RisalaBook(id: '470_hi', title: 'ज़कात और रोज़े के बारे में दो संक्षिप्त', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/470/hi-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/470'),
    RisalaBook(id: '812_hi', title: 'रोज़े के कुछ अहकाम', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/812/hi-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/812'),
    RisalaBook(id: '520_hi', title: 'ब्रह्माण्ड की रचना किसने की? मेरी रचना किसने', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/520/hi-man_kholaqo-alkaun-v2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hi/content/520'),
  ],

  // ── Malay (ms) ── 18 books ──────────────────────────
  'ms': [
    RisalaBook(id: '133_ms', title: 'Panduan dan Kajian Berkenaan Haji, Umrah dan Ziarah,Menurut', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/133/ms_altahqeq.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/133'),
    RisalaBook(id: '103_ms', title: 'Tatacara Umrah', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/103/ms_sifat-umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/103'),
    RisalaBook(id: '104_ms', title: 'Tatacara Solat Nabi ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/104/ms_tatacarasolat.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/104'),
    RisalaBook(id: '948_ms', title: 'PANDUAN UMRAH', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/948/ms_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/948'),
    RisalaBook(id: '272_ms', title: 'Hukum-Hakam Berkenaan Hadyu, Korban dan Sembelihan', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/272/ms-ahkam_hadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/272'),
    RisalaBook(id: '96_ms', title: 'Pelajaran Terpenting Buat Setiap Muslim', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/96/ms_aldroos.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/96'),
    RisalaBook(id: '69_ms', title: 'Perkara Yang Mesti Diketahui Setiap Muslim', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/69/ms-ma_la_yasa-3.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/69'),
    RisalaBook(id: '619_ms', title: 'Saya Seorang Muslim', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/619/ms_ana_muslim.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/619'),
    RisalaBook(id: '453_ms', title: 'Fadilat Sepuluh Awal Zulhijjah', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/453/ms_fadhl_ash_dhilhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/453'),
    RisalaBook(id: '100_ms', title: 'Akidah Yang Sahih dan Pembatalnya', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/100/ms_akida_new.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/100'),
    RisalaBook(id: '102_ms', title: 'Panduan Meraih Hidup Bahagia', description: '', category: 'Supplications', icon: '📿', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/102/ms_wasailmufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/102'),
    RisalaBook(id: '84_ms', title: 'Rasul agama Islam: Nabi Muhammad ﷺ', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/84/ms_rasul-islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/84'),
    RisalaBook(id: '302_ms', title: 'Akidah Yang Benar', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/302/ms_alaqida_alhsahihah_new.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/302'),
    RisalaBook(id: '273_ms', title: 'Hukum-Hakam Berkaitan Jenazah', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/273/ms-ahkam_janaiz.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/273'),
    RisalaBook(id: '196_ms', title: 'RISALAH PERTAMA', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/196/ms_tohid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/196'),
    RisalaBook(id: '195_ms', title: 'RISALAH RINGKAS BERKAITAN ZAKAT DAN PUASA', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/195/ms_risalatan_v3.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/195'),
    RisalaBook(id: '814_ms', title: 'Beberapa Hukum-Hakam Puasa', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/814/ms_minahkam_assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/814'),
    RisalaBook(id: '271_ms', title: 'Siapakah yang menciptakan alam jagat ini? Siapakah yang', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/271/ms_mankhalaka_alkaun.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ms/content/271'),
  ],

  // ── Somali (so) ── 1 books ──────────────────────────
  'so': [
    RisalaBook(id: '860_so', title: 'Arrimo aysan haboonayn in Muslimku kaJaahil ka ahaado', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/860/so-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/so/content/860'),
  ],

  // ── Swahili (sw) ── 21 books ──────────────────────────
  'sw': [
    RisalaBook(id: '180_sw', title: 'Uchambuzi na ufafanuzi wa masuala mengi ya Hija,', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/180/sw-attahqiq_walidoh-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/180'),
    RisalaBook(id: '197_sw', title: 'NAMNA YA KUFANYA UMRAH', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/197/sw_sifat-umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/197'),
    RisalaBook(id: '82_sw', title: 'Dondoo kuhusu Itikadi ya Kiislamu', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/82/sw_nabzah_fe_alakidah_2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/82'),
    RisalaBook(id: '139_sw', title: 'Namna ya Swala ya Mtume ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/139/sw-kaifiyah_solat_nabi-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/139'),
    RisalaBook(id: '937_sw', title: 'SIFA YA ‘UMRA', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/937/sw_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/937'),
    RisalaBook(id: '41_sw', title: 'Misingi Mitatu na Ushahidi Wake', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/41/sw-tsalatsatul_usul-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/41'),
    RisalaBook(id: '616_sw', title: 'HUKUMU ZA AL-HADYU, AL-ADHWAHI NA KUCHINJA', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/616/sw_ahkam_alhadi_waladhohi_v1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/616'),
    RisalaBook(id: '138_sw', title: 'MASOMO MUHIMU KWA UMMA WOTE', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/138/sw_addurus-almuhimmah_2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/138'),
    RisalaBook(id: '59_sw', title: 'Mambo ya Msingi ambayo haitakikani kwa Muislamu kutoyajua', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/59/sw-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/59'),
    RisalaBook(id: '459_sw', title: 'MIMI NI MUISLAMU', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/459/sw_anamuslim.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/459'),
    RisalaBook(id: '645_sw', title: 'Makala kuhusu damu za asili za wanawake', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/645/sw-risalah_fi_dima.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/645'),
    RisalaBook(id: '448_sw', title: 'FADHILA ZA SIKU KUMI (ZA MWANZO) ZA DHUL-HIJA', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/448/sw_fadlashr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/448'),
    RisalaBook(id: '523_sw', title: 'ITIKADI SAHIHI NA YANAYOPINGANA NAYO', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/523/sw-aqidah_sohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/523'),
    RisalaBook(id: '147_sw', title: 'Njia zenye Faida kwa Maisha yenye Furaha', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/147/sw-alwasail_almufidah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/147'),
    RisalaBook(id: '237_sw', title: 'MUHAMMAD, REHEMA NA AMANI ZA MWENYEZI MUNGU ZIWE', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/237/sw-rasul_islam-1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/237'),
    RisalaBook(id: '179_sw', title: 'Ulinzi wa Tauhidi', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/179/sw-hirasah_tauhid-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/179'),
    RisalaBook(id: '526_sw', title: 'HUKUMU YA UCHAWI, UGANGA NA MAMBO YANAYOHUSIANA NA', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/526/sw-hukm_sihr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/526'),
    RisalaBook(id: '474_sw', title: 'Risala mbili fupi kuhusu Zaka na Saumu(Funga)', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/474/sw-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/474'),
    RisalaBook(id: '189_sw', title: 'Saumu', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/189/sw_fast.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/189'),
    RisalaBook(id: '813_sw', title: 'Miongoni mwa hukumu za Funga (swaumu)', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/813/sw-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/813'),
    RisalaBook(id: '270_sw', title: 'Nani aliye umba Dunia? na ni nani aliye', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/270/sw-man_kholaqo_alkaun-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sw/content/270'),
  ],

  // ── Hausa (ha) ── 21 books ──────────────────────────
  'ha': [
    RisalaBook(id: '223_ha', title: 'TABBATACCAN BAYYANI AKAN YAWANCIN MAS\'ALOLIN HAJJI DA UMRA', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/223/ha_attahqiq-walidoh.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/223'),
    RisalaBook(id: '146_ha', title: 'SIFFAR AIKIN UMARA', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/146/ha-sifat_umrah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/146'),
    RisalaBook(id: '58_ha', title: 'TAKAITACCEN BAYANI AKAN AKIDAR MUSULUNCI (SHARHIN TUSHEN IMANI)', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/58/ha-nubzah_fil_aqidah-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/58'),
    RisalaBook(id: '198_ha', title: 'SIFFAR SALLAR ANNABI ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/198/ha_kaifiyah-solat-nabi_v2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/198'),
    RisalaBook(id: '939_ha', title: 'YADDA AKE UMARA', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/939/ha_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/939'),
    RisalaBook(id: '545_ha', title: 'TUSHE GUDA UKU DA DALILANSU', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/545/ha-tsalatsatul_usul-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/545'),
    RisalaBook(id: '338_ha', title: 'HUKUNCE-HUKUNEN HADAYA DA LAYYA DA YANKA', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/338/ha_ahkamhadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/338'),
    RisalaBook(id: '98_ha', title: 'MUHIMMAN DARUSSA GA DUKKANIN AL\'UMMA', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/98/ha_addurus-almuhimmah_v2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/98'),
    RisalaBook(id: '460_ha', title: 'ABINDA BA ZAI YI WU MUSULMI YA JAHILCE', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/460/ha_ma_la_yasa_v3.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/460'),
    RisalaBook(id: '586_ha', title: 'Bayanin kafirci da ɓatan duk wanda ya raya', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/586/ha_bayan_alkufri_wadholal.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/586'),
    RisalaBook(id: '571_ha', title: 'SAƘO A KAN JINAYEN ƊABI\'A GA MATA', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/571/ha-risalah_fi_dima-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/571'),
    RisalaBook(id: '303_ha', title: 'FALALAR GOMAN FARKO NA ZUL-HIJJA', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/303/ha_organized.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/303'),
    RisalaBook(id: '580_ha', title: 'AƘIDA INGANTACCIYA DA ABINDA YAKE KISHIYANTAR TA', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/580/ha_alaqeedah_assoheehah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/580'),
    RisalaBook(id: '56_ha', title: 'Hanyoyi Masu Amfani Don Samun Rayuwa Mai Dadi', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/56/ha_alwasail-almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/56'),
    RisalaBook(id: '496_ha', title: 'Manzon Musulunci Annabi Muhammad - tsira da amincin', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/496/ha-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/496'),
    RisalaBook(id: '579_ha', title: 'Kare Tauhidi', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/579/ha-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/579'),
    RisalaBook(id: '583_ha', title: 'Hukuncin Sihiri da Bokanci da abinda yake da', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/583/ha_hukum_sihir.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/583'),
    RisalaBook(id: '478_ha', title: 'TAƘAITATTUN SAƘONNI BIYU A KAN ZAKKA DA AZUMI', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/478/ha-risalatan_mujizatan-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/478'),
    RisalaBook(id: '194_ha', title: 'Azumi', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/194/ha_Azumi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/194'),
    RisalaBook(id: '817_ha', title: 'Daga Hukunce-Hukuncen Azumi', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/817/ha-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/817'),
    RisalaBook(id: '464_ha', title: 'WA YA HALICCI HALITTU? WA YA HALICCE NI', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/464/ha_man_khalakaalkaun_v2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ha/content/464'),
  ],

  // ── Chinese (zh) ── 14 books ──────────────────────────
  'zh': [
    RisalaBook(id: '127_zh', title: '副朝简介', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/127/zh_omrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/127'),
    RisalaBook(id: '128_zh', title: '先知（愿主福安之）的礼拜方式', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/128/zh_kaifiyahsolatnabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/128'),
    RisalaBook(id: '944_zh', title: '副朝模式', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/944/zh_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/944'),
    RisalaBook(id: '126_zh', title: '大众必学的重要课程', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/126/zh_droos.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/126'),
    RisalaBook(id: '73_zh', title: '穆斯林必修知识', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/73/zh-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/73'),
    RisalaBook(id: '617_zh', title: '我是穆斯林', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/617/zh-ana_muslim-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/617'),
    RisalaBook(id: '55_zh', title: '通往幸福生活的有益途径', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/55/zh-alwasail_almufidah-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/55'),
    RisalaBook(id: '52_zh', title: '穆斯林的堡垒----古兰经与圣训中的记主词', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/52/zh_hisn_new.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/52'),
    RisalaBook(id: '461_zh', title: '伊斯兰教的使者穆罕默德 - 愿主福安之 -', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/461/zh-rasul_islam-1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/461'),
    RisalaBook(id: '773_zh', title: '伊斯兰信仰简述', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/773/zh-nubzah_fil_aqidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/773'),
    RisalaBook(id: '776_zh', title: '三项基本原则及其证据', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/776/zh-tsalatsatul_usul.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/776'),
    RisalaBook(id: '981_zh', title: '维护认主独一信仰', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/981/zh_hirasahtawheed.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/981'),
    RisalaBook(id: '982_zh', title: '正确信仰及其相反之事', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/982/zh_alaqeedah_Assohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/982'),
    RisalaBook(id: '983_zh', title: '关于巫术、占卜及相关事项的律例', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/983/zh_hukmu_assihri.pdf', bookPageUrl: 'https://risala.prh.gov.sa/zh/content/983'),
  ],

  // ── Russian (ru) ── 22 books ──────────────────────────
  'ru': [
    RisalaBook(id: '630_ru', title: 'Исследование и разъяснение множества вопросов, касающихся хаджа, умры', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/630/ru-attahqiq_walidoh-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/630'),
    RisalaBook(id: '125_ru', title: 'Описание умры (малого паломничества)', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/125/ru-sifat_umrah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/125'),
    RisalaBook(id: '567_ru', title: 'КРАТКОЕ ИЗЛОЖЕНИЕ ИСЛАМСКИХ УБЕЖДЕНИЙ', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/567/ru-nubzah_fil_aqidah-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/567'),
    RisalaBook(id: '124_ru', title: 'Описание молитвы Пророка ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/124/ru-kaifiyah_solat_nabi-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/124'),
    RisalaBook(id: '943_ru', title: 'Описание малого паломничества', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/943/ru_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/943'),
    RisalaBook(id: '542_ru', title: 'Три основы и их доказательства', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/542/ru-tsalatsatul_usul-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/542'),
    RisalaBook(id: '95_ru', title: 'ВАЖНЫЕ УРОКИ ДЛЯ ВСЕЙ УММЫ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/95/ru-addurus_almuhimmah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/95'),
    RisalaBook(id: '573_ru', title: 'МОЛЬБЫ, ВСТРЕЧАЮЩИЕСЯ В КОРАНЕ И СУННЕ', description: '', category: 'Supplications', icon: '📿', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/573/ru_addua_wayalihi_alilaaj_v3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/573'),
    RisalaBook(id: '64_ru', title: 'То, что непозволительно не знать мусульманину', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/64/ru-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/64'),
    RisalaBook(id: '476_ru', title: 'Я — МУСУЛЬМАНИН', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/476/ru_anamuslim.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/476'),
    RisalaBook(id: '633_ru', title: 'Трактат о естественных кровотечениях у женщин', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/633/ru_risalahfiidimaa_v3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/633'),
    RisalaBook(id: '455_ru', title: 'ДОСТОИНСТВО ПЕРВЫХ ДЕСЯТИ ДНЕЙ МЕСЯЦА ЗУ-ЛЬ-ХИДЖА', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/455/ru_fadlashr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/455'),
    RisalaBook(id: '486_ru', title: 'НЕКОТОРЫЕ ОШИБКИ ПАЛОМНИКОВ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/486/ru_akhtahujjaj.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/486'),
    RisalaBook(id: '363_ru', title: 'Правильные убеждения (‘акыда) и то, что им противоречит', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/363/ru_alaqeedah_assohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/363'),
    RisalaBook(id: '141_ru', title: 'ПОЛЕЗНЫЕ СРЕДСТВА ДЛЯ СЧАСТЛИВОЙ ЖИЗНИ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/141/ru-alwasail_almufidah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/141'),
    RisalaBook(id: '480_ru', title: 'Посланник ислама Мухаммад (да благословит его Аллах и', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/480/ru-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/480'),
    RisalaBook(id: '362_ru', title: 'ПОСЛАНИЕ ПЕРВОЕ', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/362/ru_hirasah_tawheed.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/362'),
    RisalaBook(id: '393_ru', title: 'постановление шариата относительно колдовства, предсказаний и того, что', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/393/ru_hukmu_assihri.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/393'),
    RisalaBook(id: '172_ru', title: 'ДВА КРАТКИХ ПОСЛАНИЯ О ЗАКЯТЕ И ПОСТЕ', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/172/ru-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/172'),
    RisalaBook(id: '193_ru', title: 'Пост в рамадане', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/193/ru_fast.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/193'),
    RisalaBook(id: '485_ru', title: 'НЕКОТОРЫЕ ЗАКОНОПОЛОЖЕНИЯ ПОСТА', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/485/ru-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/485'),
    RisalaBook(id: '521_ru', title: 'Кто сотворил этот мир? И кто сотворил меня?', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/521/ru-man_kholaqo_alkaun-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ru/content/521'),
  ],

  // ── Spanish (es) ── 16 books ──────────────────────────
  'es': [
    RisalaBook(id: '376_es', title: 'Investigación y aclaración de mu-chas cuestiones del Hayy,', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/376/es_attahqiq.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/376'),
    RisalaBook(id: '429_es', title: 'La forma de realizar la ‘Umrah', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/429/es_sifat-umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/429'),
    RisalaBook(id: '678_es', title: 'Resumen del credo islámico', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/678/es_nubzah_fil_aqeedah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/678'),
    RisalaBook(id: '458_es', title: 'Cómo era la oración del profeta ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/458/es_kaifiyah-solat-nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/458'),
    RisalaBook(id: '934_es', title: 'Cómo realizar la‘Umrah', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/934/es_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/934'),
    RisalaBook(id: '679_es', title: 'Los tres fundamentos y sus evidencias', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/679/es_thalathauthool.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/679'),
    RisalaBook(id: '614_es', title: 'Las normas de la ofrenda animal, Udjiah y', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/614/es-ahkam_hadyi-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/614'),
    RisalaBook(id: '628_es', title: 'Lecciones importantes para la comunidad en general', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/628/es_addurus_almuhimmah_v2_1_1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/628'),
    RisalaBook(id: '68_es', title: 'Lo que todo musulmán debe conocer', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/68/es-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/68'),
    RisalaBook(id: '36_es', title: 'Tratado sobre los sangrados naturales de la mujer', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/36/es-risalah_fi_dima-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/36'),
    RisalaBook(id: '640_es', title: 'Virtudes de los primeros días de Dhul Hiyyah', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/640/es-fadl_ashr_zulhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/640'),
    RisalaBook(id: '361_es', title: 'Medios útiles para llevar una vida feliz', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/361/es-alwasail_almufidah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/361'),
    RisalaBook(id: '484_es', title: 'La correcta doctrina', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/484/es_alaqida_alhsahihah_new.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/484'),
    RisalaBook(id: '515_es', title: 'El Profeta del Islam, Muhammad, la paz y', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/515/es-rasul_islam-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/515'),
    RisalaBook(id: '357_es', title: 'Dos breves mensajes sobre az-zakat y el ayuno', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/357/es-risalatan_mujizatan-1.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/357'),
    RisalaBook(id: '359_es', title: 'De los veredictos del ayuno', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/359/es-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/es/content/359'),
  ],

  // ── Portuguese (pt) ── 4 books ──────────────────────────
  'pt': [
    RisalaBook(id: '33_pt', title: 'O modo da oração do Profeta, que a', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/33/pt_kaifiyah-solat-nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/pt/content/33'),
    RisalaBook(id: '621_pt', title: 'Eu sou muçulmano', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/621/pt-ana_muslim-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/pt/content/621'),
    RisalaBook(id: '377_pt', title: 'Meios eficazes para uma vida feliz', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/377/pt_alwasail.pdf', bookPageUrl: 'https://risala.prh.gov.sa/pt/content/377'),
    RisalaBook(id: '85_pt', title: 'Profeta do Isslam, Muhammad – Que a paz', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/85/pt-rasul_islam-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/pt/content/85'),
  ],

  // ── German (de) ── 5 books ──────────────────────────
  'de': [
    RisalaBook(id: '938_de', title: 'Die Beschreibung der ʿUmrah', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/938/de_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/de/content/938'),
    RisalaBook(id: '925_de', title: 'Wichtige Lektionen für die allgemeine muslimische Gemeinschaft', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/925/de_durusmuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/de/content/925'),
    RisalaBook(id: '927_de', title: 'Eine Niederschrift zu den natürlichen Blutungen der Frauen', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/927/de-risalah_fi_dima.pdf', bookPageUrl: 'https://risala.prh.gov.sa/de/content/927'),
    RisalaBook(id: '926_de', title: 'Zwei kurze Niederschriften zur Pflichtabgabe („Zakah“) und zum', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/926/de-risalatan_mujizatan.pdf', bookPageUrl: 'https://risala.prh.gov.sa/de/content/926'),
    RisalaBook(id: '984_de', title: 'Der Gesandte des Islams Muhammad  - Allahs Segen', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/984/de-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/de/content/984'),
  ],

  // ── Italian (it) ── 5 books ──────────────────────────
  'it': [
    RisalaBook(id: '335_it', title: 'La Modalità di Preghiera del Profeta ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/335/it_kaifiyahsolat.pdf', bookPageUrl: 'https://risala.prh.gov.sa/it/content/335'),
    RisalaBook(id: '407_it', title: 'Le cause utili per una vita felice', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/407/it_alwasail-almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/it/content/407'),
    RisalaBook(id: '283_it', title: 'Le norme giuridiche riguardanti i funerali', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/283/it_ahkamjanaiz.pdf', bookPageUrl: 'https://risala.prh.gov.sa/it/content/283'),
    RisalaBook(id: '991_it', title: 'Virtù ed etichette della Moschea del Profeta e', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/991/it_fadhoil_waadab_masjidnabawi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/it/content/991'),
    RisalaBook(id: '993_it', title: 'L\'accertamento e la chiarificazione di numerose questioni relative', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/993/it_attahqiq_waliidoh.pdf', bookPageUrl: 'https://risala.prh.gov.sa/it/content/993'),
  ],

  // ── Dutch (nl) ── 4 books ──────────────────────────
  'nl': [
    RisalaBook(id: '46_nl', title: 'Wat de moslim zich geen onwetendheid over kan', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/46/nl_ma-la-yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/nl/content/46'),
    RisalaBook(id: '694_nl', title: 'De heilzame middelen tot een gelukkig leven', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/694/nl-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/nl/content/694'),
    RisalaBook(id: '282_nl', title: 'Het dodengebed', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/282/nl-ahkam_janaiz.pdf', bookPageUrl: 'https://risala.prh.gov.sa/nl/content/282'),
    RisalaBook(id: '800_nl', title: 'Uit de voorschriften van het vasten', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/800/nl_min_ahkam_Assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/nl/content/800'),
  ],

  // ── Persian (fa) ── 23 books ──────────────────────────
  'fa': [
    RisalaBook(id: '170_fa', title: 'تحقیق و توضیح  بسیاری از مسائل حج و', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/170/fa-attahqiq_walidoh-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/170'),
    RisalaBook(id: '140_fa', title: 'روش انجام دادن عمره', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/140/fa_sifatulumrah_v2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/140'),
    RisalaBook(id: '492_fa', title: 'خلاصه‌ای در عقیدۀ اسلامی', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/492/fa-nubzah_fil_aqidah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/492'),
    RisalaBook(id: '129_fa', title: 'كيفيت نماز پیامبر ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/129/fa_kaifiyah-solat-nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/129'),
    RisalaBook(id: '945_fa', title: 'روش عمره', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/945/fa_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/945'),
    RisalaBook(id: '674_fa', title: 'اصول سه‌گانه و ادلهٔ آن', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/674/fa_thalatha_uthool.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/674'),
    RisalaBook(id: '167_fa', title: 'درس های مهم برای عموم امت', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/167/fa-addurus_almuhimmah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/167'),
    RisalaBook(id: '258_fa', title: 'دعا و درمان با رقْیه از کتاب و', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/258/fa_413.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/258'),
    RisalaBook(id: '487_fa', title: 'آنچه هر مسلمانی باید بداند', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/487/fa-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/487'),
    RisalaBook(id: '353_fa', title: 'من مسلمانم', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/353/fa_anamuslim.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/353'),
    RisalaBook(id: '364_fa', title: 'راهنمای حج و عمره', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/364/fa_almanhajlimurid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/364'),
    RisalaBook(id: '493_fa', title: 'رساله‌ای دربارۀ خون‌های طبیعی زنان', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/493/fa_risalahfidimaatobiiyyahlinnisaav3.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/493'),
    RisalaBook(id: '274_fa', title: 'فضیلت دههٔ اول ماه ذوالحجه', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/274/fa_fadl-ashr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/274'),
    RisalaBook(id: '275_fa', title: 'اشتباهاتی که برخی از حاجیان مرتکب آن می‌شوند', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/275/fa_akhta.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/275'),
    RisalaBook(id: '168_fa', title: 'عقیدهٔ صحیح  و آنچه با آن در تضاد', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/168/fa_alaqeedah_assohihah_v4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/168'),
    RisalaBook(id: '148_fa', title: 'راهکارهای سودمند برای شاد زیستن', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/148/fa_alwasail-almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/148'),
    RisalaBook(id: '343_fa', title: 'عقیدهٔ صحیح', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/343/fa_alaqida_alhsahihah_new.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/343'),
    RisalaBook(id: '441_fa', title: 'پیامبر اسلام محمد ﷺ', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/441/fa-rasul_islam-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/441'),
    RisalaBook(id: '109_fa', title: 'پاسداری از توحید', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/109/fa_hirasah_tawheed_v4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/109'),
    RisalaBook(id: '200_fa', title: 'حکم سِحر و پیشگویی و آنچه به آنها', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/200/fa_hukmu_assihri_v4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/200'),
    RisalaBook(id: '171_fa', title: 'دو نامهٔ مختصر دربارهٔ زکات و روزه', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/171/fa-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/171'),
    RisalaBook(id: '218_fa', title: 'از احکام روزه', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/218/fa_minahkam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/218'),
    RisalaBook(id: '78_fa', title: 'چه کسی جهان را آفریده است؟ و چه', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/78/fa-man_kholaqo-alkaun-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fa/content/78'),
  ],

  // ── Pashto (ps) ── 14 books ──────────────────────────
  'ps': [
    RisalaBook(id: '184_ps', title: 'د قرآن او د سنتو په رڼا کې', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/184/ps_attahqiq.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/184'),
    RisalaBook(id: '122_ps', title: 'د عمرې طریقه', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/122/ps_sefa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/122'),
    RisalaBook(id: '111_ps', title: 'د پېغمبر صلی الله علیه وسلم د لمانځه', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/111/ps_kaifiyah-solat-nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/111'),
    RisalaBook(id: '94_ps', title: 'د هدیې، قربانۍ او ذبحې احکام', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/94/ps_ahkam-hadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/94'),
    RisalaBook(id: '164_ps', title: 'د عام خلکو لپاره مهم درسونه', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/164/ps_addurus-almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/164'),
    RisalaBook(id: '89_ps', title: 'هغه څه چې مسلمان ترې بايد ناخبره پاتې', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/89/ps-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/89'),
    RisalaBook(id: '913_ps', title: 'د ښځو د طبیعي وینو (حیض، نفاس او', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/913/ps-risalah_fi_dima.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/913'),
    RisalaBook(id: '641_ps', title: 'د ذي الحجې د لسيزې فضیلت', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/641/ps-fadl_ashr_zulhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/641'),
    RisalaBook(id: '110_ps', title: 'صحیح عقیده او هغه چې خالف یې ده', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/110/ps_akidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/110'),
    RisalaBook(id: '121_ps', title: 'د نېکمرغه ژوند لپاره ګټورې وسیلې', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/121/ps_alwasail-almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/121'),
    RisalaBook(id: '627_ps', title: 'د طهارت، لمونځ او جنازې فقهي احکام', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/627/ps_minalahkam_alfiqhiyyah_v2_1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/627'),
    RisalaBook(id: '185_ps', title: 'د توحید ساتنې لړۍ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/185/ps_tawheed.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/185'),
    RisalaBook(id: '293_ps', title: 'د زکات او روژې په اړه دوه لنډ', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/293/ps_risalatan-mujizatan.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/293'),
    RisalaBook(id: '294_ps', title: 'د روژې له احکامو څخه', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/294/ps-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ps/content/294'),
  ],

  // ── Uzbek (uz) ── 17 books ──────────────────────────
  'uz': [
    RisalaBook(id: '97_uz', title: 'Ҳаж, умра ва зиёратга оид Қуръон ва суннат', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/97/uz_attahqiq_walidoh_3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/97'),
    RisalaBook(id: '183_uz', title: 'Умранинг сифати', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/183/uz-sifat_umrah-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/183'),
    RisalaBook(id: '652_uz', title: 'Иймон асосларининг шарҳи (Исломий эътиқод ҳақида илмий асар)', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/652/uz-nubzah_fil_aqidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/652'),
    RisalaBook(id: '105_uz', title: 'Пайғамбар соллаллоҳу алайҳи ва саллам намозининг кайфияти', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/105/uz-kaifiyah_solat_nabi-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/105'),
    RisalaBook(id: '149_uz', title: 'УММАТ УЧУН МУҲИМ ДАРСЛАР', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/149/uz-addurus_almuhimmah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/149'),
    RisalaBook(id: '724_uz', title: 'Ҳар бир мусулмон билиши зарур бўлган илмлар', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/724/uz-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/724'),
    RisalaBook(id: '613_uz', title: 'Мен мусулмонман', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/613/uz-ana_muslim_1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/613'),
    RisalaBook(id: '644_uz', title: 'Аёллардан келадиган табий қонларга оид рисола', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/644/uz-risalah_fi_dima-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/644'),
    RisalaBook(id: '447_uz', title: 'ЗУЛҲИЖЖА ОЙИНИНГ АВВАЛГИ ЎН КУНИНИНГ ФАЗИЛАТИ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/447/uz-fadl_ashr_zulhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/447'),
    RisalaBook(id: '181_uz', title: 'Саҳиҳ эътиқод ва унинг зидди', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/181/uz_alaqeedah_assohihah_v4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/181'),
    RisalaBook(id: '150_uz', title: 'БАХТЛИ ҲАЁТ УЧУН ФОЙДАЛИ ВОСИТАЛАР', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/150/uz-alwasail_almufidah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/150'),
    RisalaBook(id: '226_uz', title: 'Ислом элчиси – Муҳаммад соллаллоҳу алайҳи ва саллам', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/226/uz-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/226'),
    RisalaBook(id: '142_uz', title: 'Тавҳидни ҳимоя қилиш', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/142/uz-hirasah_tauhid-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/142'),
    RisalaBook(id: '199_uz', title: 'Сеҳргарлик, коҳинлик ва шунга оид масалалар ҳукми', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/199/uz_hukmu_assihri_walkahanah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/199'),
    RisalaBook(id: '212_uz', title: 'Закот ва рўза ҳақида рисола', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/212/uz-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/212'),
    RisalaBook(id: '217_uz', title: 'РЎЗА АҲКОМЛАРИ', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/217/uz-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/217'),
    RisalaBook(id: '248_uz', title: 'Бу оламни, мени ким ва нима учун яратди?', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/248/uz-man_kholaqo_alkaun-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/uz/content/248'),
  ],

  // ── Azerbaijani (az) ── 4 books ──────────────────────────
  'az': [
    RisalaBook(id: '556_az', title: 'Peyğəmbərin (sallallahu aleyhi va səlləm) namaz qılma qaydası', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/556/az_kaifiyah-solat-nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/az/content/556'),
    RisalaBook(id: '543_az', title: 'Üç əsas və dəlilləri', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/543/az-tsalatsatul_usul-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/az/content/543'),
    RisalaBook(id: '546_az', title: 'Bütün ümmət üçün vacib dərslər', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/546/az-addurus_almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/az/content/546'),
    RisalaBook(id: '710_az', title: 'İslam elçisi Muhəmməd (Allahın salavatı və salamı onun', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/710/az-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/az/content/710'),
  ],

  // ── Tajik (tg) ── 3 books ──────────────────────────
  'tg': [
    RisalaBook(id: '561_tg', title: 'Равиши намози Паёмбар (Саллалоҳу алайҳи ва саллам)', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/561/tg_kaifiyah-soah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tg/content/561'),
    RisalaBook(id: '12_tg', title: 'Дарсҳои муҳим барои оммаи мусалмонон', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/12/tg-addurus_almuhimmah-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tg/content/12'),
    RisalaBook(id: '650_tg', title: 'Он чи ҳар як мусалмон набояд аз он', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/650/tg_maalaayasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tg/content/650'),
  ],

  // ── Kyrgyz (ky) ── 5 books ──────────────────────────
  'ky': [
    RisalaBook(id: '912_ky', title: 'Пайгамбардын мечитинин артыкчылыктары жана адептери, Пайгамбардын ﷺ кабырын', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/912/ky_fadhail_waadab_almasjid_annabawi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ky/content/912'),
    RisalaBook(id: '637_ky', title: 'Пайгамбар, саллаллаху алейхи уа салламдын, намазынын баяны', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/637/ky_kaifiyah_solah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ky/content/637'),
    RisalaBook(id: '596_ky', title: 'Үч негиз жана анын далилдери', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/596/ky_thalatha_uthool.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ky/content/596'),
    RisalaBook(id: '462_ky', title: 'Мусулман адам билүүсү важиб болгон нерселер', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/462/ky_ma-la-yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ky/content/462'),
    RisalaBook(id: '693_ky', title: 'Бактылуу жашоо үчүн пайдалуу себептер', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/693/ky-alwasail_almufidah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ky/content/693'),
  ],

  // ── Tamil (ta) ── 10 books ──────────────────────────
  'ta': [
    RisalaBook(id: '290_ta', title: 'உம்ரா செய்யும் முறை', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/290/ta-sifat_umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ta/content/290'),
    RisalaBook(id: '692_ta', title: 'இஸ்லாமியக் கொள்கை பற்றிய சுருக்கமான ஓர் ஆய்வுக் கண்ணோட்டம்', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/692/ta-nubzah_fil_aqidah-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ta/content/692'),
    RisalaBook(id: '281_ta', title: 'நபியவர்களின் தொழுகை முறை அவரின் மீது அல்லாஹ் ஸலவாத்தும் ஸலாமும்', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/281/Ta_kaif_salat.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ta/content/281'),
    RisalaBook(id: '597_ta', title: 'மூன்று அடிப்படைகளும் அவற்றின் ஆதாரங்களும்', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/597/ta_thalatha_uthool.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ta/content/597'),
    RisalaBook(id: '491_ta', title: 'குர்பானியின் சட்டங்கள்', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/491/ta-ahkam_hadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ta/content/491'),
    RisalaBook(id: '691_ta', title: 'ஒவ்வொரு முஸ்லிமும் அவசியம் அறிந்திருக்கவேண்டிய விடயங்கள்', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/691/ta_maa_laa_yasaa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ta/content/691'),
    RisalaBook(id: '729_ta', title: 'பெண்கள் சுத்தம் தொடர்பான ஒரு கையேடு', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/729/ta-risalah_fi_dima.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ta/content/729'),
    RisalaBook(id: '289_ta', title: 'துல்ஹஜ் மாதத்தின் முதல் பத்து நாட்களின் சிறப்புகள்', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/289/ta-fadl_ashr_zulhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ta/content/289'),
    RisalaBook(id: '30_ta', title: 'மகிழ்ச்சியான வாழ்வுக்கான பயனுள்ள வழிமுறைகள்', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/30/ta-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ta/content/30'),
    RisalaBook(id: '689_ta', title: 'இஸ்லாத்தின் தூதர் முஹம்மத் (ஸல்) அவர்கள்', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/689/ta-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ta/content/689'),
  ],

  // ── Telugu (te) ── 17 books ──────────────────────────
  'te': [
    RisalaBook(id: '713_te', title: 'ఖుర్ఆన్ మరియు సున్నతుల ప్రకారం హజ్, ఉమ్రహ్ మరియు జియారతుకు', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/713/te-attahqiq_walidoh-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/713'),
    RisalaBook(id: '242_te', title: 'ఉమ్రహ్ విధానము', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/242/te-sifat_umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/242'),
    RisalaBook(id: '680_te', title: 'ఇస్లామీయ విశ్వాసం యొక్క సారాంశము', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/680/te_nubzahfilaqeedah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/680'),
    RisalaBook(id: '243_te', title: 'ప్రవక్త ముహమ్మద్ సల్లల్లాహు అలైహి వసల్లం నమాజు విధానము', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/243/te_kaifiyah-solat.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/243'),
    RisalaBook(id: '598_te', title: 'త్రిసూత్రాలు మరియు వాటి ఆధారాలు', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/598/te-tsalatsatul_usul-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/598'),
    RisalaBook(id: '304_te', title: 'హదీ, ఉద్హియా (ఖుర్బానీ జంతువు), మరియు తజ్‌కియా యొక్క నియమాలు', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/304/te_432.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/304'),
    RisalaBook(id: '233_te', title: 'సాధారణ ముస్లింలందరి కొరకు ముఖ్య పాఠాలు', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/233/te-addurus_almuhimmah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/233'),
    RisalaBook(id: '50_te', title: 'ముస్లిం తప్పక తెలుసుకోవలసిన జ్ఞానము', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/50/te-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/50'),
    RisalaBook(id: '554_te', title: 'స్త్రీల సహజరక్త సంభంధిత పత్రిక', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/554/te_risalah-fiidimaa-attobiiyyah-linnisaa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/554'),
    RisalaBook(id: '732_te', title: 'సరియైన విశ్వాసం (అఖీదహ్) మరియు దానికి విరుద్ధమైనవి', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/732/te-aqidah_sohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/732'),
    RisalaBook(id: '241_te', title: 'సంతోషకరమైన జీవితాన్ని అందించే ఉత్తమ మార్గాలు', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/241/te-alwasail-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/241'),
    RisalaBook(id: '600_te', title: 'ఇస్లాం యొక్క సందేశహరులు ముహమ్మద్ సల్లల్లాహు అలైహివ సల్లం', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/600/te-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/600'),
    RisalaBook(id: '731_te', title: 'తౌహీద్ సంరక్షణ', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/731/te-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/731'),
    RisalaBook(id: '735_te', title: 'మంత్రజాలం, జ్యోతిష్కం మరియు వాటికి సంబంధించిన వాటి ఆదేశము', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/735/te-hukm_sihr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/735'),
    RisalaBook(id: '341_te', title: 'జకాతు విధిదానము మరియు రమదాను ఉపవాసాలపై రెండు సంక్షిప్త సందేశాలు', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/341/te_risalatanmujizatan.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/341'),
    RisalaBook(id: '336_te', title: 'ఉపవాసముల ఆదేశములలో నుండి', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/336/te_minahkam_assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/336'),
    RisalaBook(id: '634_te', title: 'విశ్వాన్ని ఎవరు సృష్టించారు? నన్ను ఎవరు సృష్టించారు? మరియు ఎందుకు?', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/634/te_mankhalaka_alkaun_v2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/te/content/634'),
  ],

  // ── Malayalam (ml) ── 15 books ──────────────────────────
  'ml': [
    RisalaBook(id: '676_ml', title: 'ഇസ്‌ലാമിക വിശ്വാസ സംഗ്രഹം', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/676/ml-nubzah_fil_aqidah-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/676'),
    RisalaBook(id: '560_ml', title: 'നബിയുടെ നിസ്കാരം', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/560/ml_kaifiyah-solah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/560'),
    RisalaBook(id: '723_ml', title: 'മൂന്ന്  അടിസ്ഥാനതത്വങ്ങളും അവയുടെ തെളിവുകളും', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/723/ml_thalatha_uthool.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/723'),
    RisalaBook(id: '490_ml', title: 'ഹദ്‌യ്, ഉദ്ഹിയ്യഃ, ബലികർമ്മം; ചില വിധിവിലക്കുകൾ', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/490/ml_ahkamhadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/490'),
    RisalaBook(id: '24_ml', title: 'പൊതുജനങ്ങൾക്കുള്ള സുപ്രധാന പാഠങ്ങൾ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/24/ml-addurus_almuhimmah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/24'),
    RisalaBook(id: '699_ml', title: 'ഓരോ മുസ്‌ലിമും നിര്‍ബന്ധമായും അറിഞ്ഞിരിക്കേണ്ടത്', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/699/ml-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/699'),
    RisalaBook(id: '35_ml', title: 'ഋതുമതിയാകുമ്പോൾ', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/35/ml-risalah_fi_dima.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/35'),
    RisalaBook(id: '643_ml', title: 'ദുൽഹിജ്ജ മാസത്തിലെ (ആദ്യ) പത്ത് ദിനങ്ങളുടെ  ശ്രേഷ്ഠത', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/643/ml_fadhlu_ashri_dhilhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/643'),
    RisalaBook(id: '902_ml', title: 'ശരിയായ വിശ്വാസവും അതിന് വിരുദ്ധമായതും', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/902/ml_alaqeedah_assohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/902'),
    RisalaBook(id: '383_ml', title: 'സൗഭാഗ്യജീവിതം ലഭിക്കാനുള്ള വഴികൾ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/383/ml-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/383'),
    RisalaBook(id: '604_ml', title: 'ഇസ്‌ലാമിൻ്റെ പ്രവാചകൻ മുഹമ്മദ് നബി (ﷺ)', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/604/ml-rasul_islam-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/604'),
    RisalaBook(id: '901_ml', title: 'തൗഹീദിന്റെ സംരക്ഷണം', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/901/ml_hirasah_tawheed.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/901'),
    RisalaBook(id: '905_ml', title: 'സിഹ്ർ, ജോത്സ്യം തുടങ്ങിയവയുടെ വിധി', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/905/ml_hukmu_assihri.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/905'),
    RisalaBook(id: '799_ml', title: 'നോമ്പിന്‍റെ വിധിവിലക്കുകളിൽ നിന്ന്', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/799/ml_min_ahkam_Assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/799'),
    RisalaBook(id: '639_ml', title: 'ആരാണ് ഈ പ്രപഞ്ചത്തിൻ്റെ സ്രഷ്ടാവ്? ആരാണ് എന്നെ സൃഷ്ടിച്ചത്? എന്തിനുവേണ്ടി', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/639/ml_man_khalaq_alkown.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ml/content/639'),
  ],

  // ── Kannada (kn) ── 12 books ──────────────────────────
  'kn': [
    RisalaBook(id: '479_kn', title: 'ಪ್ರವಾದಿಯವರ ನಮಾಝ್ ವಿಧಾನ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/479/kn-kaifiyah_solat_nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/479'),
    RisalaBook(id: '498_kn', title: 'ಹದ್ಯ್, ಉದ್‌ಹಿಯ ಮತ್ತು ತಝ್ಕಿಯಃದ ನಿಯಮಗಳು', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/498/kn_ahkam-hadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/498'),
    RisalaBook(id: '433_kn', title: 'ನಾನು ಮುಸ್ಲಿಮ್', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/433/kn-ana_muslim-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/433'),
    RisalaBook(id: '722_kn', title: 'ಮಹಿಳೆಯರ ನೈಸರ್ಗಿಕ ರಕ್ತಸ್ರಾವದ ನಿಯಮಗಳು', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/722/kn_risalah_fidimaa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/722'),
    RisalaBook(id: '456_kn', title: 'ದುಲ್‌ಹಿಜ್ಜ ತಿಂಗಳ ಮೊದಲ ಹತ್ತು ದಿನಗಳ ಶ್ರೇಷ್ಠತೆ', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/456/kn_fadlashr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/456'),
    RisalaBook(id: '849_kn', title: 'ಸರಿಯಾದ ವಿಶ್ವಾಸ (ಅಕೀದ) ಮತ್ತು ಅದಕ್ಕೆ ವಿರುದ್ಧವಾದದ್ದು', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/849/kn-aqidah_sohihah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/849'),
    RisalaBook(id: '406_kn', title: 'ಸೌಭಾಗ್ಯ ಜೀವನಕ್ಕಾಗಿ ಉಪಯುಕ್ತ ಮಾರ್ಗಗಳು', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/406/kn-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/406'),
    RisalaBook(id: '465_kn', title: 'ಇಸ್ಲಾಮಿನ ಸಂದೇಶವಾಹಕ ಮುಹಮ್ಮದ್ ﷺ', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/465/kn-rasul_islam-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/465'),
    RisalaBook(id: '848_kn', title: 'ತೌಹೀದಿನ ರಕ್ಷಣೆ', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/848/kn-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/848'),
    RisalaBook(id: '852_kn', title: 'ಮಾಟ, ಭವಿಷ್ಯ ಹೇಳುವುದು ಮತ್ತು ಅದಕ್ಕೆ ಸಂಬಂಧಿಸಿದ ವಿಷಯಗಳ ವಿಧಿ', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/852/kn-hukm_sihr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/852'),
    RisalaBook(id: '471_kn', title: 'ಝಕಾತ್ ಮತ್ತು ಉಪವಾಸದ ಕುರಿತು ಎರಡು ಸಂಕ್ಷಿಪ್ತ ಸಂದೇಶಗಳು', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/471/kn-risalatan_mujizatan.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/471'),
    RisalaBook(id: '815_kn', title: 'ಉಪವಾಸ ಸಂಬಂಧಿತ ಕೆಲವು ನಿಯಮಗಳು', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/815/kn_minahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/kn/content/815'),
  ],

  // ── Gujarati (gu) ── 12 books ──────────────────────────
  'gu': [
    RisalaBook(id: '39_gu', title: 'ઉમરહનો તરીકો', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/39/gu_sifat-umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/39'),
    RisalaBook(id: '222_gu', title: 'નબી સલ્લલ્લાહુ અલૈહિ વસલ્લમની નમાઝની પદ્ધતિ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/222/gu_kaifiyah-solat-nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/222'),
    RisalaBook(id: '463_gu', title: 'હદ્-ય, કુરબાની અને ઝબેહ કરવાના કેટલાક આદેશો', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/463/gu_ahkam-hadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/463'),
    RisalaBook(id: '221_gu', title: 'એક સામાન્ય મુસલમાન વ્યક્તિ માટે અગત્યના પાઠો', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/221/gu-addurus_almuhimmah-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/221'),
    RisalaBook(id: '74_gu', title: 'તે વાતો જે એક મુસલમાને જાણવી જરૂરી છે', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/74/gu-ma_la_yasa-3.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/74'),
    RisalaBook(id: '435_gu', title: 'હું મુસલમાન છું', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/435/gu-ana_muslim-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/435'),
    RisalaBook(id: '450_gu', title: 'ઝિલ્ હિજ્જહના પહેલા દસ દિવસની મહત્ત્વતા', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/450/gu_fadlashr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/450'),
    RisalaBook(id: '220_gu', title: 'સુખી જીવન માટેના લાભદાયક ઉપાયો', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/220/gu_alwasail-almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/220'),
    RisalaBook(id: '444_gu', title: 'ઇસ્લામના પયગંબર મુહમ્મદ ﷺ તેમના પર દરુદ અને', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/444/gu_rasul-islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/444'),
    RisalaBook(id: '473_gu', title: 'ઝકાત અને રોઝા વિશે બે સંક્ષિપ્ત પુસ્તિકા', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/473/gu-risalatan_mujizatan-1.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/473'),
    RisalaBook(id: '816_gu', title: 'રોઝાના કેટલાક આદેશો', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/816/gu-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/816'),
    RisalaBook(id: '651_gu', title: 'સૃષ્ટિને કોણે પેદા કરી? મને કોણે પેદા કર્યો?', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/651/gu_mankhalaka_alkaun.pdf', bookPageUrl: 'https://risala.prh.gov.sa/gu/content/651'),
  ],

  // ── Nepali (ne) ── 6 books ──────────────────────────
  'ne': [
    RisalaBook(id: '704_ne', title: 'नबी ﷺ को नमाजको तरिका', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/704/ne-kaifiyah_solat_nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ne/content/704'),
    RisalaBook(id: '797_ne', title: 'तीन मूल सिद्धान्त र त्यसका प्रमाणहरू', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/797/ne-tsalatsatul_usul-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ne/content/797'),
    RisalaBook(id: '5_ne', title: 'सर्वसाधारणका लागि महत्त्वपूर्ण पाठहरू', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/5/ne_addurus-almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ne/content/5'),
    RisalaBook(id: '728_ne', title: 'मुस्लिमले जान्नैपर्ने कुराहरू', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/728/ne_maa_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ne/content/728'),
    RisalaBook(id: '809_ne', title: 'सुखमय जीवनका लागि उपयोगी साधनहरू', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/809/ne-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ne/content/809'),
    RisalaBook(id: '985_ne', title: 'इस्लाम धर्मको सन्देष्टा मुहम्मद (सल्लल्लाहु अलैहि वसल्लम)', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/985/ne_rasulislam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ne/content/985'),
  ],

  // ── Sinhala (si) ── 9 books ──────────────────────────
  'si': [
    RisalaBook(id: '256_si', title: 'උම්රා ඉටු කිරීමේ ක්‍රමය', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/256/si_405.pdf', bookPageUrl: 'https://risala.prh.gov.sa/si/content/256'),
    RisalaBook(id: '705_si', title: 'ඉස්ලාමීය විශ්වාස පද්ධතිය පිළිබඳ හැඳින්වීමක්', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/705/si-nubzah_fil_aqidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/si/content/705'),
    RisalaBook(id: '255_si', title: 'නබි තුමාණන් සලාත් ඉටු කළ ක්‍රමය', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/255/si_kaifiyahsolat.pdf', bookPageUrl: 'https://risala.prh.gov.sa/si/content/255'),
    RisalaBook(id: '675_si', title: 'මූලධර්ම තුන සහ ඒවායේ සාක්ෂි හා සාධක', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/675/si-tsalatsatul_usul.pdf', bookPageUrl: 'https://risala.prh.gov.sa/si/content/675'),
    RisalaBook(id: '291_si', title: 'පොදු ජනතාවට වැදගත් වන පාඩම්', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/291/si_addurus-almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/si/content/291'),
    RisalaBook(id: '700_si', title: 'මුස්ලිම්වරයෙකු දැන සිටිය යුතු අත්‍යවශ්‍ය කරුණු', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/700/si_malayasaa_almuslim_v3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/si/content/700'),
    RisalaBook(id: '730_si', title: 'කාන්තා පිරිසිදුකම', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/730/si-risalah_fi_dima-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/si/content/730'),
    RisalaBook(id: '249_si', title: 'ප්‍රීතිමත් ජීවිතයක් සඳහා ඵලදායී මාර්ග කිහිපයක්', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/249/si-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/si/content/249'),
    RisalaBook(id: '798_si', title: 'උපවාසයේ නීතිරීතිවලින් බිඳක්', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/798/si_minahkamassiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/si/content/798'),
  ],

  // ── Amharic (am) ── 12 books ──────────────────────────
  'am': [
    RisalaBook(id: '38_am', title: 'የዑምራ አደራረግ ስርዓት', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/38/am_sifat-umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/38'),
    RisalaBook(id: '392_am', title: 'የዑምራ አደራረግ ስርዓት', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/392/am_sifatumrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/392'),
    RisalaBook(id: '935_am', title: 'የዑምራ አፈፃፀም ሁኔታ ከተመረጡ ዱዓዎች ጋር', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/935/am_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/935'),
    RisalaBook(id: '497_am', title: 'ሀድይ፣ ኡዱሒያና እርድን የተመለከቱ ህግጋት', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/497/am_ahkam-hadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/497'),
    RisalaBook(id: '269_am', title: 'አሳሳቢ ትምህርቶች ለብዙሀኑ ህዝብ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/269/am_aldroos.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/269'),
    RisalaBook(id: '821_am', title: 'ማንም ሙስሊም ሳያውቀው ሊቀር የማይፈቀድለት ጉዳዮች (እያንዳንዱ ሙስሊም', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/821/am-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/821'),
    RisalaBook(id: '449_am', title: 'የዙል ሒጃ አስሩ ቀናት ትሩፋት', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/449/am_fadlashr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/449'),
    RisalaBook(id: '389_am', title: 'ለደስተኛ ሕይወት ጠቃሚ ዘዴዎች', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/389/am-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/389'),
    RisalaBook(id: '690_am', title: 'የኢስላም መልዕክተኛ የሆኑት ሙሐመድ ﷺ', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/690/am-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/690'),
    RisalaBook(id: '472_am', title: 'ዘካና ፆምን የሚመለከቱ አጠር ያሉ መልዕክቶች', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/472/am-risalatan_mujizatan.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/472'),
    RisalaBook(id: '810_am', title: 'የፆም ህግጋት', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/810/am-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/810'),
    RisalaBook(id: '466_am', title: 'ፍጥረተ ዓለምን የፈጠረው ማን ነው? እኔንስ የፈጠረኝ ማን', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/466/am-man_kholaqo-alkaun-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/am/content/466'),
  ],

  // ── Oromo (om) ── 12 books ──────────────────────────
  'om': [
    RisalaBook(id: '38_om', title: 'የዑምራ አደራረግ ስርዓት', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/38/am_sifat-umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/38'),
    RisalaBook(id: '392_om', title: 'የዑምራ አደራረግ ስርዓት', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/392/am_sifatumrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/392'),
    RisalaBook(id: '935_om', title: 'የዑምራ አፈፃፀም ሁኔታ ከተመረጡ ዱዓዎች ጋር', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/935/am_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/935'),
    RisalaBook(id: '497_om', title: 'ሀድይ፣ ኡዱሒያና እርድን የተመለከቱ ህግጋት', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/497/am_ahkam-hadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/497'),
    RisalaBook(id: '269_om', title: 'አሳሳቢ ትምህርቶች ለብዙሀኑ ህዝብ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/269/am_aldroos.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/269'),
    RisalaBook(id: '821_om', title: 'ማንም ሙስሊም ሳያውቀው ሊቀር የማይፈቀድለት ጉዳዮች (እያንዳንዱ ሙስሊም', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/821/am-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/821'),
    RisalaBook(id: '449_om', title: 'የዙል ሒጃ አስሩ ቀናት ትሩፋት', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/449/am_fadlashr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/449'),
    RisalaBook(id: '389_om', title: 'ለደስተኛ ሕይወት ጠቃሚ ዘዴዎች', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/389/am-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/389'),
    RisalaBook(id: '690_om', title: 'የኢስላም መልዕክተኛ የሆኑት ሙሐመድ ﷺ', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/690/am-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/690'),
    RisalaBook(id: '472_om', title: 'ዘካና ፆምን የሚመለከቱ አጠር ያሉ መልዕክቶች', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/472/am-risalatan_mujizatan.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/472'),
    RisalaBook(id: '810_om', title: 'የፆም ህግጋት', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/810/am-min_ahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/810'),
    RisalaBook(id: '466_om', title: 'ፍጥረተ ዓለምን የፈጠረው ማን ነው? እኔንስ የፈጠረኝ ማን', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/466/am-man_kholaqo-alkaun-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/om/content/466'),
  ],

  // ── Kinyarwanda (rw) ── 2 books ──────────────────────────
  'rw': [
    RisalaBook(id: '61_rw', title: 'IBYO UMUYISILAMU ADAKWIYE KUYOBERWA', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/61/rw_ma-la-yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/rw/content/61'),
    RisalaBook(id: '379_rw', title: 'UBURYO NGIRAKAMARO BUKUGEZA KU BUZIMA BW\'UMUNEZERO', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/379/rw-alwasail_almufidah-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/rw/content/379'),
  ],

  // ── Wolof (wo) ── 1 books ──────────────────────────
  'wo': [
    RisalaBook(id: '11_wo', title: 'Ay njàngale yu am solo ñeel xeet wi', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/11/wo-addurus_almuhimmah-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/wo/content/11'),
  ],

  // ── Yoruba (yo) ── 3 books ──────────────────────────
  'yo': [
    RisalaBook(id: '857_yo', title: 'Bí Anabi (kí ikẹ àti ọlá Ọlọ́hun máa', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/857/yo-kaifiyah_solat_nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/yo/content/857'),
    RisalaBook(id: '747_yo', title: 'Awọn ẹkọ ti o pataki fun gbogbo ali\'ummah', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/747/yo-addurus_almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/yo/content/747'),
    RisalaBook(id: '856_yo', title: 'Àwọn ọ̀nà tó ṣàǹfààní fún ìgbésí ayé oriire', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/856/yo-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/yo/content/856'),
  ],

  // ── Malagasy (mg) ── 3 books ──────────────────────────
  'mg': [
    RisalaBook(id: '748_mg', title: 'Ny fomba fanaovan\'ny Mpaminany (S.A.W) ny SWALAT', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/748/mg_kaifiyah_solah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/mg/content/748'),
    RisalaBook(id: '22_mg', title: 'Lesona manan-danja ho an’ny be sy nymaro', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/22/mg-addurus_almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/mg/content/22'),
    RisalaBook(id: '384_mg', title: 'IREO FOMBA AHAZOANA NY FIAINANA FENO FAHASAMBARANA', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/384/mg-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/mg/content/384'),
  ],

  // ── Bosnian (bs) ── 4 books ──────────────────────────
  'bs': [
    RisalaBook(id: '563_bs', title: 'Opis Poslanikovog namaza, sallallahu alejhi ve sellem', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/563/bs_kaifiyah-solah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bs/content/563'),
    RisalaBook(id: '541_bs', title: 'Tri osnovna načela i njihovi dokazi', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/541/bs-tsalatsatul_usul-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bs/content/541'),
    RisalaBook(id: '14_bs', title: 'Opće lekcije za svakog muslimana', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/14/bs_addurus-almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bs/content/14'),
    RisalaBook(id: '373_bs', title: 'Uputstva za srećan život', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/373/bs-alwasail_almufidah-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bs/content/373'),
  ],

  // ── Serbian (sr) ── 4 books ──────────────────────────
  'sr': [
    RisalaBook(id: '555_sr', title: 'Начин намаза Посланика, саллаллаху алејхи ве селлем', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/555/sr_kaifiyah-solat-nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sr/content/555'),
    RisalaBook(id: '547_sr', title: 'Три основна начела и њихови докази', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/547/sr-tsalatsatul_usul-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sr/content/547'),
    RisalaBook(id: '8_sr', title: 'Битне лекције за сваког муслимана', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/8/sr_addurus-almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sr/content/8'),
    RisalaBook(id: '512_sr', title: 'КОРИСНА УПУТСТВА ЗА СРЕЋАН ЖИВОТ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/512/sr-alwasail_almufidah-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/sr/content/512'),
  ],

  // ── Romanian (ro) ── 2 books ──────────────────────────
  'ro': [
    RisalaBook(id: '711_ro', title: 'Lecții importante pentru întreaga națiune islamică', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/711/ro-addurus_almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ro/content/711'),
    RisalaBook(id: '378_ro', title: 'Metode eficiente pentru o viață fericită', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/378/ro-alwasail_almufidah-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ro/content/378'),
  ],

  // ── Polish (pl) ── 4 books ──────────────────────────
  'pl': [
    RisalaBook(id: '295_pl', title: 'Sposób Modlitwy Proroka (niech pokój i błogosławieństwo Allaha', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/295/pl-kaifiyah_solat_nabi-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/pl/content/295'),
    RisalaBook(id: '7_pl', title: 'Ważne lekcje dla ogółu społeczności muzułmańskiej', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/7/pl-addurus_almuhimmah-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/pl/content/7'),
    RisalaBook(id: '380_pl', title: 'Środki prowadzące do szczęśliwego życia', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/380/pl-alwasail_almufidah-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/pl/content/380'),
    RisalaBook(id: '286_pl', title: 'Przepisy dotyczące pogrzebów', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/286/pl_ahkamjanaiz.pdf', bookPageUrl: 'https://risala.prh.gov.sa/pl/content/286'),
  ],

  // ── Czech (cs) ── 4 books ──────────────────────────
  'cs': [
    RisalaBook(id: '712_cs', title: 'Způsob modlitby Proroka ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/712/cs-kaifiyah_solat_nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/cs/content/712'),
    RisalaBook(id: '421_cs', title: 'Důležité lekce pro běžné muslimy', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/421/cs_addurus-almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/cs/content/421'),
    RisalaBook(id: '408_cs', title: 'Prospěšné prostředky pro šťastný život', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/408/cs-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/cs/content/408'),
    RisalaBook(id: '468_cs', title: 'Dvě krátká pojednání o almužně (zakátu) a půstu', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/468/cs-risalatan_mujizatan.pdf', bookPageUrl: 'https://risala.prh.gov.sa/cs/content/468'),
  ],

  // ── Hungarian (hu) ── 10 books ──────────────────────────
  'hu': [
    RisalaBook(id: '344_hu', title: 'Hogyan imádkozott a Próféta ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/344/hu_kaifiyah-solat-nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hu/content/344'),
    RisalaBook(id: '45_hu', title: 'A három alaptétel és ezek bizonyítékai', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/45/hu_tsalatsatul-usul.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hu/content/45'),
    RisalaBook(id: '6_hu', title: 'Fontos leckék a muszlim Nép számára', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/6/hu_addurus-almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hu/content/6'),
    RisalaBook(id: '538_hu', title: 'Olyan kötelező tudás, amelyről egy muszlim nem lehet', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/538/hu-ma_la_yasa-3.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hu/content/538'),
    RisalaBook(id: '682_hu', title: 'A Hiteles Hitvallás és mindaz, ami azzal ellentétes', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/682/hu-aqidah_sohihah_wama.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hu/content/682'),
    RisalaBook(id: '706_hu', title: 'A boldog élethez vezető hasznos eszközök', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/706/hu_alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hu/content/706'),
    RisalaBook(id: '287_hu', title: 'A temetések vallási szabályai', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/287/hu_ahkamjanaiz.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hu/content/287'),
    RisalaBook(id: '451_hu', title: 'Vallásjogi szabályozások és előírások a tisztasággal, az imával', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/451/hu-min_ahkam_fiqhiyah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hu/content/451'),
    RisalaBook(id: '681_hu', title: 'A Tawhíd Őrzése', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/681/hu-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hu/content/681'),
    RisalaBook(id: '685_hu', title: 'A varázslás és a jóslás vallásjogi megítélése és', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/685/hu-hukm_sihr.pdf', bookPageUrl: 'https://risala.prh.gov.sa/hu/content/685'),
  ],

  // ── Lithuanian (lt) ── 2 books ──────────────────────────
  'lt': [
    RisalaBook(id: '559_lt', title: 'Svarbios pamokos visai musulmonų bendruomenei', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/559/lt_addurus_almuhimmah_v2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/lt/content/559'),
    RisalaBook(id: '385_lt', title: 'Naudingos priemonės laimingam gyvenimui', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/385/lt-alwasail_almufidah-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/lt/content/385'),
  ],

  // ── Danish (da) ── 3 books ──────────────────────────
  'da': [
    RisalaBook(id: '374_da', title: 'De vigtige lektioner for den islamiske nation', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/374/da-addurus_almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/da/content/374'),
    RisalaBook(id: '537_da', title: 'Det, som en muslim ikke må være uvidende', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/537/da_malaayasaamuslim.pdf', bookPageUrl: 'https://risala.prh.gov.sa/da/content/537'),
    RisalaBook(id: '990_da', title: 'Beskrivelsen af Hajj', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/990/da_sifatulhaj.pdf', bookPageUrl: 'https://risala.prh.gov.sa/da/content/990'),
  ],

  // ── Vietnamese (vi) ── 7 books ──────────────────────────
  'vi': [
    RisalaBook(id: '608_vi', title: 'Cách Thức Hành Lễ Salah Của Nabi ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/608/vi-kaifiyah_solat_nabi-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/vi/content/608'),
    RisalaBook(id: '796_vi', title: 'Ba Nền Tảng Căn Bản Và Bằng Chứng', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/796/vi-tsalatsatul_usul.pdf', bookPageUrl: 'https://risala.prh.gov.sa/vi/content/796'),
    RisalaBook(id: '9_vi', title: 'Kiến Thức Căn Bản Cho Người Muslim', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/9/vi-addurus_almuhimmah-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/vi/content/9'),
    RisalaBook(id: '861_vi', title: 'Kiến Thức Căn Bản, Người Muslim Cần Biết', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/861/vi-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/vi/content/861'),
    RisalaBook(id: '702_vi', title: 'Các Thông Điệp Hữu Ích Cho Cuộc Sống', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/702/vi-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/vi/content/702'),
    RisalaBook(id: '609_vi', title: 'Các Giáo Luật Thực Hành Về Việc Thanh', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/609/vi_min_alahkam_alfiqhiyyah_v2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/vi/content/609'),
    RisalaBook(id: '986_vi', title: 'Vị Thiên Sứ của Islam, Muhammad ﷺ (cầu', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/986/vi_rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/vi/content/986'),
  ],

  // ── Filipino (tl) ── 15 books ──────────────────────────
  'tl': [
    RisalaBook(id: '202_tl', title: 'Ang Paraan ng Pagsasagawa ng Umrah', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/202/tl_sifat-umrah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/202'),
    RisalaBook(id: '205_tl', title: 'Ang Pamamaraan ng Ṣalāh ng Propeta ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/205/tl_kaifiyah-solat-nabi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/205'),
    RisalaBook(id: '327_tl', title: 'Ang mga Patakaran sa Handog, mga Alay, at', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/327/tl_ahkamalhadi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/327'),
    RisalaBook(id: '204_tl', title: 'Ang mga Mahalagang Aralin Para sa Kamadlaan ng', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/204/tl_addurus-almuhimmah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/204'),
    RisalaBook(id: '434_tl', title: 'Ako ay Muslim', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/434/tl-ana_muslim-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/434'),
    RisalaBook(id: '488_tl', title: 'Isang Mensahe Hinggil sa mga Pagdurugong Likas sa', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/488/tl-risalah_fi_dima-3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/488'),
    RisalaBook(id: '326_tl', title: 'Ang Kainaman ng Sampung Araw ng Dhulḥijjah', description: '', category: 'Occasions', icon: '🌟', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/326/TL_fadhlu_dhilhijjah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/326'),
    RisalaBook(id: '311_tl', title: 'Ang Tumpak na Paniniwala at ang Sumasalungat Dito', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/311/tl-aqidah_sohihah_wama_yudoduha-3.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/311'),
    RisalaBook(id: '203_tl', title: 'Ang mga Kaparaanang Napakikinabangan Para sa Maligayang Buhay', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/203/tl_wasail.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/203'),
    RisalaBook(id: '443_tl', title: 'Ang Sugo ng Islām na si Muḥammad –', description: '', category: 'Seerah', icon: '🕌', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/443/tl-rasul_islam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/443'),
    RisalaBook(id: '307_tl', title: 'Pag-iingat sa TAWHID', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/307/tl-hirasah_tauhid-3.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/307'),
    RisalaBook(id: '313_tl', title: 'Ang Kahatulan sa Panggagaway at Panghuhula at ang', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/313/tl-hukm_sihr-3.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/313'),
    RisalaBook(id: '469_tl', title: 'Dalawang Pinaiksing Mensahe Kaugnay sa Zakāh at Pag-aayuno', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/469/tl-risalatan-1.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/469'),
    RisalaBook(id: '261_tl', title: 'Ilan sa mga Patakaran ng Pag-aayuno', description: '', category: 'Fasting & Zakat', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/261/tl_minahkam_assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/261'),
    RisalaBook(id: '440_tl', title: 'Sino ang lumikha ng Sansinukob? Sino ang lumikha', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/440/tl-man_kholaqo_akaun-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tl/content/440'),
  ],

  // ── Lao (lo) ── 3 books ──────────────────────────
  'lo': [
    RisalaBook(id: '558_lo', title: 'ວິທີນະມາຊການຕາມແບບຢ່າງຂອງທ່ານນະບີ ﷺ', description: '', category: 'Prayer', icon: '🙏', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/558/lo-kaifiyah_solat_nabi-2.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/lo/content/558'),
    RisalaBook(id: '494_lo', title: 'ບົດຮຽນສຳຄັນສຳຫຼັບຜູ້ຄົນທົ່ວໄປ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/494/lo-addurus_almuhimmah-2.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/lo/content/494'),
    RisalaBook(id: '566_lo', title: 'ແນວທາງທີ່ເປັນປະໂຫຍດເພື່ອຊີວິດແຫ່ງຄວາມຜາສຸກ', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/566/lo_alwasail-almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/lo/content/566'),
  ],

  // ── Burmese (my) ── 1 books ──────────────────────────
  'my': [
    RisalaBook(id: '916_my', title: 'ပျော်ရွှင်သောဘဝအတွက် အသုံးဝင်သောနည်းလမ်းများ။', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/916/my_wasailmufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/my/content/916'),
  ],

  // ── Khmer (km) ── 4 books ──────────────────────────
  'km': [
    RisalaBook(id: '918_km', title: 'ការស្រាវជ្រាវបញ្ជាក់ និងការពន្យល់លម្អិតអំពីបញ្ហាជាច្រើននៃហាជ្ជី អំុរ៉ោះ និងហ្ស៊ីយ៉ារ៉ោះ(ការទស្សនកិច្ច) យោងតាមគម្ពីរគួរអាន និងសុណ្ណ', description: '', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/918/km-attahqiq_walidoh.pdf', bookPageUrl: 'https://risala.prh.gov.sa/km/content/918'),
    RisalaBook(id: '921_km', title: 'សេចក្តីបកស្រាយសង្ខេបអំពីគោលជំនឿឥស្លាម', description: '', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/921/km_nubzah_fil_aqeedah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/km/content/921'),
    RisalaBook(id: '915_km', title: 'សារស្តីអំពីឈាមធម្មជាតិរបស់ស្ត្រី', description: '', category: 'Fiqh', icon: '📋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/915/km-risalah_fi_dima.pdf', bookPageUrl: 'https://risala.prh.gov.sa/km/content/915'),
    RisalaBook(id: '914_km', title: 'មធ្យោបាយដ៏មានប្រសិទ្ធិភាពដើម្បីជីវិតមានសុភមង្គល', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/914/km-alwasail_almufidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/km/content/914'),
  ],

  // ── Kurdish (ku) ── 1 books ──────────────────────────
  'ku': [
    RisalaBook(id: '405_ku', title: 'ئامراز وڕێکارە بەسوودەكان بۆ گەیشتن بە ژیانێكی بەختەوەر', description: '', category: 'General', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/405/ku-alwasail_almufidah-1.0.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ku/content/405'),
  ],

  };

  // ── Get Books for Language ────────────────────────
  static List<RisalaBook> getBooksForLanguage(String langCode) {
    return booksByLanguage[langCode] ?? booksByLanguage['en'] ?? [];
  }

  // ── Get All Categories ────────────────────────────
  static List<String> getCategoriesForLanguage(String langCode) {
    final books = getBooksForLanguage(langCode);
    return books.map((b) => b.category).toSet().toList();
  }

  // ── All supported language codes ──────────────────
  static List<String> get supportedLanguages => booksByLanguage.keys.toList();

  // ── Download Directory ────────────────────────────
  Future<String> getRisalaDirectory(String langCode) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/risala/$langCode');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  // ── PDF File Path ─────────────────────────────────
  Future<String> getBookPath(String langCode, String bookId) async {
    final dir = await getRisalaDirectory(langCode);
    return '$dir/$bookId.pdf';
  }

  // ── Check if Downloaded ───────────────────────────
  Future<bool> isBookDownloaded(String langCode, String bookId) async {
    try {
      final path = await getBookPath(langCode, bookId);
      final file = File(path);
      if (!await file.exists()) return false;
      final size = await file.length();
      return size > 10 * 1024;
    } catch (_) {
      return false;
    }
  }

  Future<int> getDownloadedCount(String langCode) async {
    final books = getBooksForLanguage(langCode);
    int count = 0;
    for (final book in books) {
      if (await isBookDownloaded(langCode, book.id)) {
        count++;
      }
    }
    return count;
  }

  // ── Download Single Book ──────────────────────────
  Future<bool> downloadBook({
    required String langCode,
    required RisalaBook book,
    required void Function(double) onProgress,
  }) async {
    try {
      final path = await getBookPath(langCode, book.id);
      final partPath = '$path.part';
      _cancelToken = CancelToken();

      final pdfUrl = book.pdfUrl;
      if (pdfUrl == null || pdfUrl.isEmpty) {
        print('❌ No PDF URL for: ${book.title}');
        return false;
      }

      print('📥 Downloading: ${book.title}');
      print('🔗 URL: ${pdfUrl}');

      try {
        await _dio.download(
          pdfUrl,
          partPath,
          cancelToken: _cancelToken,
          deleteOnError: true,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 '
                  'like Mac OS X) AppleWebKit/605.1.15',
              'Accept': 'application/pdf,application/octet-stream,*/*',
              'Referer': book.bookPageUrl ?? 'https://risala.prh.gov.sa/',
            },
          ),
          onReceiveProgress: (received, total) {
            if (total > 0) {
              onProgress((received / total).clamp(0.0, 1.0));
            } else {
              onProgress((received / (5 * 1024 * 1024)).clamp(0.0, 0.9));
            }
          },
        );

        final partFile = File(partPath);
        if (await partFile.exists()) {
          final size = await partFile.length();
          final isValidPdf = await _verifyPdf(partPath);

          if (size > 10 * 1024 && isValidPdf) {
            await partFile.rename(path);
            print('✅ Downloaded: ${book.title} (${(size / 1024).toStringAsFixed(0)} KB)');
            return true;
          } else {
            print('⚠️ Invalid PDF, deleting...');
            await partFile.delete().catchError((_) {});
          }
        }
      } catch (urlError) {
        print('❌ Download failed: ${urlError}');
        File(partPath).delete().catchError((_) {});
      }

      print('⚠️ Failed to download: ${book.title}');
      return false;
    } catch (e) {
      print('❌ Download error: ${book.title} - $e');
      return false;
    }
  }

  // ── Verify PDF header ─────────────────────────────
  Future<bool> _verifyPdf(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.openRead(0, 5).first;
      if (bytes.length >= 4) {
        return bytes[0] == 0x25 && // %
            bytes[1] == 0x50 &&    // P
            bytes[2] == 0x44 &&    // D
            bytes[3] == 0x46;      // F
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ── Download ALL Books for Language ───────────────
  Future<void> downloadAllBooks({
    required String langCode,
    required void Function(String bookTitle, int current, int total, double progress) onProgress,
    required void Function() onComplete,
    required void Function(String error) onError,
  }) async {
    final books = getBooksForLanguage(langCode);
    final total = books.length;

    for (int i = 0; i < total; i++) {
      final book = books[i];

      if (await isBookDownloaded(langCode, book.id)) {
        onProgress(book.title, i + 1, total, 1.0);
        continue;
      }

      onProgress(book.title, i + 1, total, 0.0);

      await downloadBook(
        langCode: langCode,
        book: book,
        onProgress: (progress) {
          onProgress(book.title, i + 1, total, progress);
        },
      );
    }

    onComplete();
  }

  void cancelDownload() {
    _cancelToken?.cancel('Cancelled');
  }

  // ── Delete All Books ──────────────────────────────
  Future<void> deleteAllBooks(String langCode) async {
    try {
      final dir = Directory(await getRisalaDirectory(langCode));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      print('❌ Delete error: $e');
    }
  }

  // ── Get total downloaded size ─────────────────────
  Future<String> getTotalSize(String langCode) async {
    try {
      final dirPath = await getRisalaDirectory(langCode);
      final dir = Directory(dirPath);
      if (!await dir.exists()) return '0 MB';

      int total = 0;
      await for (final f in dir.list()) {
        if (f is File) total += await f.length();
      }
      return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '0 MB';
    }
  }
}

// ── Risala Book Model ──────────────────────────────────
class RisalaBook {
  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;
  final String? pdfUrl;
  final String? bookPageUrl;

  const RisalaBook({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.pdfUrl,
    this.bookPageUrl,
  });

  String get fallbackUrl => bookPageUrl ?? '';
  String get primaryUrl => pdfUrl ?? bookPageUrl ?? '';
  String get mirrorUrl => pdfUrl ?? '';
  List<String> get allUrls => [
    if (pdfUrl != null && pdfUrl!.isNotEmpty) pdfUrl!,
    if (bookPageUrl != null && bookPageUrl!.isNotEmpty) bookPageUrl!,
  ];
}
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class RisalaService {
//   static final RisalaService _instance = RisalaService._internal();
//   factory RisalaService() => _instance;
//   RisalaService._internal();

//   final Dio _dio = Dio(BaseOptions(
//     connectTimeout: const Duration(minutes: 5),
//     receiveTimeout: const Duration(minutes: 10),
//     sendTimeout: const Duration(minutes: 5),
//     followRedirects: true,
//     maxRedirects: 15,
//     validateStatus: (s) => s != null && s < 500,
//     headers: {
//       'User-Agent':
//           'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) '
//           'AppleWebKit/605.1.15 (KHTML, like Gecko) '
//           'Mobile/15E148',
//       'Accept': 'application/pdf,application/octet-stream,*/*',
//       'Accept-Language': 'en-US,en;q=0.9',
//       'Referer': 'https://risala.prh.gov.sa/',
//     },
//   ));

//   CancelToken? _cancelToken;

//   // ── REAL PDF URLs (extracted from website) ────────
//   static const Map<String, List<RisalaBook>> booksByLanguage = {
//   // ── ENGLISH ───────────────────────────────────────
//   'en': [
//     RisalaBook(id: 'fasting_en', title: 'Some Rulings on Fasting', description: 'Rulings related to fasting in Islam', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/415/en_minahkam_assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/415'),
//     RisalaBook(id: 'creed_en', title: 'The Sound Creed', description: 'Explanation of correct Islamic creed', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/483/en_alaqida_alhsahihah_new.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/483'),
//     RisalaBook(id: 'must_know_en', title: 'What A Muslim Must Know', description: 'Essential knowledge for every Muslim', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/511/en_malaa_yasaa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/511'),
//     RisalaBook(id: 'umrah_en', title: 'How to do Umrah', description: 'Step by step guide for Umrah', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/940/en_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/940'),
//     RisalaBook(id: 'tawhid_en', title: 'Safeguarding Tawhid', description: 'Protecting the oneness of Allah', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/397/en-hirasah_tauhid-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/397'),
//   ],

//   // ── URDU ──────────────────────────────────────────
//   'ur': [
//     RisalaBook(id: 'fasting_ur', title: 'روزے کے بعض احکام', description: 'روزے سے متعلق اسلامی احکام', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/231/ur-min_ahkam_siyam-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/231'),
//     RisalaBook(id: 'creed_ur', title: 'تحقیق والی عقیدہ', description: 'صحیح اسلامی عقیدہ کی تشریح', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/178/ur_tahqiq_waliidohv3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/178'),
//     RisalaBook(id: 'must_know_ur', title: 'مسلمان کو جاننا چاہیے', description: 'ہر مسلمان کے لیے ضروری معلومات', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/211/ur-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/211'),
//     RisalaBook(id: 'umrah_ur', title: 'عمرے کا طریقہ', description: 'عمرہ کرنے کا طریقہ', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/933/ur_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/933'),
//     RisalaBook(id: 'tawhid_ur', title: 'حفاظت توحید', description: 'توحید کی حفاظت', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/173/ur-hirasah_tauhid-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/173'),
//   ],

//   // ── ARABIC ────────────────────────────────────────
//   'ar': [
//     RisalaBook(id: 'fasting_ar', title: 'من أحكام الصيام', description: 'أحكام الصيام في الإسلام', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/252/ar_minahkamsiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/252'),
//     RisalaBook(id: 'creed_ar', title: 'نبذة في العقيدة الإسلامية', description: 'شرح العقيدة الصحيحة', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/381/ar-nubzah_fil_aqidah-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/381'),
//     RisalaBook(id: 'must_know_ar', title: 'ما يجب على المسلم معرفته', description: 'المعرفة الأساسية لكل مسلم', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/244/ar_ahkamhadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/244'),
//     RisalaBook(id: 'umrah_ar', title: 'صفة العمرة', description: 'دليل العمرة خطوة بخطوة', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/939/ar_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/939'),
//     RisalaBook(id: 'tawhid_ar', title: 'حراسة التوحيد', description: 'حماية التوحيد', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/397/ar-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/397'),
//   ],

//   // ── TURKISH (tr) ──────────────────────────────────
//   'tr': [
//     RisalaBook(id: 'fasting_tr', title: 'Zekât ve Oruç Hakkında Veciz İki Risale', description: 'Oruç ile ilgili hükümler', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/475/tr-risalatan_mujizatan.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/475'),
//     RisalaBook(id: 'creed_tr', title: 'İslam Akidesinin Temel İlkeleri', description: 'İslam inancının temelleri', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/795/tr-nubzah_fil_aqidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/795'),
//     RisalaBook(id: 'must_know_tr', title: 'Müslümanın Kesin Olarak Bilmesi Gereken Konular', description: 'Her Müslümanın bilmesi gerekenler', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/858/tr-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/858'),
//     RisalaBook(id: 'umrah_tr', title: 'Umre Nasıl Yapılır', description: 'Umre rehberi', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/933/tr_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/933'),
//     RisalaBook(id: 'tawhid_tr', title: 'Tevhidi Koruma', description: 'Allah’ın birliğini koruma', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/173/tr-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/173'),
//   ],

//   // ── FRENCH (fr) ───────────────────────────────────
//   'fr': [
//     RisalaBook(id: 'fasting_fr', title: 'Parmi les jugements religieux relatifs au jeûne', description: 'Règles relatives au jeûne', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/818/fr_minahkam_Assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/818'),
//     RisalaBook(id: 'creed_fr', title: 'Résumé de la Croyance Islamique', description: 'Explication de la croyance correcte', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/381/fr-nubzah_fil_aqidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/381'),
//     RisalaBook(id: 'must_know_fr', title: 'Ce que tout Musulman doit savoir', description: 'Connaissances essentielles', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/858/fr-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/858'),
//     RisalaBook(id: 'umrah_fr', title: 'Description de la Oumra', description: 'Guide étape par étape', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/946/fr_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/946'),
//     RisalaBook(id: 'tawhid_fr', title: 'Protection du Tawhid', description: 'Protection de l’unicité d’Allah', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/397/fr-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/397'),
//   ],

//   // ── INDONESIAN (id) ───────────────────────────────
//   'id': [
//     RisalaBook(id: 'fasting_id', title: 'Beberapa Hukum Terkait Puasa', description: 'Hukum-hukum puasa dalam Islam', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/252/id_minahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/252'),
//     RisalaBook(id: 'creed_id', title: 'Ringkasan Akidah Islam', description: 'Penjelasan akidah yang benar', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/381/id-nubzah_fil_aqidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/381'),
//     RisalaBook(id: 'must_know_id', title: 'Hal yang Harus Diketahui Muslim', description: 'Pengetahuan penting bagi Muslim', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/858/id-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/858'),
//     RisalaBook(id: 'umrah_id', title: 'Tata Cara Umrah', description: 'Panduan Umrah langkah demi langkah', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/933/id_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/933'),
//     RisalaBook(id: 'tawhid_id', title: 'Menjaga Tauhid', description: 'Melindungi Tauhid Allah', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/173/id-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/173'),
//   ],

//   // ── BENGALI (bn) ──────────────────────────────────
//   'bn': [
//     RisalaBook(id: 'fasting_bn', title: 'রোজার বিধি-বিধান', description: 'রোজা সম্পর্কিত ইসলামী বিধান', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/252/bn_minahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/252'),
//     RisalaBook(id: 'must_know_bn', title: 'একজন মুসলিমের জানা উচিত', description: 'প্রত্যেক মুসলিমের জন্য অপরিহার্য জ্ঞান', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/348/bn-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/348'),
//   ],
// };


//   // ── Get Books for Language ────────────────────────
//   static List<RisalaBook> getBooksForLanguage(String langCode) {
//     return booksByLanguage[langCode] ?? booksByLanguage['en'] ?? [];
//   }

//   // ── Get All Categories ────────────────────────────
//   static List<String> getCategoriesForLanguage(String langCode) {
//     final books = getBooksForLanguage(langCode);
//     return books.map((b) => b.category).toSet().toList();
//   }

//   // ── Download Directory ────────────────────────────
//   Future<String> getRisalaDirectory(String langCode) async {
//     final base = await getApplicationDocumentsDirectory();
//     final dir = Directory('${base.path}/risala/$langCode');
//     if (!await dir.exists()) {
//       await dir.create(recursive: true);
//     }
//     return dir.path;
//   }

//   // ── PDF File Path ─────────────────────────────────
//   Future<String> getBookPath(String langCode, String bookId) async {
//     final dir = await getRisalaDirectory(langCode);
//     return '$dir/$bookId.pdf';
//   }

//   // ── Check if Downloaded ───────────────────────────
//   Future<bool> isBookDownloaded(String langCode, String bookId) async {
//     try {
//       final path = await getBookPath(langCode, bookId);
//       final file = File(path);
//       if (!await file.exists()) return false;
//       final size = await file.length();
//       return size > 10 * 1024;
//     } catch (_) {
//       return false;
//     }
//   }

//   Future<int> getDownloadedCount(String langCode) async {
//     final books = getBooksForLanguage(langCode);
//     int count = 0;
//     for (final book in books) {
//       if (await isBookDownloaded(langCode, book.id)) {
//         count++;
//       }
//     }
//     return count;
//   }

//   // ── Download Single Book ──────────────────────────
//   Future<bool> downloadBook({
//     required String langCode,
//     required RisalaBook book,
//     required void Function(double) onProgress,
//   }) async {
//     try {
//       final path = await getBookPath(langCode, book.id);
//       final partPath = '$path.part';
//       _cancelToken = CancelToken();

//       print('📥 Downloading: ${book.title}');

//       // Use direct PDF URL
//       final pdfUrl = book.pdfUrl;
//       if (pdfUrl == null || pdfUrl.isEmpty) {
//         print('❌ No PDF URL for: ${book.title}');
//         return false;
//       }

//       print('🔗 Downloading from: $pdfUrl');

//       try {
//         final response = await _dio.download(
//           pdfUrl,
//           partPath,
//           cancelToken: _cancelToken,
//           deleteOnError: true,
//           options: Options(
//             responseType: ResponseType.bytes,
//             followRedirects: true,
//             headers: {
//               'User-Agent':
//                   'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 '
//                   'like Mac OS X) AppleWebKit/605.1.15',
//               'Accept': 'application/pdf,application/octet-stream,*/*',
//               'Referer': book.bookPageUrl ?? 'https://risala.prh.gov.sa/',
//             },
//           ),
//           onReceiveProgress: (received, total) {
//             if (total > 0) {
//               onProgress((received / total).clamp(0.0, 1.0));
//             } else {
//               onProgress((received / (5 * 1024 * 1024)).clamp(0.0, 0.9));
//             }
//           },
//         );

//         // Verify it's a real PDF
//         final partFile = File(partPath);
//         if (await partFile.exists()) {
//           final size = await partFile.length();
//           final isValidPdf = await _verifyPdf(partPath);

//           if (size > 10 * 1024 && isValidPdf) {
//             await partFile.rename(path);
//             print('✅ Downloaded: ${book.title} (${(size / 1024).toStringAsFixed(0)} KB)');
//             return true;
//           } else {
//             print('⚠️ Invalid PDF, deleting...');
//             await partFile.delete().catchError((_) {});
//           }
//         }
//       } catch (urlError) {
//         print('❌ Download failed: $urlError');
//         File(partPath).delete().catchError((_) {});
//       }

//       print('⚠️ Failed to download: ${book.title}');
//       return false;
//     } catch (e) {
//       print('❌ Download error: ${book.title} - $e');
//       return false;
//     }
//   }

//   // ── Verify PDF is real ────────────────────────────
//   Future<bool> _verifyPdf(String filePath) async {
//     try {
//       final file = File(filePath);
//       final bytes = await file.openRead(0, 5).first;
//       if (bytes.length >= 4) {
//         return bytes[0] == 0x25 && // %
//             bytes[1] == 0x50 &&    // P
//             bytes[2] == 0x44 &&    // D
//             bytes[3] == 0x46;      // F
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   // ── Download ALL Books for Language ───────────────
//   Future<void> downloadAllBooks({
//     required String langCode,
//     required void Function(String bookTitle, int current, int total, double progress) onProgress,
//     required void Function() onComplete,
//     required void Function(String error) onError,
//   }) async {
//     final books = getBooksForLanguage(langCode);
//     final total = books.length;

//     for (int i = 0; i < total; i++) {
//       final book = books[i];

//       if (await isBookDownloaded(langCode, book.id)) {
//         onProgress(book.title, i + 1, total, 1.0);
//         continue;
//       }

//       onProgress(book.title, i + 1, total, 0.0);

//       await downloadBook(
//         langCode: langCode,
//         book: book,
//         onProgress: (progress) {
//           onProgress(book.title, i + 1, total, progress);
//         },
//       );
//     }

//     onComplete();
//   }

//   void cancelDownload() {
//     _cancelToken?.cancel('Cancelled');
//   }

//   // ── Delete All Books ──────────────────────────────
//   Future<void> deleteAllBooks(String langCode) async {
//     try {
//       final dir = Directory(await getRisalaDirectory(langCode));
//       if (await dir.exists()) {
//         await dir.delete(recursive: true);
//       }
//     } catch (e) {
//       print('❌ Delete error: $e');
//     }
//   }

//   // ── Get total size ────────────────────────────────
//   Future<String> getTotalSize(String langCode) async {
//     try {
//       final dirPath = await getRisalaDirectory(langCode);
//       final dir = Directory(dirPath);
//       if (!await dir.exists()) return '0 MB';

//       int total = 0;
//       await for (final f in dir.list()) {
//         if (f is File) total += await f.length();
//       }
//       return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
//     } catch (_) {
//       return '0 MB';
//     }
//   }
// }

// // ── Risala Book Model ──────────────────────────────────
// class RisalaBook {
//   final String id;
//   final String title;
//   final String description;
//   final String category;
//   final String icon;
//   final String? pdfUrl;       // Direct PDF download URL
//   final String? bookPageUrl;  // Webpage URL for "Read Online"

//   const RisalaBook({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.icon,
//     this.pdfUrl,
//     this.bookPageUrl,
//   });

//   // Backward compatibility - so old code still works
//   String get fallbackUrl => bookPageUrl ?? '';
//   String get primaryUrl => pdfUrl ?? bookPageUrl ?? '';
//   String get mirrorUrl => pdfUrl ?? '';
//   List<String> get allUrls => [
//     if (pdfUrl != null && pdfUrl!.isNotEmpty) pdfUrl!,
//     if (bookPageUrl != null && bookPageUrl!.isNotEmpty) bookPageUrl!,
//   ];
// }

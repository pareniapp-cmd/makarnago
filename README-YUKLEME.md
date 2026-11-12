# Makarna Kaçış: App Store'a yükleme rehberi

Bu klasör oyunu bir iPhone uygulamasına çevirmek için gereken her şeyi içerir. Sırayla ilerle.

> **Mac'in yoksa** önce `CODEMAGIC-REHBERI.md` dosyasını oku: Xcode adımlarını (3. bölüm) Codemagic'in bulut Mac'i yapıyor. Bu rehberdeki mağaza, gizlilik, dil ve reklam bölümleri yine geçerli. Bundle ID: `com.makarnago.app`.

> Dürüst not: Apple'a yüklemeyi senin Mac'inde sen yapmak zorundasın. Ben Xcode çalıştıramam, hesaplarını açamam, uygulamayı gönderemem. Aşağıdaki adımlar güncel kaynaklardan doğrulandı (Kasım 2026), ama Apple kuralları değişir, tıkanırsan ilgili Apple sayfasına bak.

## 0) Klasörde ne var

| Dosya | Ne işe yarıyor |
|---|---|
| `www/index.html` | Oyunun kendisi (tek dosya). Web sürümüyle aynı, iki fark: titreşim yerel eklentiyle, çift dokunup yakınlaştırma kapalı. |
| `package.json`, `capacitor.config.json` | Capacitor proje ayarları. `appId` `com.makarnago.app` olarak ayarlı, değiştirmek istersen CODEMAGIC-REHBERI.md'ye bak. |
| `assets/icon-1024.png` | Uygulama simgesi, 1024×1024, saydamlık yok. |
| `screenshots/<dil>/` | Her dil için (`tr`, `en`, `es`, `pt`, `ru`) 7 ekran görüntüsü, tam 1320×2868 (iPhone 6.9" boyutu), üstte yerelleştirilmiş başlıkla, JPEG. |
| `store/metadata-*.md` | 5 dilde mağaza metinleri (tr, en, es, pt-BR, ru), uzunluk sınırları kontrol edildi. |
| `store/` | Ayrıca gizlilik politikası şablonu ve inceleme notları. |

## 1) Hesaplar ve araçlar (başlamadan önce)

1. **Apple Developer Program:** developer.apple.com/programs/enroll . Yıllık 99 USD (yerel para birimiyle gösterilir). Bireysel kayıt genelde bir gün içinde onaylanır. Apple Kimliği, iki adımlı doğrulama ve kimlik belgesi gerekir.
2. **Mac + Xcode 26:** Nisan 2026'dan beri App Store'a yüklenen uygulamalar Xcode 26 ve iOS 26 SDK ile derlenmiş olmalı. Mac yoksa bulut Mac kiralama (MacinCloud benzeri) ya da macOS derleme sunan CI servisleri seçenek, ama bunlarla ilgili güncel durumu kendin kontrol et.
3. **Node.js** (LTS sürümü).
4. **Gizlilik politikası için bir web adresi** (Apple zorunlu tutar). `store/gizlilik-politikasi-sablon.md` içeriğini bir sayfaya koy (GitHub Pages, Notion yayını, kendi siten).
5. (Reklam istiyorsan) **AdMob hesabı**: admob.google.com

## 2) Projeyi kur

```bash
cd makarna-ios
# 1) capacitor.config.json içinde appId zaten com.makarnago.app
npm install
npx cap add ios
npx cap sync ios
npx cap open ios      # Xcode açılır
```

Sürüm uyuşmazlığı hatası alırsan: `npm install @capacitor/core@latest @capacitor/ios@latest @capacitor/haptics@latest @capacitor/cli@latest`

## 3) Xcode'da yapılacaklar

1. Sol listeden **App** hedefini seç.
2. **General**:
   - Display Name: `Makarna Kaçış`
   - Bundle Identifier: `capacitor.config.json` ile aynı olmalı
   - Version `1.0`, Build `1`
   - Deployment Info: **iPhone** yalnızca (iPad seçili değilse iPad ekran görüntüsü istemez), Orientation: yalnız **Portrait**
3. **Signing & Capabilities**: Team olarak kendi hesabını seç, "Automatically manage signing" açık kalsın.
4. **Simge:** `Assets.xcassets > AppIcon` içine `assets/icon-1024.png` dosyasını sürükle.
5. **Info.plist**: `ITSAppUsesNonExemptEncryption` anahtarını **NO** yap (şifreleme açıklama sorusunu atlatır).
6. Bir iPhone'u bağlayıp (ya da simülatörde) çalıştır, şunlara bak: ses geliyor mu, titreşim var mı, sürükleme akıcı mı, paylaşma çalışıyor mu, sessiz moddayken ses duyuluyor mu.
7. **Product > Archive**, sonra **Distribute App > App Store Connect > Upload**.

## 4) App Store Connect (appstoreconnect.apple.com)

1. **My Apps > + > New App**: Platform iOS, Ad `Makarna Kaçış`, ana dil Türkçe, Bundle ID (listeden), SKU (istediğin kısa bir kod).
2. **App Information**: Kategori **Games > Arcade** (ikincil: Action ya da Casual). Gizlilik politikası URL'si.
3. **Pricing and Availability**: Ücretsiz.
4. **Sürüm sayfası**: `store/metadata-tr.md` içindeki metinleri yapıştır (Alt başlık, Tanıtım metni, Açıklama, Anahtar kelimeler, Yenilikler). İngilizce için `metadata-en.md`.
5. **Ekran görüntüleri:** Her dil için `screenshots/<dil>/` içindeki 7 dosyayı o dilin **6.9" iPhone** alanına yükle (aşağıdaki "Diller" bölümüne bak). En az 1 set zorunlu, en fazla 10 görüntü. Apple 1260×2736, 1290×2796 ya da 1320×2868'i kabul ediyor, bizimkiler 1320×2868.
6. **App Privacy**: Reklam yoksa ve analitik eklemediysen "Data Not Collected". Reklam eklersen aşağıdaki AdMob bölümüne bak.
7. **Age Rating** sorularını dürüst doldur. Oyunda şiddet yok, çatal ve sos çizgi film tarzı. Apple yaş derecelendirme sistemini Ocak 2026'da güncelledi, soruları güncel hâliyle cevapla.
8. **App Review Information**: `store/inceleme-notlari.md` içeriğini yapıştır. İletişim bilgisi ve telefon gerekir.
9. **Build** bölümünde yüklediğin sürümü seç (işlenmesi 10-30 dk sürebilir), **Submit for Review**.

**TestFlight (önerilir):** Gönderim öncesi build'i TestFlight'tan 3-5 arkadaşına gönder. Bu, gerçek telefonda sorun yakalamak için en iyi test.

## 4b) Diller

Oyun **5 dilde**: Türkçe, İngilizce, İspanyolca, Brezilya Portekizcesi ve Rusça. Telefonun diline göre kendi seçer, tanımadığı dillerde İngilizce açılır. Oyuncu Ayarlar > Dil düğmesiyle değiştirebilir.

App Store Connect'te her dil için:
1. Sürüm sayfasında sol üstteki dil menüsünden **Add Language**'e basıp Spanish (Spain ya da Mexico), Portuguese (Brazil), Russian ve English'i ekle.
2. Her dilin sayfasına `store/metadata-<dil>.md` içindeki ad, alt başlık, tanıtım metni, anahtar kelimeler ve açıklamayı yapıştır.
3. Her dilin 6.9" alanına `screenshots/<dil>/` içindeki 7 dosyayı yükle.
4. Uygulamanın adı dile göre değişir: Makarna Kaçış, Pasta Escape, Fuga de Pasta, Fuga da Massa, Побег макаронины.

**Dürüst notlar:**
- Çevirileri ben yazdım ve anadili konuşan biri okumadı. Oyun içi espriler ve mağaza metinlerini yayından önce her dilden birine okutmanı öneririm, özellikle ölüm yazıları ve bölüm espirileri için.
- Rusya'da App Store ödemeleri ve erişimi kısıtlı olabilir, o pazarın güncel durumunu kendin kontrol et.
- Yeni dil eklemek için `www/index.html` içindeki çeviri tablosuna bir sütun eklemek yeterli. Almanca, Fransızca, Endonezce, Japonca gibi diller aynı sistemle eklenebilir. Japonca/Çince/Korece (yazı tipi ve satır kırma) ve Arapça (sağdan sola düzen) için ekstra test ve ayar gerekir.

## 5) Reklam (AdMob) kurulumu

Oyunda şu an **reklam kodu yok**. Reklam eklemek için önce hangi tür ve nerede olacağına karar ver, sonra ben koda yerleştirebilirim. Altyapı adımları:

1. admob.google.com'da bir **iOS uygulaması** ekle. **Uygulama Kimliği** çıkar: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`.
2. Reklam birimleri oluştur: önerim **Ödüllü** (ör. "izle, kalkan kazan") ve seyrek **Geçiş (interstitial)**. Banner oyun alanını küçülttüğü için önermem.
3. Eklentiyi kur: `npm install @capacitor-community/admob` ve `npx cap sync ios`. Eklentinin 8. sürümü Capacitor 8 ve iOS 15+ hedefliyor.
4. Xcode > `Info.plist`'e şunları ekle:
   - `GADApplicationIdentifier` = AdMob Uygulama Kimliğin
   - `SKAdNetworkItems`: Google'ın iOS kurulum belgesindeki listenin tamamı (Google'ın kimliği `cstr6suwn9.skadnetwork`)
   - `NSUserTrackingUsageDescription`: örn. "Bu kimlik sana daha uygun reklamlar göstermek için kullanılır."
5. **Geliştirme sırasında Google'ın test reklam kimliklerini kullan**, kendi gerçek reklamlarına kendin tıklama (hesap kapatılma sebebi). Test kimlikleri Google'ın AdMob belgelerinde yazıyor.
6. **Onay penceresi:** AB/Birleşik Krallık kullanıcıları için Google'ın UMP onay formunu kur, iOS'ta takip izni (ATT) penceresi de gerekir.
7. **app-ads.txt:** Geliştirici web sitenin kök dizinine koy: `google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0` (yayıncı kimliğini AdMob'dan al). Bu dosyanın doğru adres altında olması reklam gelirini etkiler.
8. App Store'daki **App Privacy** formunu Google'ın "AdMob için veri açıklaması" sayfasına göre doldur (cihaz kimliği, kullanım verisi, reklam verisi gibi).
9. Gizlilik politikana reklam bölümünü ekle (şablonda hazır).

**Reklam yerleşimi önerim (henüz kodlanmadı):** İlk 3 dakikada ve ilk bölümlerde hiç reklam yok. Ödüllü reklam ölüm ekranında isteğe bağlı bir düğme. Geçiş reklamı en fazla her 5 ölümde bir ve en az 2 dakika arayla, patron bölümlerinde hiç. Zorla izletilen sık reklam, oyunun en büyük değeri olan "bir daha" hissini öldürür.

## 6) Reddedilme riskleri

- **4.3 Spam/Kopya:** Oyunun çekirdeği "boşluktan geç" türü olduğu için en büyük riskin bu. Açıklamada ve notlarda özgün özellikleri öne çıkar (sürükleme kontrolü, 4 patron, 5 makarna çeşidi, kostümler, günlük parkur). Metinlerde ve anahtar kelimelerde başka oyunların adını kullanma.
- **4.2 Minimum işlev (web sitesi sarmalayıcı):** Oyun tamamen cihazın içinde (`www/` klasörü) çalışıyor, internetten içerik çekmiyor. Titreşim yerel eklentiyle, paylaşım yerel menüyle. İnceleme notunda bunu belirt.
- **5.1.1 Gizlilik:** Gizlilik politikası URL'si ve doğru App Privacy formu şart.
- **2.1 Çökme/eksik içerik:** TestFlight ile gerçek telefonda test et.
- Ekran görüntüleri gerçek oyun görüntüsü olmalı (bizimkiler öyle).

## 7) Google Play (isteğe bağlı)

Tek seferlik 25 USD. Yeni kişisel hesaplarda üretime çıkmadan önce kapalı test koşulu olabilir, güncel şartı Play Console'dan kontrol et. Android için `npx cap add android` ile benzer bir akış izlenir.

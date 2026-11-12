# Mac olmadan iPhone'a: Codemagic rehberi

Mac'in olmadığı için Xcode'u Codemagic'in bulut Mac'lerinde çalıştıracağız. Sen kod ve ayar tarafını yönetiyorsun, derleme ve yükleme otomatik oluyor.

> Dürüst not: Bu boru hattını burada çalıştıramadım, yani ilk derlemede küçük hatalar çıkabilir (bu normal). Hata verirse Codemagic'teki hata günlüğünü bana yapıştır, birlikte düzeltiriz.

## Bundle ID
`com.makarnago.app` seçtik. Apple ve Capacitor, kimliğin `com.xxx.yyy` biçiminde, nokta içermesini ister, tek başına `makarna` kabul edilmez. Kimlik dünya genelinde benzersiz olmalı. Kaydederken "zaten alınmış" derse `com.makarnago.app2` ya da `com.makarnago.oyun` gibi değiştir. Değiştirirsen iki yerde de düzelt: `capacitor.config.json` (appId) ve `codemagic.yaml` (2 yer: `bundle_identifier` ve `BUNDLE_ID`).

## Ücret
Codemagic kişisel hesapta ayda **500 dakika ücretsiz macOS M2** veriyor (ekip hesabında yok). Bir Capacitor derlemesi genelde 10-15 dakika sürer, yani ayda yaklaşık 30-40 derleme. Aşımda dakika başı 0,095 USD. Apple Developer üyeliği ayrı: yıllık 99 USD.

## Adım adım

### A) Apple tarafı (tarayıcıdan, Mac gerekmez)
1. **Apple Developer Program'a katıl:** developer.apple.com/programs/enroll . Onay genelde bir gün sürer.
2. **Bundle ID kaydet:** developer.apple.com > Account > Certificates, Identifiers & Profiles > Identifiers > **+** > App IDs > App > Açıklama: `Makarna Kaçış`, Bundle ID: **Explicit** `com.makarnago.app`. Ek yetenek seçmene gerek yok.
3. **App Store Connect'te uygulama kaydı aç:** appstoreconnect.apple.com > My Apps > **+** > New App: iOS, Ad `Makarna Kaçış` (adın alınmışsa Apple söyler, o zaman değiştir), ana dil Türkçe, Bundle ID listeden, SKU `makarna-kacis-1`.
4. **API anahtarı üret:** App Store Connect > Users and Access > **Integrations** > App Store Connect API > **+** > ad `codemagic`, rol **App Manager**. Şunları not al: **Issuer ID**, **Key ID** ve **.p8 dosyasını indir** (Apple bunu yalnızca bir kez indirtir, kaybetme ve kimseyle paylaşma, depoya koyma).

### B) Kod deposu
5. GitHub'da (ya da GitLab/Bitbucket) **özel (private)** bir depo aç.
6. Bu klasörün içeriğini yükle (`.gitignore` hazır, `.p8` dosyası asla yüklenmesin). Tarayıcıdan "Add file > Upload files" ile sürükleyebilirsin. `codemagic.yaml` dosyası deponun ana dizininde olmalı.

### C) Codemagic
7. codemagic.io'ya GitHub hesabınla gir, **kişisel hesapta** kal (ekip kurarsan ücretsiz dakikalar gider).
8. **Add application** > depoyu seç > yapılandırma türü olarak **codemagic.yaml** seç.
9. **Integrations** bölümünde **Developer Portal** (App Store Connect API anahtarı) entegrasyonunu bağla: ad **`codemagic`** (yaml'daki `app_store_connect: codemagic` ile aynı olmalı), Issuer ID, Key ID ve .p8 dosyasını gir.
10. **Start new build** > branch seç > workflow `ios-release` > başlat.

### D) Telefonuna kur
11. Derleme bitince Codemagic .ipa'yı App Store Connect'e yükler (yaml'da `submit_to_testflight: false`, bu iç test için yeterli).
12. App Store Connect > TestFlight > **Internal Testing** > yeni grup > kendini (Apple Kimliğinle) ekle.
13. iPhone'una **TestFlight** uygulamasını kur, davetten Makarna Kaçış'ı yükle ve oyna.
14. Sorun yoksa App Store Connect'te sürüm sayfasını doldur (README-YUKLEME.md > 4. ve 4b. bölümler: metinler, ekran görüntüleri, gizlilik, yaş derecesi), build'i seç, **Submit for Review**.

## Her derlemede ne oluyor (codemagic.yaml)
1. `npm install`, sonra `npx cap add ios` (iOS projesini sıfırdan üretir).
2. `scripts/ios-setup.sh`: görünen ad, şifreleme beyanı, yalnız dikey yön, yalnız iPhone, sürüm/yapı numarası, simge, desteklenen diller.
3. `scripts/localize-name.rb`: ana ekran adını cihaz diline göre değiştirir (en iyi çaba, hata verirse atlanır).
4. Codemagic, API anahtarınla sertifika ve profili kendisi oluşturur/çeker, uygulamayı imzalar ve .ipa derler.
5. .ipa'yı App Store Connect'e yükler. Yapı numarası her derlemede Codemagic'in sayacından artar, Apple'ın "aynı numara" hatası çıkmaz.

## Sık çıkan sorunlar
- **"Bundle identifier not found / no profiles":** Bundle ID'yi A2'de kaydettiğinden ve yaml'daki ile birebir aynı olduğundan emin ol.
- **"Authentication failed":** Issuer ID / Key ID / .p8 eşleşmiyor ya da rol App Manager değil.
- **Xcode sürümü hatası:** yaml'daki `xcode: latest` yeterli olmalı, olmazsa `26.0` gibi sabit sürüm yaz.
- **Simge/alpha hatası:** simge dosyası saydam olmamalı, bizimki 1024×1024 RGB.
- **Ana ekran adı İngilizce kalıyor:** `localize-name.rb` atlanmış demektir, uygulama yine çalışır. Günlükteki mesaja bak, bana yapıştırabilirsin.
- **"Missing Compliance":** `ITSAppUsesNonExemptEncryption` ayarı `ios-setup.sh` ile geliyor, çıkıyorsa günlüğü paylaş.

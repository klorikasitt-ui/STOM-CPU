S.T.O.M. (Stom This Operations Master) - Kapsamlı Proje Dokümantasyonu
1. Proje Genel Bakışı
S.T.O.M. (Stom This Operations Master), mobil ortamda sıfırdan tasarlanmış ve optimize edilmiş 4-bitlik minimalist bir mikroişlemci mimarisidir. Donanım seviyesindeki mantıksal bileşenlerin bir araya getirilmesiyle oluşturulan bu sistem, geleneksel bilgisayar mimarisi ilkelerini en saf haliyle simüle eder.
2. Mimari ve Veri Yolu (Datapath) Yapısı
İşlemcinin temel veri akışı, donanım bileşenleri arasında kusursuz bir döngü oluşturacak şekilde tasarlanmıştır:
 * Temel Döngü: RAM -> ALU -> MUX -> CU -> RAM
 * Veri Yolu Genişliği: 4-bit paralel mimari kullanılarak tasarlanmıştır. Bu sayede veriler hatlar üzerinden eş zamanlı olarak akarak tek çevrimde sonuç üretilmesini sağlar.
 * Geri Besleme Döngüsü (Feedback Loop): ALU ve MUX üzerinden işlenen sonuçlar, tekrar RAM'in veri girişine bağlanarak hesaplama sonuçlarının bellekte saklanmasına olanak tanır.
3. Donanım Bileşenleri ve İşlevleri
 * RAM (Rastgele Erişimli Bellek):
   * Verilerin ve komutların depolandığı temel ünitedir.
   * Hem veri girişi (data in) hem de veri çıkışı (data out) hatlarına sahiptir.
 * ALU (Aritmetik Mantık Birimi):
   * İşlemcinin hesaplama merkezidir.
   * Aritmetik işlemleri aynı anda (hem artırma hem eksiltme gibi) eş zamanlı olarak hesaplayabilir.
 * MUX (Çoklayıcı):
   * ALU'dan gelen farklı hesaplama sonuçları arasından, komutun gereksinimine göre doğru veriyi seçip bir sonraki aşamaya aktaran anahtarlama birimidir.
 * CU (Kontrol Birimi):
   * İşlemcinin orkestra şefi konumundadır.
   * MUX üzerinden hangi sonucun seçileceğini belirler ve RAM, ALU ile diğer birimlerin zamanlamasını koordine eder.
4. Komut ve İşlem Özellikleri
 * İşlem Yeteneği: Hem artırma hem de eksiltme işlemlerini donanımsal olarak aynı anda hesaplayıp, kontrol birimi (CU) denetiminde MUX aracılığıyla seçim yapabilen esnek bir yapıya sahiptir.


*lisans*: GNU GPL ile korunur.

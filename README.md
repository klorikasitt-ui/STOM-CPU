# 🚀 STOM-8 MİMARİSİ (STOM CPU)

> **"Bilmeden başarmak bir kazadır; bilerek başarmak ise imparatorluktur."**

---

## 📖 Genel Bakış
**STOM-8**, 12 yaşındaki vizyoner mühendis **Burak Yakub Güçer** tarafından, 5.75 inçlik kısıtlı bir mobil ekran üzerinde (Proto Circuit Simulator) geliştirilmiş **8-bit sıralı mantık** tabanlı bir mikroişlemci mimarisidir. Bu proje, donanım tasarımının sadece laboratuvarlarda değil, mazoşistçe bir sabırla her yerde yapılabileceğinin kanıtıdır.

---

## 🛠 Teknik Spesifikasyonlar

| Bileşen | Detay |
| :--- | :--- |
| **Mimari** | 8-Bit Sequential Logic |
| **Hafıza (Register)** | 8x D-Type Flip-Flop (256 State) |
| **Lojik Birimi** | 4001 Quad 2-Input NOR Gates |
| **Görselleştirme** | Dual 7-Segment Hexadecimal Display |
| **Stabilite** | 1H Akım Sınırlayıcı (Anti-SG Protokolü) |
| **Geliştirme Ortamı** | Proto (Mobile Edition) |

---

## 🔍 Kritik Durum Kodları (Debug Logs)

Geliştirme sırasında gözlemlenen ve sistemin "karakterini" belirleyen bazı kilit Hexadecimal çıktılar:

* **`9A` / `A9`**: Sistemin matematiksel olarak tutarlı çalıştığını gösteren ilk anlamlı veri döngüleri.
* **`EE` (Error/End)**: `I0` hattı hariç tüm bitlerin aktif olduğu, sistemin bağımlılık sınırlarını zorladığı "Lut Kavmi" modu.
* **`FF`**: 8-bitlik krallığın mutlak sınırı (255).
* **`00` -> `FF`**: Meşhur *Integer Underflow* vakası.

---

## 🏗 Mimari Bağımlılıklar
Bu devre, tıpkı bir **Linux çekirdeği** gibi derin bağımlılıklar içerir:
1.  **CLA (Clock):** Sistemin kalp atışı.
2.  **VDD/SV:** Enerji sürekliliği.
3.  **1H Resistor:** Display'lerin yanmasını ve simülatörün `D1 MAX CURRENT` (SG) hatası vermesini engelleyen hayati organ.

---

## 🚧 Bilinen Sorunlar (Known Issues)
* **Computational Lag:** Devre karmaşıklaştıkça telefonun işlemcisinin ağlaması.
* **Routing Hell:** 5.75 inç ekranda yeşil kabloların birbirine girmesi.
* **Success Paradox:** Başarınca hissedilen o garip duygusuzluk hissi.

---

## 🖋 Geliştirici
**Burak Yakub Güçer**
*Donanım Filozofu & DVPU Kurucusu*

---

> *Bu proje, "nasıl çalıştığını bilmeden başarmanın" verdiği o soğuk mühendislik disipliniyle inşa edilmiştir.*

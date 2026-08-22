# S.T.O.M. CPU (Stom This Operations Master)

Tamamen sıfırdan, kendi kafamda kurduğum bağımsız bir işlemci mimarisi.

## Projenin Hikayesi

Bu mimari telefonda görsel bir simülatör üzerinde tasarlandı. Simülatörün salak kısıtlamaları yüzünden yapı içeride kilitli kaldı. Tasarımın tamamı bana ait; Verilog dilini bilmediğim için mantığı yapay zekaya aktarıp bu koda döktürdüm. Çalıntı falan değil, tamamen özgün bir iş.

## Mimari Şema

```text
+-------------------+
|   Control Unit    |
+---------+---------+
          |
          v
+--------+     +------------+------------+     +--------+
|  PC    +---> |         Datapath        | <-> |  RAM   |
+--------+     +-------------------------+     +--------+
```
Modül Hiyerarşisi
 * stom_top: Kontrol ünitesi, datapath, ALU decoder ve RAM birimlerini birbirine bağlayan üst modül.
 * stom_datapath: Program Sayacı (PC), Register Dosyası, ALU, mux'lar ve ara yazmaçların bulunduğu ana veri yolu.
 * stom_control_unit: FSM tabanlı kontrol merkezi.
 * stom_alu: Aritmetik ve mantıksal işlemlerin döndüğü ana hesaplama birimi.
 * stom_alu_decoder: Komut fonksiyon alanlarını çözen birim.
 * stom_mux2, stom_mux3, stom_mux4: Veri ve kontrol akışını yönlendiren çoklayıcı (multiplexer) modülleri.
 * stom_ram: 1024 kelimelik bellek bloğu.
 * stom_register_file: 32 adet 32-bit register dizisi.
 * stom_register: Enable özellikli temel yazmaç modülü.
 * stom_pc: Program sayacı modülü.
Lisans

Bu proje GNU General Public License v3.0 (GPLv3) ile lisanslanmıştır.


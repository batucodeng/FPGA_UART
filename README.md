Modül 1: Baud Rate Generator
Genel Bakış
UART asenkron bir haberleşme protokolü olduğundan ortak bir saat hattı bulunmaz. Bu modül, 50 MHz sistem saatini bölerek UART alıcı (RX) ve verici (TX) bloklarının ihtiyaç duyduğu zamanlama darbelerini (tick) üretir.

Mimari
Parametrik Tasarım: generic parametreleri sayesinde farklı sistem saatleri ve standart baud hızları için kolayca konfigüre edilebilir.
16x RX Oversampling Tick: Alıcı hattındaki gürültüyü filtrelemek ve bitin tam orta noktasını (center-sampling) yakalayabilmek için baud hızının 16 katı frekansta darbe üretir.
1x TX Tick: Her 16 RX darbesinde bir tetiklenerek vericinin bit iletim periyodunu belirler.
Simülasyon Dalga Formu
baud_gen_1gen.png

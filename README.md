Modül 1: Baud Rate Generator
Genel Bakış
UART asenkron bir haberleşme protokolü olduğundan ortak bir saat hattı bulunmaz. Bu modül, 50 MHz sistem saatini bölerek UART alıcı (RX) ve verici (TX) bloklarının ihtiyaç duyduğu zamanlama darbelerini (tick) üretir.

Mimari
Parametrik Tasarım: generic parametreleri sayesinde farklı sistem saatleri ve standart baud hızları için kolayca konfigüre edilebilir.
16x RX Oversampling Tick: Alıcı hattındaki gürültüyü filtrelemek ve bitin tam orta noktasını (center-sampling) yakalayabilmek için baud hızının 16 katı frekansta darbe üretir.
1x TX Tick: Her 16 RX darbesinde bir tetiklenerek vericinin bit iletim periyodunu belirler.
Simülasyon Dalga Formu
baud_gen_1gen.png

Modül 2: UART Transmitter
Genel Bakış
Paralel 8-bitlik veriyi alıp standart UART protokolüne uygun seri bit dizisine dönüştüren TX bloğudur.

FSM Durumları ve Protokol
IDLE: Hat boşta ve lojik '1' seviyesindedir.
START_BIT: Hatta 1 baud süresi boyunca lojik '0' sürülür.
DATA_BITS: 8 bitlik veri en düşük anlamlı bitten (LSB-first) başlanarak sırayla hatta verilir.
STOP_BIT: Çerçeveyi sonlandırmak için hatta 1 baud süresi boyunca lojik '1' basılır ve 1 çevrimlik tx_done darbesi üretilir.

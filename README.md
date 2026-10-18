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

Modül 3: UART Receiver (Alıcı)
Genel Bakış
Dış dünyadan asenkron olarak gelen seri bit dizisini dinleyen, elektriksel parazitleri filtreleyen ve çerçeveyi çözümleyerek 8-bitlik paralel veriye dönüştüren RX bloğudur.

Mimari ve Koruma Mekanizmaları
Metastability Koruması: Asenkron rx pininden gelen sinyal, saat bölgesine senkronize edilmek üzere ardışık iki flip-flop üzerinden geçirilir.
16x Oversampling & Sahte Start Koruması: Start biti tespit edildiğinde FSM doğrudan veriyi almaya başlamaz; sayacı 7 tick saydırarak bitin tam ortasında hattın hâlâ lojik '0' olduğunu doğrular. Hatta anlık bir gürültü (glitch) oluşmuşsa işlem iptal edilip güvenle IDLE durumuna dönülür.
LSB-First Kaydırma Mantığı: Her 16 tick darbesinde bir (bitin tam ortasında) okunan değer, kaydırma saklayıcısının (shift register) en anlamlı bitine (MSB) yazılıp sağa ötelenir. 8 adım sonunda ilk gelen LSB biti doğru yerine oturur.

FSM Durumları ve Protokol
IDLE: Hat boşta ve lojik '1' seviyesindedir; düşen kenar ('0') gözlenir.
START_BIT: 7 tick sayılarak orta noktada hattın geçerli bir start biti olup olmadığı denetlenir.
DATA_BITS: 8 bitlik veri, her 16 tick'te bir örneklenerek içeri alınır.
STOP_BIT: 16 tick boyunca hattın kural gereği lojik '1' seviyesinde kalıp kalmadığı kontrol edilir. Çerçeve hatasız sonlanmışsa 1 saat çevrimi süresince rx_done bayrağı kaldırılır ve paralel veri çıkışa aktarılır.

Simülasyon Dalga Formu
uart_rx_pho.png

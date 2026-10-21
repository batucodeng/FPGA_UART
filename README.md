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

Modül 4: Top-Level Entegrasyonu ve Echo Loopback
Genel Bakış: uart_baud_gen, uart_rx ve uart_tx modüllerini tek çatı altında toplayan yapısal üst düzey modüldür.
Echo Mekanizması: Alıcının çıkardığı rx_done sinyali doğrudan vericinin tx_start girişine, rx_data veri hattı ise vericinin tx_data girişine bağlanmıştır. Bu sayede harici bir işlemciye gerek kalmadan gelen bayt anında bilgisayara geri basılarak sistem donanım üzerinde test edilebilir.

Modül 5: Komut Çözücü (Command Parser & LED Kontrolcüsü)
Genel Bakış: UART alıcı modülünden paralel olarak aktarılan 8-bitlik ASCII karakterlerini çözümleyen ve gelen komut koduna göre doğrudan donanımsal çevre birimini (LED) süren kontrol bloğudur.

Mimari ve Çalışma Mantığı
Karakter Tabanlı Ayrıştırma: Alıcıdan yeni_paket_geldi darbesi üretildiği anda hatta bulunan gelen_veri baytı denetlenir:
ASCII '1' (0x31): led_cikisi hattı lojik '1' seviyesine çekilir (LED yanar).
ASCII '0' (0x30): led_cikisi hattı lojik '0' seviyesine çekilir (LED söner).
Durum Koruma ve Gürültü Filtreleme: Sistemde tanımlanmamış herhangi bir ASCII karakteri (örneğin 'A' / 0x41) geldiğinde LED'in mevcut lojik seviyesi korunur, geçersiz komutlar yok sayılır.
Kalıcı Durum Saklama: led_durumu dahili saklayıcısı (register), yeni geçerli bir komut gelene veya donanımsal reset uygulanana kadar son durumu hat üzerinde sabit tutar.

Modül 5'i güncelledim:
Tek Saat Çevrimi Tetikleme (One-Clock Pulse): Alıcının ürettiği yeni_paket_geldi bayrağı yalnızca tek bir sistem saati periyodu boyunca aktif kalır; karşılaştırma mantığı sadece bu darbe anında işletilerek gereksiz register yazımları önlenir.

Senkron Kayıt ve Sıfırlama (Synchronous Registering): Durum saklama işlemi 50 MHz sistem saatinin yükselen kenarına (rising_edge(clk)) senkron olarak gerçekleşir. Asenkron rst sinyali geldiğinde led_cikisi anında güvenli lojik '0' seviyesine çekilir.

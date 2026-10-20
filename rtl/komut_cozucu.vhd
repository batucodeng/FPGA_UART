library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity komut_cozucu is
port (
clk : in std_logic;
rst : in std_logic;
yeni_paket_geldi : in std_logic;
gelen_veri : in std_logic_vector(7 downto 0);
led_cikisi : out std_logic
);
end komut_cozucu;

architecture Behavioral of komut_cozucu is

signal led_durumu : std_logic := '0';
begin
surec_komut_isle : process(clk,rst)
begin
if rst = '1' then
led_durumu <= '0';
elsif rising_edge(clk) then
if yeni_paket_geldi = '1' then
if gelen_veri = x"31" then -- klavye '1' karakteri (ascii'si 0x31)
led_durumu <= '1';
elsif gelen_veri = x"30" then -- klavye '0' karakteri (ascii 0x30)
led_durumu <= '0';
end if;
end if;
end if;
end process;

led_cikisi <= led_durumu;

end Behavioral;
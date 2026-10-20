library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_komut_cozucu is 
end tb_komut_cozucu;

architecture Behavioral of tb_komut_cozucu is

component komut_cozucu is
port (
clk : in std_logic;
rst : in std_logic;
yeni_paket_geldi : in std_logic;
gelen_veri : in std_logic_vector(7 downto 0);
led_cikisi : out std_logic
);
end component;

constant clk_periyodu : time := 20 ns;

signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal yeni_paket_geldi : std_logic := '0';
signal gelen_veri : std_logic_vector(7 downto 0) := (others => '0');
signal led_cikisi : std_logic;

begin

saat_sureci : process
begin
clk <= '0';
wait for clk_periyodu / 2;
clk <= '1';
wait for clk_periyodu / 2;
end process;

test_birim : komut_cozucu
port map (
clk => clk,
rst => rst,
yeni_paket_geldi => yeni_paket_geldi,
gelen_veri => gelen_veri,
led_cikisi => led_cikisi
);

uyari_sureci : process
begin
rst <= '1';
wait for 40 ns;
rst <= '0';
wait for 40 ns;

gelen_veri <= x"31";
yeni_paket_geldi <= '1';
wait for clk_periyodu;
yeni_paket_geldi <= '0';
wait for 100 ns;

gelen_veri <= x"41";
yeni_paket_geldi <= '1';
wait for clk_periyodu;
yeni_paket_geldi <= '0';
wait for 100 ns;

gelen_veri <= x"30"; -- bilgisayarda 0 tuşu 30'a denk
yeni_paket_geldi <= '1';
wait for clk_periyodu;
yeni_paket_geldi <= '0';
wait for 100 ns;

assert false report "Komut cozucu testi basariyla tamamlandi" severity failure;
end process;
end Behavioral;
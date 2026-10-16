library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_baud_gen is
generic (
CLK_FREQ : integer := 50000000;
BAUD_RATE : integer := 115200
);
port (
clk : in std_logic;
rst : in std_logic;
rx_tick : out std_logic;
tx_tick : out std_logic
);
end uart_baud_gen;

architecture Behavioral of uart_baud_gen is
constant RX_MAX_COUNT : integer := CLK_FREQ/ (16 * BAUD_RATE);

signal rx_counter : integer range 0 to RX_MAX_COUNT - 1 := 0;
signal tx_counter : unsigned(3 downto 0) := (others => '0');

signal s_rx_tick : std_logic := '0';

begin 

process(clk, rst)
begin
if (rst = '1') then
rx_counter <= 0;
s_rx_tick <= '0';
elsif rising_edge(clk) then
if (rx_counter = RX_MAX_COUNT - 1) then
rx_counter <= 0;
s_rx_tick <= '1';
else 
rx_counter <= rx_counter + 1;
s_rx_tick <= '0';
end if;
end if;
end process;

rx_tick <= s_rx_tick;

process(clk, rst)
begin
if (rst = '1') then
tx_counter <= (others => '0');
tx_tick <= '0';
elsif rising_edge(clk) then
tx_tick <= '0';
if (s_rx_tick = '1') then
if (tx_counter = 15) then
tx_counter <= (others => '0');
tx_tick <= '1';
else 
tx_counter <= tx_counter + 1;
end if;
end if;
end if;
end process;

end Behavioral;

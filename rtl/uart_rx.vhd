library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
port (
clk : in std_logic;
rst : in std_logic;
rx_tick : in std_logic;
rx : in std_logic;
rx_done : out std_logic;
rx_data : out std_logic_vector(7 downto 0)
);
end uart_rx;

architecture Behavioral of uart_rx is

type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
signal state_reg, state_next : state_type := IDLE;

signal rx_sync1, rx_sync2 : std_logic := '1';
signal tick_cnt_reg, tick_cnt_next : integer range 0 to 15 := 0;
signal bit_cnt_reg, bit_cnt_next : integer range 0 to 7 := 0;
signal data_reg, data_next : std_logic_vector(7 downto 0) := (others => '0');

begin

process(clk, rst)
begin
if(rst = '1') then
rx_sync1 <= '1';
rx_sync2 <= '1';
elsif rising_edge(clk) then
rx_sync1 <= rx;
rx_sync2 <= rx_sync1;
end if;
end process;

process(clk, rst)
begin
if (rst = '1') then
state_reg <= IDLE;
tick_cnt_reg <= 0;
bit_cnt_reg <= 0;
data_reg <= (others => '0');
elsif rising_edge(clk) then
state_reg <= state_next;
tick_cnt_reg <= tick_cnt_next;
bit_cnt_reg <= bit_cnt_next;
data_reg <= data_next;
end if;
end process;

process(state_reg, tick_cnt_reg, bit_cnt_reg, data_reg, rx_sync2, rx_tick)
begin
state_next <= state_reg;
tick_cnt_next <= tick_cnt_reg;
bit_cnt_next  <= bit_cnt_reg;
data_next     <= data_reg;
rx_done       <= '0';

case state_reg is
when IDLE =>
if (rx_sync2 = '0') then
state_next    <= START_BIT;
tick_cnt_next <= 0;
end if;
when START_BIT =>
if (rx_tick = '1') then
if (tick_cnt_reg = 7) then
if (rx_sync2 = '0') then
state_next    <= DATA_BITS;
tick_cnt_next <= 0;
bit_cnt_next  <= 0;
else
state_next <= IDLE;
end if;
else
tick_cnt_next <= tick_cnt_reg + 1;
end if;
end if;
when DATA_BITS =>
if (rx_tick = '1') then
if (tick_cnt_reg = 15) then
tick_cnt_next <= 0;
data_next <= rx_sync2 & data_reg(7 downto 1);
if (bit_cnt_reg = 7) then
state_next <= STOP_BIT;
else
bit_cnt_next <= bit_cnt_reg + 1;
end if;
else
tick_cnt_next <= tick_cnt_reg + 1;
end if;
end if;
when STOP_BIT =>
if (rx_tick = '1') then
if (tick_cnt_reg = 15) then
state_next <= IDLE;
if (rx_sync2 = '1') then
rx_done <= '1';
end if;
else
tick_cnt_next <= tick_cnt_reg + 1;
end if;
end if;
end case;
end process;
rx_data <= data_reg;
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
port (
clk : in std_logic;
rst : in std_logic;
tx_tick : in std_logic;
tx_start : in std_logic;
tx_data : in std_logic_vector(7 downto 0);
tx : out std_logic;
tx_busy : out std_logic;
tx_done : out std_logic
);
end uart_tx;

architecture Behavioral of uart_tx is
type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
signal state_reg, state_next : state_type := IDLE;

signal data_reg, data_next : std_logic_vector(7 downto 0) := (others => '0');
signal bit_cnt_reg, bit_cnt_next : integer range 0 to 7 := 0;
signal tx_reg, tx_next : std_logic := '1';

begin

process(clk, rst)
begin
if (rst = '1') then
state_reg <= IDLE;
data_reg <= (others => '0');
bit_cnt_reg <= 0;
tx_reg <= '1';
elsif rising_edge(clk) then
state_reg <= state_next;
data_reg <= data_next;
bit_cnt_reg <= bit_cnt_next;
tx_reg <= tx_next;
end if;
end process;

process(state_reg, data_reg, bit_cnt_reg, tx_reg, tx_tick, tx_start, tx_data)
begin

state_next <= state_reg;
data_next <= data_reg;
bit_cnt_next <= bit_cnt_reg;
tx_next <= tx_reg;
tx_busy <= '1';
tx_done <= '0';

case state_reg is
when IDLE => 
tx_busy <= '0';
tx_next <= '1';
if(tx_start = '1') then
data_next <= tx_data;
state_next <= START_BIT;
tx_busy <= '1';
end if;

when START_BIT =>
tx_next <= '0';
if (tx_tick = '1') then
state_next <= DATA_BITS;
bit_cnt_next <= 0;
end if;

when DATA_BITS =>
tx_next <= data_reg(bit_cnt_reg);
if (tx_tick = '1') then
if(bit_cnt_reg = 7) then
state_next <= STOP_BIT;
else 
bit_cnt_next <= bit_cnt_reg + 1;
end if;
end if;

when STOP_BIT =>
tx_next <= '1';
if(tx_tick = '1') then
state_next <= IDLE;
tx_done <= '1';
end if;
end case;
end process;
tx <= tx_reg;
end Behavioral;

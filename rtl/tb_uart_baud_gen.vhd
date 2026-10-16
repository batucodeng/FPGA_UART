library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_uart_baud_gen is
end tb_uart_baud_gen;

architecture Behavioral of tb_uart_baud_gen is

constant CLK_FREQ_VAL : integer := 50000000;
constant BAUD_RATE_VAL : integer := 115200;
constant clk_period : time := 20 ns;

signal tb_clk : std_logic := '0';
signal tb_rst : std_logic := '0';
signal tb_rx_tick : std_logic;
signal tb_tx_tick : std_logic;
begin

uut: entity work.uart_baud_gen
generic map (
CLK_FREQ => CLK_FREQ_VAL, 
BAUD_RATE => BAUD_RATE_VAL
)
port map (
clk => tb_clk,
rst => tb_rst,
rx_tick => tb_rx_tick,
tx_tick => tb_tx_tick
);

clk_process : process 
begin 
tb_clk <= '0';
wait for clk_period / 2;
tb_clk <= '1';
wait for clk_period / 2;
end process;

stim_proc : process
begin 
tb_rst <= '1';
wait for 40 ns;
tb_rst <= '0';
wait for 15 us;

wait;
end process;
end Behavioral;
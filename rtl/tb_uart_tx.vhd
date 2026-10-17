library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_uart_tx is
end tb_uart_tx;

architecture Behavioral of tb_uart_tx is
constant clk_period : time := 20 ns;

signal tb_clk      : std_logic := '0';
signal tb_rst      : std_logic := '0';
signal tb_tx_tick  : std_logic;
signal tb_rx_tick  : std_logic;
signal tb_tx_start : std_logic := '0';
signal tb_tx_data  : std_logic_vector(7 downto 0) := (others => '0');
signal tb_tx       : std_logic;
signal tb_tx_busy  : std_logic;
signal tb_tx_done  : std_logic;

begin

baud_gen_inst: entity work.uart_baud_gen
generic map (
CLK_FREQ => 50000000,
BAUD_RATE => 115200
)
port map (
clk => tb_clk,
rst => tb_rst,
rx_tick => tb_rx_tick,
tx_tick => tb_tx_tick
);

uut: entity work.uart_tx
port map (
clk => tb_clk,
rst => tb_rst,
tx_tick => tb_tx_tick,
tx_start => tb_tx_start,
tx_data => tb_tx_data,
tx => tb_tx,
tx_busy => tb_tx_busy,
tx_done => tb_tx_done
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
wait for 100 ns;

tb_tx_data <= x"A5";
tb_tx_start <= '1';
wait for clk_period;
tb_tx_start <= '0';
wait until tb_tx_done = '1';
wait for 5 us;

tb_tx_data <= x"3C";
tb_tx_start <= '1';
wait for clk_period;
tb_tx_start <= '0';

wait until tb_tx_done = '1';
wait for 10 us;

wait;
end process;
end Behavioral;
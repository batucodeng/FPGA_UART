library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_uart_rx is
end tb_uart_rx;

architecture Behavioral of tb_uart_rx is
constant CLK_PERIOD : time := 20 ns;
constant BIT_PERIOD : time := 8.68 us; -- 1/115200 baud bit suresi unutma

signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal rx : std_logic := '1'; --hat bosta 1
signal rx_tick : std_logic;
signal rx_done : std_logic;
signal rx_data : std_logic_vector(7 downto 0);

begin

clk_process : process
begin 
clk <= '0';
wait for CLK_PERIOD / 2;
clk <= '1';
wait for CLK_PERIOD / 2;
end process;

uut_baud_gen : entity work.uart_baud_gen
port map (
clk => clk, 
rst => rst, 
tx_tick => open, 
rx_tick => rx_tick
);

uut_rx : entity work.uart_rx
port map (
clk => clk,
rst => rst,
rx_tick => rx_tick,
rx => rx,
rx_done => rx_done,
rx_data => rx_data
);

stim_proc : process

constant TEST_DATA : std_logic_vector(7 downto 0) := x"A5";
begin
rst <= '1';
rx <= '1';
wait for 100 ns;
rst <= '0';
wait for 2 us;

rx <= '0';
wait for BIT_PERIOD;

for i in 0 to 7 loop
rx <= TEST_DATA(i);
wait for BIT_PERIOD;
end loop;

rx <= '1';
wait for BIT_PERIOD;

wait for 15 us;

assert false report "Simulasyon basariyla tamamlandi!" severity failure;
end process;

end Behavioral;
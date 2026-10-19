library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_uart_top is
end tb_uart_top;

architecture Behavioral of tb_uart_top is

component uart_top is 
port (
clk : in std_logic;
rst : in std_logic;
rx : in std_logic;
tx : out std_logic
);
end component;

constant CLK_PERIOD : time := 20 ns;
constant BIT_PERIOD : time := 8.68 us;

signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal rx : std_logic := '1';
signal tx : std_logic;

begin 

clk_process : process
begin 
clk <= '0';
wait for CLK_PERIOD / 2;
clk <= '1';
wait for CLK_PERIOD / 2;
end process;

uut : uart_top
port map (
clk => clk, 
rst => rst,
rx => rx, 
tx => tx
);

stim_proc : process
constant TEST_DATA : std_logic_vector(7 downto 0) := x"35";
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

wait for 120 us;

assert false report "Loopback simulasyonu basariyla tamamlandi" severity failure;
end process;

end Behavioral;

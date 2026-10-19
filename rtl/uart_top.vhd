library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_top is
port (
clk : in std_logic;
rst : in std_logic;
rx : in std_logic;
tx : out std_logic
);
end uart_top;

architecture Behavioral of uart_top is

component uart_baud_gen is
port (
clk : in std_logic;
rst : in std_logic;
tx_tick : out std_logic;
rx_tick : out std_logic
);
end component;

component uart_rx is
port (
clk : in std_logic;
rst : in std_logic;
rx_tick : in std_logic;
rx : in std_logic;
rx_done : out std_logic;
rx_data : out std_logic_vector(7 downto 0)
);
end component;

component uart_tx is
port (
clk : in std_logic;
rst : in std_logic;
tx_start : in std_logic;
tx_tick : in std_logic;
tx_data : in std_logic_vector(7 downto 0);
tx_done : out std_logic;
tx_busy : out std_logic;
tx : out std_logic
);
end component;

signal rx_tick_sig : std_logic;
signal tx_tick_sig : std_logic;

signal rx_done_sig : std_logic;
signal rx_data_sig : std_logic_vector(7 downto 0);

begin

inst_baud_gen : uart_baud_gen
port map (
clk => clk,
rst => rst,
tx_tick => tx_tick_sig,
rx_tick => rx_tick_sig
);

inst_rx : uart_rx
port map (
clk => clk,
rst => rst, 
rx_tick => rx_tick_sig,
rx => rx,
rx_done => rx_done_sig,
rx_data => rx_data_sig
);

inst_tx : uart_tx
port map (
clk => clk,
rst => rst,
tx_start => rx_done_sig,
tx_tick => tx_tick_sig,
tx_data => rx_data_sig,
tx_done => open,
tx_busy => open,
tx => tx
);
end Behavioral;
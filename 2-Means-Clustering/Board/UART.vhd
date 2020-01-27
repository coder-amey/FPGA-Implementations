-- Author: Amey.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity UART is
	port(
		RESET, CLK, SEND, uart_rx : in std_logic;
		tx_data : in std_logic_vector(7 downto 0);
		
		rx_done, tx_done, uart_tx : out std_logic;
		rx_data : out std_logic_vector(7 downto 0));
end UART;

architecture COMPORT of UART is
	component uart_transceiver is
		port(
			sys_rst, sys_clk : in std_logic;
			tx_wr, uart_rx : in std_logic;
			tx_data : in std_logic_vector(7 downto 0);
			divisor : in std_logic_vector(15 downto 0);
			rx_done, tx_done, uart_tx : out std_logic;
			rx_data : out std_logic_vector(7 downto 0));
		end component;
	signal div : std_logic_vector(15 downto 0); --  div = f / (baud * 16).
	signal tx_wr, wr_done : std_logic;
	signal lock, mask : std_logic := '0';
	begin
	    div <= X"028B"; -- 651 = 100M / (9600 * 16) = 0x028B.
		COM0: entity work.uart_transceiver port map(
			sys_rst => RESET,
			sys_clk => CLK,
			divisor  => div,
            uart_rx => uart_rx,
            uart_tx => uart_tx,
            tx_wr => tx_wr,                        
            rx_done => rx_done,
            tx_done => wr_done,
            tx_data => tx_data,
			rx_data => rx_data);
		
		process(CLK) -- To debounce the send signal.
        begin
            if(rising_edge(CLK)) then
                if(lock = '0') then
                    if((SEND = '1') AND (mask = '0')) then
                        lock <= '1';
                        mask <= '1';
                        tx_wr <= '1';
                    elsif(SEND = '0') then
                        mask <= '0';
                    end if;
                else
                    tx_wr <= '0';
                    if(wr_done = '1') then
                        lock <= '0';
                    end if;
                end if;
            end if;
        end process;
    tx_done <= wr_done;
end COMPORT;
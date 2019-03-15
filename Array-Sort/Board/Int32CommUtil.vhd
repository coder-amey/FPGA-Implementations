-- Author: Amey.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.Int32_pack.all;

entity Int32CommUtil is
	port(
		RESET, CLK, uart_rx : in std_logic;
		uart_tx : out std_logic;
		sbits : out std_logic_vector(1 downto 0));
end Int32CommUtil;

architecture FSM of Int32CommUtil is
	component UART is
		port(
			RESET, CLK, SEND, uart_rx : in std_logic;
			tx_data : in std_logic_vector(7 downto 0);	
			rx_done, tx_done, uart_tx : out std_logic;
			rx_data : out std_logic_vector(7 downto 0));
		end component;
	
	component Int32ArrSort is
		port(
			RESET, CLK, enable, ack_driver : in std_logic;
			ack_mod : inout std_logic;
			int_in : in std_logic_vector(31 downto 0);
			int_out : out std_logic_vector(31 downto 0));
		end component Int32ArrSort;
	
	signal SEND, en_mod1, ack_driver : std_logic := '0';
	signal rx_done, tx_done, ack_mod1 : std_logic;
	signal main_state, p_state, tx_state : std_logic_vector(1 downto 0) := "00";  -- main_state: FSM with four states: 0|Wait/Init, 1|Read 2, 3|Sort, 4|Write. p_state: Nested states for the process block. tx_state: Nested states for tranmisiion.
	signal rx_byte, tx_byte : std_logic_vector(7 downto 0);				-- Buffer registers.
	signal size : integer := 0;
	signal a : Int32Array(100 downto 0);
	signal int_buff, int_rx1, int_tx1 : std_logic_vector(31 downto 0);	-- Buffer vectors.

	begin
		CNXN: entity work.UART(COMPORT) port map(
			RESET => RESET,
			CLK => CLK,
			uart_rx => uart_rx,
			uart_tx => uart_tx,
			SEND => SEND,
			rx_done => rx_done,
			tx_done => tx_done,
			tx_data => tx_byte,
			rx_data => rx_byte);
		
		MOD1: entity work.Int32ArrSort(SORT) port map(
			RESET => RESET,
			CLK => CLK,
			enable => en_mod1,
			ack_driver => ack_driver,
			ack_mod => ack_mod1,
			int_in => int_tx1,
			int_out => int_rx1);
		
	process(CLK)
	variable i, j : integer := 0;
	begin
		if(RESET = '1') then
			i := 0;
			j := 0;
			size <= 0;
			SEND <= '0';
			en_mod1 <= '0';
			ack_driver <= '0';
			p_state <= "00";
			tx_state <= "00";
			main_state <= "00";
		--------
		
		elsif(rising_edge(CLK)) then
		
			if(main_state = "00") then -- Init as well as halt/waiting state.			
				if(i < 4) then
					if(rx_done = '1') then
						int_buff <= append_byte(int_buff, rx_byte);
						i := i + 1;
					end if;
				else
					size <= TO_INTEGER(unsigned(int_buff));
					i := 0;
					main_state <= state_transition(main_state);
				end if;
			----------
			
			elsif(main_state = "01") then		-- Reading state.
				if(j < size) then
					if(i < 4) then
						if(rx_done = '1') then
							int_buff <= append_byte(int_buff, rx_byte);
							i := i + 1;
						end if;
					else
						a(j) <= Int32(int_buff);
						j := j + 1;
						i := 0;
					end if;
				else
					j := 0;
					main_state <= state_transition(main_state);
				end if;
			--------
 			
			elsif(main_state = "10") then	-- Process block. Sorting state
				en_mod1 <= '1';
				if(p_state = "00") then	-- Write the size.
					if(tx_state = "00") then
						int_tx1 <= std_logic_vector(to_unsigned(size, 32));	-- Integer staging clock-cycle.
						ack_driver <= '1';
						tx_state <= state_transition(tx_state);
					-------
					elsif(tx_state = "01") then				-- Wait for ack.
						if(ack_mod1 <= '1') then
							ack_driver <= '0';
							tx_state <= state_transition(tx_state);
						end if;
					-------	
					elsif(tx_state = "10") then				-- Wait for ack to go low.
						if(ack_mod1 = '0') then
							tx_state <= state_transition(tx_state);
						end if;
					-------
					elsif(tx_state = "11") then
						tx_state <= state_transition(tx_state);	-- Integer sent.
						p_state <= state_transition(p_state);
					end if;
				------
				
				elsif(p_state = "01") then	-- Write the array.
					if(i < size) then
						if(tx_state = "00") then
							int_tx1 <= std_logic_vector(a(i));	-- Integer staging clock-cycle.
							ack_driver <= '1';
							tx_state <= state_transition(tx_state);
						-------
						elsif(tx_state = "01") then				-- Wait for ack.
							if(ack_mod1 <= '1') then
								ack_driver <= '0';
								tx_state <= state_transition(tx_state);
							end if;
						-------	
						elsif(tx_state = "10") then				-- Wait for ack to go low.
							if(ack_mod1 = '0') then
								tx_state <= state_transition(tx_state);
							end if;
						-------
						elsif(tx_state = "11") then				-- Increment counter.
							i := i + 1;
							tx_state <= state_transition(tx_state);	-- Integer sent.
						end if;
					------
					else
						i := 0;
						p_state <= state_transition(p_state);
					end if;
				------
				
				elsif(p_state = "10") then	-- Read the array.
					if(i < size) then
						if(ack_mod1 = '1') then
							a(i) <= Int32(int_rx1);
							ack_driver <= '1';
						------
						elsif(ack_driver = '1') then
							ack_driver <= '0';
							i := i + 1;
						end if;
					------
					else
						i := 0;
						p_state <= state_transition(p_state);
					end if;
				------
				
				elsif(p_state = "11") then	-- Disable the process block.
					en_mod1 <= '0';
					p_state <= state_transition(p_state);
					main_state <= state_transition(main_state);
				end if;
			---------
			
			elsif(main_state = "11") then		-- Write-back state.
				if(j < size) then
					if(tx_state = "00") then
						int_buff <= std_logic_vector(a(j));	-- Byte staging clock-cycle.
						tx_state <= "01";
					-------
					elsif(i < 4) then
						if(SEND = '0') then
							tx_byte <= int_buff(7 downto 0);
							SEND <= '1';
						elsif(tx_done = '1') then
							int_buff <= std_logic_vector(shift_right(unsigned(int_buff), 8));
							i := i + 1;
							SEND <= '0';
						end if;
					else
						j := j + 1;
						i := 0;
						tx_state <= "00";	-- Byte sent.
					end if;
				else
					j := 0;
					main_state <= state_transition(main_state);
					
				end if;
			end if;
		end if;
	end process;
	sbits <= main_state;
end FSM;
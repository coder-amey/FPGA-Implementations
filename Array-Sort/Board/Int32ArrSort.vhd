-- Author: Amey.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.Int32_pack.all;

entity Int32ArrSort is
	port(
		RESET, CLK, enable, ack_driver : in std_logic;
		ack_mod : inout std_logic;
		int_in : in std_logic_vector(31 downto 0);
		int_out : out std_logic_vector(31 downto 0));
end Int32ArrSort;

architecture SORT of Int32ArrSort is
	signal main_state, tx_state, p_state : std_logic_vector(1 downto 0) := "00";
	signal size : integer := 0;
	signal a : Int32Array(100 downto 0);
	signal swap_buff : std_logic_vector(63 downto 0);

	begin
	process(CLK)
	variable i, j : integer := 0;
	begin
		if(RESET = '1') then
			i := 0;
			j := 0;
			size <= 0;
			ack_mod <= '0';
			p_state <= "00";
			tx_state <= "00";
			main_state <= "00";
		--------
	
		elsif(rising_edge(CLK)) then
			if(enable = '1') then
				if(main_state = "00") then	-- Read the size.
					if(ack_driver = '1') then
						size <= TO_INTEGER(unsigned(int_in));
						ack_mod <= '1';
					
					elsif(ack_mod = '1') then
						ack_mod <= '0';	
						main_state <= state_transition(main_state);
					end if;
				------
				
				elsif(main_state = "01") then	-- Read the array.
					if(i < size) then
						if(ack_driver = '1') then
							a(i) <= Int32(int_in);
							ack_mod <= '1';
									
						elsif(ack_mod = '1') then
							ack_mod <= '0';
							i := i + 1;
						end if;
					else
						i := 0;
						main_state <= state_transition(main_state);
					end if;
				------
				
				elsif(main_state = "10") then	-- Process block.
					if(p_state = "00") then
						j := i + 1;
						if(j < size) then
							p_state <= state_transition(p_state);
						else
							p_state <= "11";
						end if;
					------
					
					elsif(p_state = "01") then
						if(j < size) then
							if(a(i) > a(j)) then
								swap_buff(63 downto 32) <= a(i);
								swap_buff(31 downto 0) <= a(j);
								p_state <= state_transition(p_state);
							else
								j := j + 1;
							end if;
						------
						else
							i := i + 1;
							p_state <= "00";
						end if;
					------
					
					elsif(p_state = "10") then
						a(i) <= swap_buff(31 downto 0);
						a(j) <= swap_buff(63 downto 32);
						p_state <= "01";
					--------
					
					elsif(p_state = "11") then
						i := 0;
						j := 0;
						main_state <= state_transition(main_state);
						p_state <= "00";
					end if;
				------
			
				elsif(main_state = "11") then	-- Write the array.
					if(i < size) then
						if(tx_state = "00") then
							int_out <= std_logic_vector(a(i));	-- Integer staging clock-cycle.
							ack_mod <= '1';
							tx_state <= state_transition(tx_state);
						-------
						elsif(tx_state = "01") then				-- Wait for ack.
							if(ack_driver <= '1') then
								ack_mod <= '0';
								tx_state <= state_transition(tx_state);
							end if;
						-------	
						elsif(tx_state = "10") then				-- Wait for ack to go low.
							if(ack_driver = '0') then
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
						main_state <= state_transition(main_state);
					end if;
				end if;
				------
			end if;
		end if;
	end process;
end SORT;
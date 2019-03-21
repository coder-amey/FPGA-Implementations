-- Author: Amey.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.Int32_pack.all;


entity Int32BRAMSort is
	port(
		RESET, CLK, enable : in std_logic;
		base, bound : in std_logic_vector(31 downto 0);
		d_in  : in std_logic_vector(31 downto 0);
		addr, d_out  : out std_logic_vector(31 downto 0);
		wr_en : out std_logic_vector(3 downto 0);
		done : out std_logic);
end Int32BRAMSort;

architecture SORT of Int32BRAMSort is
	signal main_state : std_logic_vector(1 downto 0) := "00";
	signal p_state : std_logic_vector(2 downto 0) := "000";
	signal ptr_i, ptr_j, ai, aj  : std_logic_vector(31 downto 0) := X"00000000";	-- Null pointer initiation avoids errors.
	
	-- Memory-control signals.
	signal mem_busy : std_logic := '0';
	
	begin
	main: process(CLK)
	begin
		if(RESET = '1') then
			mem_busy <= '0';
			wr_en <= X"0";
			p_state <= "000";
			main_state <= "00";
		--------
		
		elsif(rising_edge(CLK)) then
			if(enable = '1') then
				
				if(mem_busy = '1') then		-- Memory busy...
					mem_busy <= '0';
					wr_en <= X"0";
				-------	
						
				elsif(main_state = "00") then
					ptr_i <= base;
					ptr_j <= inc_ptr(base);
					d_out <= X"00000000";
					main_state <= state_transition(main_state);
				------
				
				elsif(main_state = "01") then	-- Process block.
					if(p_state = "000") then		-- j = i + 1. 0 -> 1 | 7(exit).
						if(ptr_j < bound) then
							addr <= ptr_i;
							mem_busy <= '1';
							p_state <= state_transition(p_state);
						else
							p_state <= "111";
						end if;
					-----
					
					elsif(p_state = "001") then		-- Load a[i]. 1 -> 2.
						ai <= d_in;
						p_state <= state_transition(p_state);
					------
					
					elsif(p_state = "010") then		-- Check j < size. 2 -> 3 | 0(next i_iter.)
						if(ptr_j < bound) then
							addr <= ptr_j;
							mem_busy <= '1';
							p_state <= state_transition(p_state);
						-----
						else
							ptr_j <= inc_ptr(inc_ptr(ptr_i));	-- j = (i + 4) + 4.
							ptr_i <= inc_ptr(ptr_i);
							p_state <= "000";
						end if;
					------
					
					elsif(p_state = "011") then		-- Load a[j].	3 -> 4
						aj <= d_in;
						p_state <= state_transition(p_state);
					------
					
					elsif(p_state = "100") then		-- 4 -> 5(swap needed) | 2(next j_iter.)
						if(ai > aj) then		-- Swap a[i] with a[j].
							addr <= ptr_i;
							d_out <=  aj;
							wr_en <= X"F";		-- *i <- a[j];
							mem_busy <= '1';
							p_state <= state_transition(p_state);
						else
							ptr_j <= inc_ptr(ptr_j);
							p_state <= "010";
						end if;
					------
					
					elsif(p_state = "101") then		-- *i <- a[j]; 5 -> 6
						if(d_in = aj) then 	-- Ensure that previous write operation has been completed.
							addr <= ptr_j;
							d_out <=  ai;
							wr_en <= X"F";		-- *j <- a[i];
							mem_busy <= '1';
							p_state <= state_transition(p_state);
						-----
						else 		-- (!) Dirty-read exception. Write again.
							wr_en <= X"F";
							mem_busy <= '1';
						end if;
					-----
					
					elsif(p_state = "110") then -- *j <- a[i]; 6 -> 2(next j_iter.)
						if(d_in = ai) then	-- Ensure that current write operation has been completed.
							ai <= aj;			-- (!) Very important.
							ptr_j <= inc_ptr(ptr_j);
							p_state <= "010";
						-----
						else 		-- (!) Dirty-read exception. Write again.
							wr_en <= X"F";
							mem_busy <= '1';
						end if;
					------
					
					elsif(p_state = "111") then 	-- Sorting done!
						addr <= X"00000000";	-- Avoid write-first anomaly.
						mem_busy <= '1';
						p_state <= state_transition(p_state);
						main_state <= state_transition(main_state);
					end if;
				------
				
				elsif(main_state = "10") then	-- Yield.
					done <= '1';
					main_state <= state_transition(main_state);
				------
				
				elsif(main_state = "11") then	-- Halt.
				end if;
				------
			else
				main_state <= "00";
				done <= '0';
			end if;
		end if;
	end process;
end SORT;
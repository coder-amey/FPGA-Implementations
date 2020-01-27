-- Author: Amey.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.Int32_pack.all;


entity K_Means is
	port(
		RESET, CLK, enable : in std_logic;
		base, bound : in std_logic_vector(31 downto 0);
		d_in  : in std_logic_vector(31 downto 0);
		addr, d_out  : out std_logic_vector(31 downto 0);
		wr_en : out std_logic_vector(3 downto 0);
		done : out std_logic;
		debug : out std_logic_vector(3 downto 0));
end K_Means;

architecture CLUSTER of K_Means is
	signal main_state : std_logic_vector(1 downto 0) := "00";
	signal p_state, sub_state : std_logic_vector(2 downto 0) := "000";	-- Process state
	signal flag : std_logic_vector(3 downto 0) :="0000"; -- Flag used in division.
	signal px, py, x, y, cx1_acc, cy1_acc, c1_n, cx2_acc, cy2_acc, c2_n : std_logic_vector(31 downto 0) := X"00000000";	-- Null pointer initiation avoids errors. [Memory pointers, data points, accumlators, counters respectively.]
	
	-- Hard-coded initial centroids [(1, 1); (24, 24)].
	signal cx1, cy1 :  std_logic_vector(31 downto 0) := X"00000001";
	signal cx2, cy2 :  std_logic_vector(31 downto 0) := X"00000018";
	-- Distance measures:
	signal dx1, dx2, dy1, dy2 : std_logic_vector(31 downto 0) := X"00000000";
	signal D1, D2 : std_logic_vector(63 downto 0) := X"0000000000000000";
	-- Memory-control signals.
	signal mem_busy : std_logic := '0';
	
	begin
	main: process(CLK)
	variable itr : integer := 0;		-- Clustering iterations
	begin
		if(RESET = '1') then
			done <= '0';
			mem_busy <= '0';
			wr_en <= X"0";
			p_state <= "000";
			sub_state <= "000";
			main_state <= "00";			

			px <= X"00000000";
			py <= X"00000000";
			x <= X"00000000";
			y <= X"00000000";
			dx1 <= X"00000000";
			dx2 <= X"00000000";
			dy1 <= X"00000000";
			dy2 <= X"00000000";
			D1 <= X"0000000000000000";
			D2 <= X"0000000000000000";
			
			cx1 <= X"00000001"; 
			cy1 <= X"00000001";
			cx2 <= X"00000018";
			cy2 <= X"00000018";
		--------
		
		elsif(rising_edge(CLK)) then
			if(enable = '1') then
				
				if(mem_busy = '1') then		-- Memory busy...
					mem_busy <= '0';
					wr_en <= X"0";
				-------	
						
				elsif(main_state = "00") then
					done <= '0';
					px <= base;
					py <= inc_ptr(base);
					d_out <= X"00000000";
					main_state <= state_transition(main_state);
				------
				
				elsif(main_state = "01") then			-- Process block.
					if(itr < 8) then		-- Set maximum iterations here.
					
						if(p_state = "000") then		-- Load x & y.
							if(sub_state = "000") then		-- Get x.
								addr <= px;
								mem_busy <= '1';
								sub_state <= state_transition(sub_state);
							-----
							
							elsif(sub_state = "001") then		-- Load x.
								x <= d_in;
								sub_state <= state_transition(sub_state);
							------
						
							elsif(sub_state = "010") then		-- Get y.
								addr <= py;
								mem_busy <= '1';
								sub_state <= state_transition(sub_state);
							-----
							
							elsif(sub_state = "011") then		-- Load y.
								y <= d_in;
								sub_state <= "000";
								p_state <= state_transition(p_state);
							end if;
						-----
						
						elsif(p_state = "001") then		-- Calculate differences.
							if(x > cx1) then
								dx1 <= sub_reg(x, cx1);
							else
								dx1 <= sub_reg(cx1, x);
							end if;
							
							if(y > cy1) then
								dy1 <= sub_reg(y, cy1);
							else
								dy1 <= sub_reg(cy1, y);
							end if;
														
							if(x > cx2) then
								dx2 <= sub_reg(x, cx2);
							else
								dx2 <= sub_reg(cx2, x);
							end if;
							
							if(y > cy2) then
								dy2 <= sub_reg(y, cy2);
							else
								dy2 <= sub_reg(cy2, y);
							end if;
						
							p_state <= state_transition(p_state);
						------
					
						elsif(p_state = "010") then		-- Calculate squared Euclidian distances.		[!]
							D1 <= (dx1 * dx1) + (dy1 * dy1);
							D2 <= (dx2 * dx2) + (dy2 * dy2);
							p_state <= state_transition(p_state);
						------
						
						elsif(p_state = "011") then		-- Compare distances.
							if(D1 < D2) then			-- Add to C1 cluster.
								cx1_acc <= cx1_acc + x;
								cy1_acc <= cy1_acc + y;
								c1_n <= c1_n + '1';
								
							else					-- Add to C2 cluster.
								cx2_acc <= cx2_acc + x;
								cy2_acc <= cy2_acc + y;
								c2_n <= c2_n + '1';
							end if;
							
							px <= inc_ptr(py);		-- px <- next(py).
							py <= inc_ptr(px);		-- py <- next(px).			[!]
							p_state <= state_transition(p_state);
						------
					
						elsif(p_state = "100") then		-- 4 -> 0 (Move to the next data point or the next iteration.)
							if(px < bound) then
								p_state <= "000";		-- Next point.
								-- WARNING: This is a common step. However, the other branch advances after a few T-cycles. DO NOT use a common jump statement.
							
							else				-- Iteration complete.
								-- Generate new centroids through Integer Division.
								if(sub_state = "000") then	-- Initialize the quotients.
									cx1 <= X"00000000"; 
									cy1 <= X"00000000";
									cx2 <= X"00000000";
									cy2 <= X"00000000";
									sub_state <= state_transition(sub_state);
								----
								-- WARNING: Division by zero leads to infinite loop.
								elsif(sub_state = "001") then
									if((cx1_acc >= c1_n) and (c1_n /= X"00000000")) then
										cx1_acc <= sub_reg(cx1_acc, c1_n);
										cx1 <= cx1 + '1';
									else
										flag(0) <= '1';
									end if;
									
									if((cy1_acc >= c1_n) and (c1_n /= X"00000000")) then
										cy1_acc <= sub_reg(cy1_acc, c1_n);
										cy1 <= cy1 + '1';
									else
										flag(1) <= '1';
									end if;
									
									if((cx2_acc >= c2_n) and (c2_n /= X"00000000")) then
										cx2_acc <= sub_reg(cx2_acc, c2_n);
										cx2 <= cx2 + '1';
									else
										flag(2) <= '1';
									end if;
									
									if((cy2_acc >= c2_n) and (c2_n /= X"00000000")) then
										cy2_acc <= sub_reg(cy2_acc, c2_n);
										cy2 <= cy2 + '1';
									else
										flag(3) <= '1';
									end if;
									
									if(flag = X"F") then
										flag <= X"0";
										sub_state <= state_transition(sub_state);
									end if;
								----
								
								elsif(sub_state = "010") then
									-- Cleanup garbage.
									cx1_acc <= X"00000000";
									cy1_acc <= X"00000000";
									c1_n <= X"00000000";
									cx2_acc <= X"00000000";
									cy2_acc <= X"00000000";
									c2_n <= X"00000000";
									
									-- Readjust pointers to seg_base.
									px <= base;
									py <= inc_ptr(base);
									
									-- Initiate next iteration
									itr := itr + 1;
									p_state <= "000";
									sub_state <= "000";
								end if;
							end if;
						end if;
					------
					
					else		-- Clustering completed.
						itr := 0;
						main_state <= state_transition(main_state);
					end if;
				------
				
				elsif(main_state = "10") then		-- Yield the discovered centroids.
					if(sub_state = "000") then		-- Write C1_x.
						addr <= px;
						d_out <=  cx1;
						wr_en <= X"F";		-- *px <- cx1;
						mem_busy <= '1';
						sub_state <= state_transition(sub_state);
					----
					
					elsif(sub_state = "001") then		-- Write C1_y.
						if(d_in = cx1) then 	-- Ensure that previous write operation has been completed.
							addr <= py;
							d_out <=  cy1;
							wr_en <= X"F";		-- *py <- cy1;
							mem_busy <= '1';
							px <= inc_ptr(py); -- px <- next(py);
							sub_state <= state_transition(sub_state);
						
						else 		-- (!) Dirty-read exception. Write again.
							wr_en <= X"F";
							mem_busy <= '1';
						end if;
					----
					
					elsif(sub_state = "010") then		-- Write C2_x.
						if(d_in = cy1) then 	-- Ensure that previous write operation has been completed.
							addr <= px;
							d_out <=  cx2;
							wr_en <= X"F";		-- *px <- cx2;
							mem_busy <= '1';
							py <= inc_ptr(px); -- py <- next(px);
							sub_state <= state_transition(sub_state);
						
						else 		-- (!) Dirty-read exception. Write again.
							wr_en <= X"F";
							mem_busy <= '1';
						end if;
					----
					
					elsif(sub_state = "011") then		-- Write C2_y.
						if(d_in = cx2) then 	-- Ensure that previous write operation has been completed.
							addr <= py;
							d_out <=  cy2;
							wr_en <= X"F";		-- *py <- cy2;
							mem_busy <= '1';
							sub_state <= state_transition(sub_state);
						
						else 		-- (!) Dirty-read exception. Write again.
							wr_en <= X"F";
							mem_busy <= '1';
						end if;
					----
					
					elsif(sub_state = "100") then		-- Return.
						if(d_in = cy2) then 	-- Ensure that previous write operation has been completed.
							-- Reset vital signals to original state. 
							px <= X"00000000";
							py <= X"00000000";
							cx1 <= X"00000001"; 
							cy1 <= X"00000001";
							cx2 <= X"00000018";
							cy2 <= X"00000018";
							sub_state <= "000";
							
							-- Finish.
							done <= '1';
							main_state <= state_transition(main_state);
						
						else 		-- (!) Dirty-read exception. Write again.
							wr_en <= X"F";
							mem_busy <= '1';
						end if;
					end if;
				----
				
				elsif(main_state = "11") then	-- Halt.
				end if;
				------
			else
				main_state <= "00";
				done <= '0';
			end if;
		end if;
	end process;
	-- Assign the signal to be sent for debugging. Default: main_state.
	debug(3 downto 2) <= "00";
	debug(1 downto 0) <= main_state;
end CLUSTER;
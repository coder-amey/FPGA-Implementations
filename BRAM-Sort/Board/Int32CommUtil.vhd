-- Author: Amey.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.ALL;

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
	
	component Int32BRAMSort is
		port(
			RESET, CLK, enable : in std_logic;
			base, bound : in std_logic_vector(31 downto 0);
			d_in  : in std_logic_vector(31 downto 0);
			addr, d_out  : out std_logic_vector(31 downto 0);
			wr_en : out std_logic_vector(3 downto 0);
			done : out std_logic);
		end component Int32BRAMSort;
	
	component BRAM is
		port (
			BRAM_PORTA_0_addr : in std_logic_vector(31 downto 0);
			BRAM_PORTA_0_clk : in std_logic;
			BRAM_PORTA_0_din : in std_logic_vector(31 downto 0);
			BRAM_PORTA_0_dout : out std_logic_vector(31 downto 0);
			BRAM_PORTA_0_en : in std_logic;
			BRAM_PORTA_0_rst : in std_logic;
			BRAM_PORTA_0_we : in std_logic_vector(3 downto 0);
			BRAM_PORTB_0_addr : in std_logic_vector(31 downto 0);
			BRAM_PORTB_0_clk : in std_logic;
			BRAM_PORTB_0_din : in std_logic_vector(31 downto 0);
			BRAM_PORTB_0_dout : out std_logic_vector(31 downto 0);
			BRAM_PORTB_0_en : in std_logic;
			BRAM_PORTB_0_rst : in std_logic;
			BRAM_PORTB_0_we : in std_logic_vector(3 downto 0));
		end component BRAM;
	
	signal SEND, en_mod1, en_mod2 : std_logic := '0';
	signal rx_done, tx_done, done_mod1 : std_logic;
	signal main_state, n_state, tx_state : std_logic_vector(1 downto 0) := "00";	-- main_state: FSM with four states: 0|Wait/Init, 1|Read 2, 3|Sort, 4|Write. n_state: General-purpose nested states. tx_state: Nested states for tranmisiion.
	signal rx_byte, tx_byte : std_logic_vector(7 downto 0);				-- Buffer registers.
	signal size : integer := 0;
	signal seg_base : std_logic_vector(31 downto 0) := X"00008420";	-- Starting address.
	signal int_buff, seg_bound, ptr : std_logic_vector(31 downto 0);	-- Buffer vector, segment boundary and locaation pointer respectively.
	
	-- Memory-control signals.
	signal addr, d_in, d_out : std_logic_vector(31 downto 0) := X"00000000";
	signal wr_en : std_logic_vector(3 downto 0) := "0000";
	signal mem_busy, M_RESET : std_logic := '0';
	
	-- Outsourced signals.
	signal mod1_m_en : std_logic := '0';
	signal mod1_addr, mod_to_mem, mem_to_mod : std_logic_vector(31 downto 0);
	signal mod1_wr_en : std_logic_vector(3 downto 0);
	
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
		
		Sort_MOD1: entity work.Int32BRAMSort(SORT) port map(
			RESET => RESET,
			CLK => CLK,
			enable => en_mod1,
			base => seg_base,
			bound => seg_bound,
			d_in  => mem_to_mod,
			addr => mod1_addr,
			d_out => mod_to_mem,
			wr_en => mod1_wr_en,
			done => done_mod1);
			
		Memory_MOD2: component BRAM port map (
			BRAM_PORTA_0_clk => CLK,
			BRAM_PORTA_0_rst => M_RESET,
			BRAM_PORTA_0_en => en_mod2,
			BRAM_PORTA_0_addr => addr,
			BRAM_PORTA_0_din => d_out,			-- Out -> Memory.
			BRAM_PORTA_0_dout => d_in,			-- In -> Module.
			BRAM_PORTA_0_we => wr_en,
			
			BRAM_PORTB_0_clk => CLK,
			BRAM_PORTB_0_rst => M_RESET,
			BRAM_PORTB_0_en => mod1_m_en,
			BRAM_PORTB_0_addr => mod1_addr,
			BRAM_PORTB_0_din => mod_to_mem,
			BRAM_PORTB_0_dout => mem_to_mod,
			BRAM_PORTB_0_we => mod1_wr_en);
		
	main: process(CLK)
	variable i : integer := 0;
	begin
		if(RESET = '1') then
			i := 0;
			size <= 0;
			SEND <= '0';
			en_mod1 <= '0';
			en_mod2 <= '0';
			mem_busy <= '0';
			M_RESET <= '1';
			wr_en <= "0000";
			n_state <= "00";
			tx_state <= "00";
			main_state <= "00";
			-- Memory ports are reset in the next immediate state. Therefore, M_RESET is decoupled from RESET.
		------
		
		elsif(rising_edge(CLK)) then
			
			if(mem_busy = '1') then		-- Memory busy...
				mem_busy <= '0';
				wr_en <= X"0";
			-------
				
			elsif(main_state = "00") then -- Init as well as halt/waiting state.
				if(M_RESET = '1') then -- Reset the memory (BRAM).
					if(n_state = "00") then	
						en_mod2 <= '1';
						mod1_m_en <= '1';
						mem_busy <= '1';
						n_state <= state_transition(n_state);
					-----
					elsif(n_state = "01") then
						en_mod2 <= '0';
						mod1_m_en <= '0';
						M_RESET <= '0';
						n_state <= "00";
					end if;
				-----
				-- BRAM Reset complete.
				
				elsif(i < 4) then		-- Read the size.
					if(rx_done = '1') then
						int_buff <= append_byte(int_buff, rx_byte);
						i := i + 1;
					end if;
				else
					size <= TO_INTEGER(unsigned(int_buff));
					seg_bound <= seg_base + std_logic_vector(shift_left(unsigned(int_buff), 2)); -- bound = base + (4(bytes) * size). Multiplication by rotation.
					ptr <= seg_base;
					i := 0;
					en_mod2 <= '1'; -- Turn on the memory unit.
					main_state <= state_transition(main_state);
				end if;
			------
			
			elsif(main_state = "01") then		-- Reading state.
				if(ptr < seg_bound) then
					if(i < 4) then
						if(rx_done = '1') then
							int_buff <= append_byte(int_buff, rx_byte);
							i := i + 1;
						end if;
					else
						if(d_in = int_buff) then 	-- Ensure that write operation has been completed.
							ptr <= inc_ptr(ptr); -- Increment pointer (+= 4) to the next location.
							i := 0;
						-----
						else
							d_out <= int_buff;
							addr <= ptr;
							wr_en <= X"F";
							mem_busy <= '1';
						end if;
					end if;
				else
					ptr <= seg_base;
					main_state <= state_transition(main_state);
				end if;
			--------
 			
			elsif(main_state = "10") then	-- Process block. Sorting state
				if(n_state = "00") then	-- Enable the sub-module.
					addr <= X"00000000";		-- To avoid write-first anomaly.
					en_mod2 <= '0';
					en_mod1 <= '1';
					mod1_m_en <= '1';
					n_state <= state_transition(n_state);
				-----
				
				elsif(n_state = "01") then	-- Wait for the sub-module to yield and then disable it.
					if(done_mod1 = '1') then
						mod1_m_en <= '0';
						en_mod1 <= '0';
						en_mod2 <= '1';
						n_state <= "00";
						main_state <= state_transition(main_state);
					end if;
				end if;
			-------
			
			elsif(main_state = "11") then		-- Write-back state.
				if(ptr < seg_bound) then
					if(tx_state = "00") then
						addr <= ptr;
						mem_busy <= '1';
						tx_state <= state_transition(tx_state);
					------
					elsif(tx_state = "01") then
						if(mem_busy = '0') then
							int_buff <= d_in;	-- Byte staging clock-cycle.
							tx_state <= state_transition(tx_state);
						end if;
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
						i := 0;
						ptr <= inc_ptr(ptr); 
						tx_state <= "00";	-- Byte sent.
					end if;
				else
					en_mod2 <= '0'; -- Turn off the memory unit.
					main_state <= state_transition(main_state);
					
				end if;
			end if;
		end if;
	end process;
	
	sbits <= main_state;
end FSM;
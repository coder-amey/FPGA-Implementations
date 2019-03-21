-- Author: Amey.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package Int32_pack is
	subtype Int32 is std_logic_vector(31 downto 0);
	type Int32Array is array (integer range <>) of Int32;
	
	impure function state_transition(s : std_logic_vector)
	return std_logic_vector;
	
	impure function append_byte(reg : std_logic_vector; byte: std_logic_vector)
	return std_logic_vector;
	
	impure function inc_ptr(ptr : std_logic_vector)
	return std_logic_vector;
		
end Int32_pack;

package body Int32_pack is
	impure function state_transition(s : std_logic_vector)
	return std_logic_vector is
		variable ns : std_logic_vector(s'length - 1 downto 0); -- New State.
		begin
			ns := s + '1';
		return std_logic_vector(ns);
	end function state_transition;

	impure function append_byte(
		reg : std_logic_vector;
		byte: std_logic_vector)
	return std_logic_vector is
		variable int : std_logic_vector(31 downto 0);
		begin
			int(31 downto 24) := byte;
			int(23 downto 0) := reg(31 downto 8);
		return std_logic_vector(int);
	end function append_byte;
	
	impure function inc_ptr(ptr : std_logic_vector)
	return std_logic_vector is
		variable new_ptr : std_logic_vector(ptr'length - 1 downto 0); -- Next location.
		begin
			new_ptr := ptr + X"4";
		return std_logic_vector(new_ptr);
	end function inc_ptr;

end Int32_pack;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.ALL;

package my_package is

	-- General MIPS Parameters --
	constant n_bits_address : natural := 32; -- 32 bits
	constant n_bits_data 	: natural := 32; -- 32 bits
	constant n_bits_instr 	: natural := 32; -- 32 bits
   	constant zeros 		: std_logic_vector(n_bits_data - 1 downto 0) := (others => '0');
   	constant ones 		: std_logic_vector(n_bits_data - 1 downto 0) := (others => '1');
   	type mem_type is array(natural range <>) of std_logic_vector(n_bits_data - 1 downto 0);
   	   	
	-- Register File Parameters --
	constant reg_file_depth   : natural := 32; -- 32 registers
	constant reg_file_width   : natural := n_bits_data;
	constant initial_reg_file : mem_type(0 to reg_file_depth - 1) := (others => zeros);
	constant stack_pointer    : natural := 29; -- register 29 is the stack pointer

	-- Data Memory Parameters --
	constant data_mem_depth   : natural := 117; -- 117 registers
	constant data_mem_width   : natural := n_bits_data;
	constant initial_data_mem : mem_type(0 to data_mem_depth - 1) := (others => zeros);

   	-- Instruction Memory Parameters --
   	constant my_program_size : natural := 25; -- Number of instructions
   	constant instr_mem_depth   : natural := my_program_size;
	constant instr_mem_width   : natural := n_bits_instr;  
	constant my_program : mem_type(0 to instr_mem_depth - 1) :=   
	(
	"00100000000001000000000000000011",
	"00100000000010000000000000001010",
	"00100000000010010000000000000110",
	"00000001001010000101000000100100",
	"00000001001010000101100000100101",
	"00000001001010000110000000100111",
	"00000001001010000110100000101010",
	"10101111101010000000000000000000",
	"10101111101010011111111111111100",
	"10001111101100000000000000000000",
	"10001111101100011111111111111100",
	"00010010000100010000000000000010",
	"00000010000100011001100000100000",
	"00001000000100000000000000001111",
	"00000010000100011001100000100010",
	"00000010000100111000000000100000",
	"00000010001100111000100000100101",
	"00100001000010000000000000000011",
	"00100001001010010000000000000011",
	"00100011101111011111111111111000",
	"00100000100001001111111111111111",
	"00000000000001000010100000101010",
	"00010000101000000000000000000001",
	"00001000000100000000000000000110",
	"00001000000100000000000000011000"
	);

	-- ALU Parameters --
	constant n_bits_alu  : natural := n_bits_data;
	constant n_functions_alu : natural := 16;

	-- Format Parameters --
	constant opcode_end           : natural := 31;
	constant opcode_start         : natural := 26;
	constant rs_end               : natural := 25;
	constant rs_start             : natural := 21;
	constant rt_end               : natural := 20;
	constant rt_start             : natural := 16;
	constant rd_end               : natural := 15;
	constant rd_start             : natural := 11;
	constant shamt_end            : natural := 10;
	constant shamt_start          : natural :=  6;	
	constant funct_end            : natural :=  5;
	constant funct_start          : natural :=  0;

	constant immediate_end        : natural := 15;
	constant immediate_start      : natural :=  0;
	
	constant pseudo_address_end   : natural := 25;
	constant pseudo_address_start : natural :=  0;

	-- Memory Mapping Parameters --
	constant text_segment_start : std_logic_vector(n_bits_address - 1 downto 0) := x"00400000";
	constant data_segment_start : std_logic_vector(n_bits_address - 1 downto 0) := x"10010000";
   	constant TOS : std_logic_vector(reg_file_width - 1 downto 0) := data_segment_start + (data_mem_depth - 1)*4; -- Top-Of-Stack
	

	-- Utility Functions --
	function n_bits_of (X : in integer) return integer;

end package my_package;

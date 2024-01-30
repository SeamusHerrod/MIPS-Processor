LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.my_package.ALL;

ENTITY DataMem IS
   PORT( 
      A        : IN  std_logic_vector (n_bits_address - 1 DOWNTO 0);
      MemWrite : IN  std_logic;
      WD       : IN  std_logic_vector (data_mem_width - 1 DOWNTO 0);
      clk      : IN  std_logic;
      rst      : IN  std_logic;
      RD       : OUT std_logic_vector (data_mem_width - 1 DOWNTO 0)
   );
END DataMem;

ARCHITECTURE behav OF DataMem IS

   -- Internal signal declarations
   SIGNAL data_mem  : mem_type(0 to data_mem_depth - 1);

BEGIN

   -- **************************** --
   -- DO NOT MODIFY or CHANGE the ---
   -- code template provided above --
   -- **************************** --
   
   ----- insert your code here ------
   -- Process that combines address guard, and multiplexer for read port
   ---------------------------------------------------------------------------
   read_port : PROCESS (A, data_mem)
   ---------------------------------------------------------------------------
   BEGIN
      RD <= (OTHERS => '0');
      IF (( to_integer( unsigned( A ) ) - to_integer( unsigned( text_segment_start)) )/4 > to_integer( unsigned( data_segment_start ) ) AND ( to_integer( unsigned( A ) ) - to_integer( unsigned( text_segment_start)) )/4 < (to_integer(unsigned(TOS)) - 32 )) THEN
         RD <= data_mem((to_integer( unsigned( A ) ) - to_integer( unsigned( text_segment_start)) )/4);
      END IF;
   END PROCESS read_port;   

   -- Process that combines inferred registers, write-enable, and address guard for the write port
   ---------------------------------------------------------------------------
   write_port : PROCESS (clk, rst)
   ---------------------------------------------------------------------------
   BEGIN
      -- Asynchronous Reset
      IF (rst = '1') THEN
         -- Reset Actions
         data_mem <= initial_data_mem;
      ELSIF (clk'EVENT AND clk = '1') THEN -- inferred registers
         -- Write-enable, and address guard for write operation
         IF ((MemWrite = '1') AND ( to_integer( unsigned( A ) ) - to_integer( unsigned( text_segment_start)) )/4 > to_integer( unsigned( data_segment_start ) ) AND ( to_integer( unsigned( A ) ) - to_integer( unsigned( text_segment_start)) )/4 < (to_integer(unsigned(TOS)) - 32 )) THEN
            data_mem((to_integer( unsigned( A ) ) - to_integer( unsigned( text_segment_start)) )/4) <= WD;
         END IF;
      END IF;
   END PROCESS write_port;

   ----------------------------------    

END behav;



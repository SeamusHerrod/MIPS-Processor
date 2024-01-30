LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.my_package.ALL;

ENTITY PC_register IS
   PORT( 
      PC_next    : IN     std_logic_vector (n_bits_address - 1 DOWNTO 0);
      clk        : IN     std_logic;
      rst        : IN     std_logic;
      PC_current : OUT    std_logic_vector (n_bits_address - 1 DOWNTO 0)
   );
END PC_register;

ARCHITECTURE behav OF PC_register IS

BEGIN

   -- **************************** --
   -- DO NOT MODIFY or CHANGE the ---
   -- code template provided above --
   -- **************************** --
   
   ----- insert your code here ------
  PC_reg: process ( clk, rst )
  BEGIN
  
    IF ( rst = '1' ) THEN
        PC_current <= text_segment_start;
    ELSIF ( clk'EVENT AND clk = '1' ) THEN
        PC_current <= PC_next;
    END IF;
  
  END PROCESS;
   ----------------------------------
   
END behav;

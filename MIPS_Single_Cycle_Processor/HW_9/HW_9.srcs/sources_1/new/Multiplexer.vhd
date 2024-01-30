LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.my_package.ALL;

entity Multiplexer is
    Port ( SEL : in STD_LOGIC;
           A   : in STD_LOGIC_VECTOR( (n_bits_data - 1) downto 0);
           B   : in STD_LOGIC_VECTOR( (n_bits_data - 1) downto 0);
           X   : out STD_LOGIC_VECTOR( (n_bits_data - 1) downto 0)
           );
end Multiplexer;

architecture Behavioral of Multiplexer is

begin

  mux : process ( SEL, A, B )
  BEGIN
    IF ( SEL <= '1' ) THEN
        X <= B;
    ELSE
        X <= A;
    END IF;
  END PROCESS;
end Behavioral;

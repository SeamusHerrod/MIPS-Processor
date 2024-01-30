LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.my_package.ALL;

entity five_x_one_mux is
    Port ( SEL : in STD_LOGIC;
           A   : in STD_LOGIC_VECTOR( 4 downto 0);
           B   : in STD_LOGIC_VECTOR( 4 downto 0);
           X   : out STD_LOGIC_VECTOR( 4 downto 0)
           );
end five_x_one_mux;

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

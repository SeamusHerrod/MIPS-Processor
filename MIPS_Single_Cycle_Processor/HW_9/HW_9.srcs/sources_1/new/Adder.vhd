LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.my_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Adder is
    Port ( PC_cur : in STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
           PC_inc : out STD_LOGIC_VECTOR(n_bits_data - 1 downto 0)
    );
end Adder;


architecture Behavioral of Adder is

begin

--PC_increment <= to_integer( unsigned( PC_cur ) ) + 4;
PC_inc <= std_logic_vector( unsigned( PC_cur ) + 4 );

end Behavioral;

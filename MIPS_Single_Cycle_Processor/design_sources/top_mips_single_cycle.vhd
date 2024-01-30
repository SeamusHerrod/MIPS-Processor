LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.my_package.ALL;

ENTITY mips_single_cycle IS
   PORT( 
      clk : IN     std_logic;
      rst : IN     std_logic
   );
END mips_single_cycle ;

ARCHITECTURE struct OF mips_single_cycle IS
   
   -- PC Register Signals --
   SIGNAL PC_next          : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL PC_current       : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL PC_inc           : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL PC_cond_branch   : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL PC_uncond_branch : std_logic_vector (n_bits_address - 1 DOWNTO 0);    
   
   -- Instruction Memory Signals --
   SIGNAL InstrMem_A     : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL InstrMem_Instr : std_logic_vector (instr_mem_width - 1 DOWNTO 0);
   
   -- Register File Signals --
   SIGNAL RegFile_RA1      : std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
   SIGNAL RegFile_RA2      : std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
   SIGNAL RegFile_RegWrite : std_logic;
   SIGNAL RegFile_WA       : std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
   SIGNAL RegFile_WD       : std_logic_vector (reg_file_width - 1 DOWNTO 0);
   SIGNAL RegFile_RD1      : std_logic_vector (reg_file_width - 1 DOWNTO 0);
   SIGNAL RegFile_RD2      : std_logic_vector (reg_file_width - 1 DOWNTO 0);
   
   -- ALU Signals --
   SIGNAL ALU_A          : std_logic_vector (n_bits_alu - 1 DOWNTO 0);
   SIGNAL ALU_ALUControl : std_logic_vector (n_bits_of(n_functions_alu) - 1 DOWNTO 0);
   SIGNAL ALU_B          : std_logic_vector (n_bits_alu - 1 DOWNTO 0);
   SIGNAL ALU_C          : std_logic_vector (n_bits_alu - 1 DOWNTO 0);
   SIGNAL ALU_zero       : std_logic;
   SIGNAL ALU_overflow   : std_logic; 
   
   -- Data Memory Signals --
   SIGNAL DataMem_A        : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL DataMem_MemWrite : std_logic;
   SIGNAL DataMem_WD       : std_logic_vector (data_mem_width - 1 DOWNTO 0);
   SIGNAL DataMem_RD       : std_logic_vector (data_mem_width - 1 DOWNTO 0);

   -- Control Unit Signals --
   SIGNAL CU_Instr      : std_logic_vector (n_bits_instr - 1 DOWNTO 0);
   SIGNAL CU_ALUControl : std_logic_vector (n_bits_of(n_functions_alu) - 1 DOWNTO 0);
   SIGNAL CU_ALUSrc     : std_logic;
   SIGNAL CU_BEQ        : std_logic;
   SIGNAL CU_J          : std_logic;
   SIGNAL CU_MemToReg   : std_logic;
   SIGNAL CU_MemWrite   : std_logic;
   SIGNAL CU_RegDst     : std_logic;
   SIGNAL CU_RegWrite   : std_logic;
   
   -- Format-Dependent Signals --
   SIGNAL opcode         : std_logic_vector (        opcode_end DOWNTO opcode_start);
   SIGNAL rs             : std_logic_vector (            rs_end DOWNTO rs_start);
   SIGNAL rt             : std_logic_vector (            rt_end DOWNTO rt_start);
   SIGNAL rd             : std_logic_vector (            rd_end DOWNTO rd_start);
   SIGNAL shamt          : std_logic_vector (         shamt_end DOWNTO shamt_start);
   SIGNAL funct          : std_logic_vector (         funct_end DOWNTO funct_start);
   SIGNAL immediate      : std_logic_vector (     immediate_end DOWNTO immediate_start);
   SIGNAL pseudo_address : std_logic_vector (pseudo_address_end DOWNTO pseudo_address_start);

   -- Internal Signals --
   SIGNAL immediate_Sign_Extended : std_logic_vector (n_bits_alu - 1 DOWNTO 0);
   SIGNAL relative_address        : std_logic_vector (n_bits_address - 1 DOWNTO 0); 
   SIGNAL branch_taken            : std_logic;

   -- WA_Mux Signals --
    SIGNAL WA_mux_SEL    : std_logic;
    SIGNAL WA_mux_A      : STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL WA_mux_B      : STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL WA_mux_X      : STD_LOGIC_VECTOR(4 downto 0);
    
   -- ALUSrc_Mux Signals --
    SIGNAL ALUSrc_mux_SEL    : std_logic;
    SIGNAL ALUSrc_mux_A      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    SIGNAL ALUSrc_mux_B      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    SIGNAL ALUSrc_mux_X      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    
    -- BT_Mux Signals --
    SIGNAL BT_mux_SEL    : std_logic;
    SIGNAL BT_mux_A      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    SIGNAL BT_mux_B      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    SIGNAL BT_mux_X      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    
    -- PCNext_Mux Signals -- 
    SIGNAL PCNext_mux_SEL    : std_logic;
    SIGNAL PCNext_mux_A      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    SIGNAL PCNext_mux_B      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    SIGNAL PCNext_mux_X      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    
    -- WD_Mux Signals --
    SIGNAL WD_mux_SEL    : std_logic;
    SIGNAL WD_mux_A      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    SIGNAL WD_mux_B      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    SIGNAL WD_mux_X      : STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
    
   -- Component Declarations --
   
    COMPONENT Multiplexer
       PORT ( 
           SEL : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
           B : in STD_LOGIC_VECTOR(n_bits_data - 1 downto 0);
           X : out STD_LOGIC_VECTOR(n_bits_data - 1 downto 0)
       );
    END COMPONENT;
    
    COMPONENT five_x_one_mux
        PORT(
           SEL : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR(4 downto 0);
           B : in STD_LOGIC_VECTOR(4 downto 0);
           X : out STD_LOGIC_VECTOR(4 downto 0)
       );  
    END COMPONENT;
    
	COMPONENT PC_register
	   PORT( 
	      PC_next    : IN     std_logic_vector (n_bits_address - 1 DOWNTO 0);
	      clk        : IN     std_logic;
	      rst        : IN     std_logic;
	      PC_current : OUT    std_logic_vector (n_bits_address - 1 DOWNTO 0)
	   );
	END COMPONENT;   

	COMPONENT InstrMem
	   PORT( 
	      A     : IN  std_logic_vector (n_bits_address - 1 DOWNTO 0);
	      rst   : IN  std_logic;
	      Instr : OUT std_logic_vector (instr_mem_width - 1 DOWNTO 0)
	   );
	END COMPONENT;

	COMPONENT RegFile 
	   PORT( 
	      RA1      : IN  std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
	      RA2      : IN  std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
	      RegWrite : IN  std_logic;
	      WA       : IN  std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
	      WD       : IN  std_logic_vector (reg_file_width - 1 DOWNTO 0);
	      clk      : IN  std_logic;
	      rst      : IN  std_logic;
	      RD1      : OUT std_logic_vector (reg_file_width - 1 DOWNTO 0);
	      RD2      : OUT std_logic_vector (reg_file_width - 1 DOWNTO 0)
	   );
	END COMPONENT;

	COMPONENT ALU
	   PORT( 
	      A           : IN     std_logic_vector (n_bits_alu - 1 DOWNTO 0);
	      ALUControl  : IN     std_logic_vector (n_bits_of(n_functions_alu) - 1 DOWNTO 0);
	      B           : IN     std_logic_vector (n_bits_alu - 1 DOWNTO 0);
	      C           : OUT    std_logic_vector (n_bits_alu - 1 DOWNTO 0);
	      zero        : OUT    std_logic;
	      overflow    : OUT    std_logic
	   );
	END COMPONENT;	
   
	COMPONENT DataMem
	   PORT( 
	      A        : IN  std_logic_vector (n_bits_address - 1 DOWNTO 0);
	      MemWrite : IN  std_logic;
	      WD       : IN  std_logic_vector (data_mem_width - 1 DOWNTO 0);
	      clk      : IN  std_logic;
	      rst      : IN  std_logic;
	      RD       : OUT std_logic_vector (data_mem_width - 1 DOWNTO 0)
	   );
	END COMPONENT;

	COMPONENT CU
	   PORT( 
	      Instr      : IN     std_logic_vector (n_bits_instr - 1 DOWNTO 0);
	      ALUControl : OUT    std_logic_vector (n_bits_of(n_functions_alu) - 1 DOWNTO 0);
	      ALUSrc     : OUT    std_logic;
	      BEQ        : OUT    std_logic;
	      J          : OUT    std_logic;
	      MemToReg   : OUT    std_logic;
	      MemWrite   : OUT    std_logic;
	      RegDst     : OUT    std_logic;
	      RegWrite   : OUT    std_logic
	   );
	END COMPONENT;	

BEGIN

      --------------------
      -- Important Hint --
      --------------------
        -- When you use the components "PC_register", "InstrMem", "RegFile", "ALU", "DataMem", and "CU", in this top-level design 
        -- "top_mips_single_cycle.vhd", name their instances by appending "_inst" to the end of the component name as follows 
        -- "PC_register_inst", "InstrMem_inst", "RegFile_inst", "ALU_inst", "DataMem_inst", and "CU_inst". 
        -- This will guarantee the correct setup of your waveform configuration for showing all needed signals. For example:
              -- PC_register_inst : PC_register
              --   PORT MAP ( 
              --             PC_next    => ... ,
              --             clk        => ... ,
              --             rst        => ... ,
              --             PC_current => ...
              --   );
      --------------------
      
   -- **************************** --
   -- DO NOT MODIFY or CHANGE the ---
   -- code template provided above --
   -- **************************** --
   
   ----- insert your code here ------
   PC_register_inst : PC_register
    PORT MAP (
        PC_next => PC_next,
        PC_current => PC_current,
        clk => clk,
        rst => rst
        );    
   PC_inc <= std_logic_vector( unsigned( PC_next ) + 4 );	
   PC_next <= PCNext_mux_X; 
    InstrMem_inst : InstrMem
	   PORT map ( 
	      A     => InstrMem_A ,
	      rst   => rst,
	      Instr => InstrMem_Instr
	   );
	InstrMem_A <= PC_current;
	
	ALU_inst : ALU
	   PORT MAP( 
	      A    	      => ALU_A, 
	      ALUControl  => ALU_ALUControl, 
	      B           => ALU_B,
	      C           => ALU_C,
	      zero        => ALU_zero,
	      overflow    => ALU_overflow
	   );
	   ALU_ALUControl <= CU_ALUControl;
	   ALU_A <= RegFile_RD1;
	   ALU_B <= ALUSrc_mux_X;
		
	DataMem_inst : DataMem
	   PORT MAP( 
	      A    	    => DataMem_A ,
	      MemWrite  => DataMem_MemWrite,
	      WD        => DataMem_WD,
	      clk       => clk,
	      rst       => rst,
	      RD        => DataMem_RD 
	   );
	DataMem_A <= ALU_C;
	DataMem_MemWrite <= CU_MemWrite;
	DataMem_WD <= RegFile_RD2;
	
	CU_inst : CU
	   PORT MAP( 
	      Instr       => CU_Instr,
	      ALUControl  => CU_ALUControl,
	      ALUSrc      => CU_ALUSrc,
	      BEQ         => CU_BEQ,
	      J           => CU_J,
	      MemToReg    => CU_MemToReg,
	      MemWrite    => CU_MemWrite,
	      RegDst      => CU_RegDst,
	      RegWrite    => CU_RegWrite 
	   );
	   
     RegFile_inst : RegFile
	   PORT MAP( 
	      RA1      => RegFile_RA1,
	      RA2      => RegFile_RA2,
	      RegWrite => RegFile_RegWrite,
	      WA       => RegFile_WA,
	      WD       => RegFile_WD,
	      clk      => clk,
	      rst      => rst,
	      RD1      => RegFile_RD1,
	      RD2      => RegFile_RD2
	   );
    RegFile_RegWrite <= CU_RegWrite;
    RegFile_RA1 <= InstrMem_Instr(rs_end downto rs_start);
    RegFile_RA2 <= InstrMem_Instr(rt_end downto rt_start);
    RegFile_WA <= WA_mux_X;
    
     WA_mux_inst:  five_x_one_mux
       PORT MAP( 
           SEL => WA_mux_SEL,
           A   => WA_mux_A,
           B   => WA_mux_B,
           X   => WA_mux_X
       );
     WA_mux_SEL <= CU_RegDst;
     WA_mux_A <= InstrMem_Instr(rt_end downto rt_start);
     WA_mux_B <= InstrMem_Instr(rd_end downto rd_start);
     
     ALUSrc_mux_inst: Multiplexer
        PORT MAP(
            SEL => ALUSrc_mux_SEL,
            A   => ALUSrc_mux_A,
            B   => ALUSrc_mux_B,
            X   => ALUSrc_mux_X
        );
     ALUSrc_mux_SEL <= CU_ALUSrc;
     ALUSrc_mux_A <= RegFile_RD2;
     ALUSrc_mux_B <= std_logic_vector( resize( signed(InstrMem_Instr(rd_end downto 0)), ALUSrc_mux_B'length));
     
     BT_mux_inst: Multiplexer
        PORT MAP(
           SEL  => BT_mux_SEL,
           A    => BT_mux_A,
           B    => BT_mux_B,
           X    => BT_mux_X
        );
     BT_mux_SEL <= CU_BEQ and ALU_zero;
     BT_mux_A <= PC_inc;
     BT_mux_B <= ALUSrc_mux_B & x"00";
     --BT_mux_B <= std_logic_vector( resize( signed(InstrMem_Instr(rd_end downto 0)), BT_mux_B'length)) & x"00"; -- 
     --BT_mux_B <= std_logic_vector( unsigned( BT_mux_B ) + unsigned( PC_inc ) );
     
     PCNext_mux_inst: Multiplexer
        PORT MAP (
            SEL => PCNext_mux_SEL,
            A   => PCNext_mux_A,
            B   => PCNext_mux_B,
            X   => PCNext_mux_X
        );
     PCNext_mux_SEL <= CU_j;
     PCNext_mux_B <= BT_mux_X;
     PCNext_mux_A <= std_logic_vector( ( unsigned( std_logic_vector( resize( unsigned(InstrMem_Instr(rs_end downto 0)), PCNext_mux_A'length)) )*4 ) + unsigned( PC_inc ) );
   ----------------------------------

END struct;

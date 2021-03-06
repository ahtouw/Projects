--------------------------------------------------------------------------------
--
-- LAB #3
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity bitstorage is
	port(bitin: in std_logic;
		 enout: in std_logic;
		 writein: in std_logic;
		 bitout: out std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
	signal q: std_logic := '0';
begin
	process(writein) is
	begin
		if (rising_edge(writein)) then
			q <= bitin;
		end if;
	end process;
	
	-- Note that data is output only when enout = 0	
	bitout <= q when enout = '0' else 'Z';
end architecture memlike;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity fulladder is
    port (a : in std_logic;
          b : in std_logic;
          cin : in std_logic;
          sum : out std_logic;
          carry : out std_logic
         );
end fulladder;

architecture addlike of fulladder is
begin
  sum   <= a xor b xor cin; 
  carry <= (a and b) or (a and cin) or (b and cin); 
end architecture addlike;


--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
end entity register8;

architecture memmy of register8 is
	component bitstorage
		port(bitin: in std_logic;
		 	 enout: in std_logic;
		 	 writein: in std_logic;
		 	 bitout: out std_logic);
	end component;
begin
	GEN_REG:
	for i in 0 to 7 generate
		U1: bitstorage port map (datain(i),enout,writein,dataout(i));
	end generate GEN_REG;

end architecture memmy;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register32 is
	port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
end entity register32;

architecture biggermem of register32 is
	component register8
		port(datain: in std_logic_vector(7 downto 0);
			enout: in std_logic;
			writein: in std_logic;
			dataout: out std_logic_vector(7 downto 0));
	end component;
begin
	U1: register8 port map (datain(7 downto 0), enout8, writein8, dataout(7 downto 0));
	U2: register8 port map (datain(15 downto 8), enout16, writein16, dataout(15 downto 8));
	U3: register8 port map (datain(23 downto 16), enout32, writein32, dataout(23 downto 16));
	U4: register8 port map (datain(31 downto 24), enout32, writein32, dataout(31 downto 24));
end architecture biggermem;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
	port(	datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic);
end entity adder_subtracter;

architecture calc of adder_subtracter is
	component fulladder
		port (a : in std_logic;
          	b : in std_logic;
         	 cin : in std_logic;
          	sum : out std_logic;
          	carry : out std_logic
        	 );
	end component;
	signal c: std_logic_vector (0 to 30); --signal vector to save carry out to
	signal b: std_logic_vector (31 downto 0); -- signal vector to store datain_b if add_sub is 1 meaning it needs to subtract 
begin
	invert: for m in 31 downto 0 generate
		b(m) <= datain_b(m) xor add_sub;
	end generate invert;
		a0: fulladder port map(datain_a(0), b(0), add_sub, dataout(0), c(0));
		stage: for I in 1 to 30 generate
			as: fulladder port map(datain_a(I), b(I), c(I-1), dataout(I), c(I));
		end generate stage;
		a31: fulladder port map(datain_a(31), b(31), c(30), dataout(31), co);  
end architecture calc;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
	port(	datain: in std_logic_vector(31 downto 0);
	   	dir: in std_logic;
		shamt:	in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
end entity shift_register;

architecture shifter of shift_register is
	
begin
	process(dir, shamt) is

	begin
	if (dir ='1') then
		case shamt is
		when "00001" =>
			dataout<= ("0"&datain(31 downto 1));
		when "00010" =>
			dataout<= ("00"&datain(31 downto 2));
		when "00011" =>
			dataout<= ("000"&datain(31 downto 3));
		when others =>
			dataout<= datain(31 downto 0);
		end case;

	else
		case shamt is
		when "00001" =>
			dataout<= (datain(30 downto 0)&"0");
		when "00010" =>
			dataout<= (datain(29 downto 0)&"00");
		when "00011" =>
			dataout<= (datain(28 downto 0)&"000");
		when others =>
			dataout<= datain(31 downto 0);
		end case;

	end if;
	end process;
end architecture shifter;




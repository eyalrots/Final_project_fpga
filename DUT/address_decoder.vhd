LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.aux_package.all;
-------------------------------------
ENTITY address_decoder IS
    generic (
        ADDRESS_BUS_WIDTH : integer := 12
    );
    PORT (
        address_bus_i : in std_logic_vector(ADDRESS_BUS_WIDTH-1 downto 0);
        cs_vec_o      : out std_logic_vector(7 downto 0)
    );
END address_decoder;
--------------------------------------------------------------
ARCHITECTURE address_decoder_arc OF address_decoder IS
begin
    cs_vec_o <= (others=>'0') when (address_bus_i(11)='0' or (conv_integer(address_bus_i(4 downto 2))=0 and address_bus_i/=X"800")) else 
                (conv_integer(address_bus_i(4 downto 2))=>'1', others=>'0');
end architecture;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;
-------------------------------------
ENTITY led_io IS
    generic (
        DATA_BUS_WIDTH : integer := 32
    );
    PORT (
        MemRead_i   : in std_logic;
        MemWrite_i  : in std_logic;
        CS_i        : in std_logic;
        data_bus_io : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
        data_o      : out std_logic_vector(7 downto 0)
    );
END led_io;
--------------------------------------------------------------
ARCHITECTURE led_io_arc OF led_io IS
    signal latch_en : std_logic;
    signal read_en  : std_logic;
    signal data_w   : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal bus_led_w: std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
begin
    latch_en <= CS_i and MemWrite_i;
    read_en  <= CS_i and MemRead_i;

    seg_latch: process (latch_en)
    begin
        if (latch_en='1') then 
            data_w <= data_bus_io;
        end if;
    end process;

    bus_led_w <= data_w when read_en='1' else (others => 'Z');
    data_bus_io <= data_w when read_en='1' else (others => 'Z');

    data_o <= data_w(7 downto 0);
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.aux_package.all;
-------------------------------------
ENTITY fir_top IS
    GENERIC (
        DATA_BUS_WIDTH : INTEGER := 32);
    PORT (
        clk_i, rst_i    : in    std_logic;
        mem_rd_i        : in    std_logic;
        mem_wr_i        : in    std_logic;
        addr_bus_i      : in    std_logic_vector(11 downto 0);
        data_bus_io     : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
        fifo_empty_o    : out   std_logic;
        fir_ifg_o       : out   std_logic
    );
END fir_top;
--------------------------------------------------------------
architecture fir_top_arc of fir_top is
    signal FIRIN_w      : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal FIROUT_w     : std_logic_vector(DATA_BUS_WIDTH-1 downto 0) := (others=>'0');
    signal FIRCTL_w     : std_logic_vector(7 downto 0);
    signal COEF3_0_w    : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal COEF7_4_w    : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal mclk2_w      : std_logic;
    signal mclk4_w      : std_logic;
    signal mclk8_w      : std_logic;
    signal div4         : std_logic;
    signal div8         : std_logic_vector(1 downto 0);
    signal read_en_w    : std_logic_vector(4 downto 0) := (others=>'0');
    signal zero_vec_w   : std_logic_vector(23 downto 0) := (others=>'0');
begin
    -- registers --
    fir_regs: process (clk_i)
    begin
        if (rst_i='1') then
            FIRCTL_w    <= (others=>'0');
            FIRIN_w     <= (others=>'0');
            COEF3_0_w   <= (others=>'0');
            COEF7_4_w   <= (others=>'0');
            FIROUT_w    <= (others=>'0');
        elsif (falling_edge(clk_i)) then
            if (mem_wr_i='1') then
                case addr_bus_i is
                    when X"82C" =>
                        FIRCTL_w(0) <= data_bus_io(0);
                        FIRCTL_w(1) <= data_bus_io(1);
                        FIRCTL_w(4) <= data_bus_io(4);
                        FIRCTL_w(5) <= data_bus_io(5);
                    when X"830" =>
                        FIRIN_w <= data_bus_io;
                    when X"838" =>
                        COEF3_0_w <= data_bus_io;
                    when X"83C" =>
                        COEF7_4_w <= data_bus_io;
                    when others => 
                        FIRCTL_w(5) <= '0';
                end case;
            end if;
        end if;
    end process;

    read_en_w(0) <= '1' when (addr_bus_i=X"82C" and mem_rd_i='1') else '0';
    read_en_w(1) <= '1' when (addr_bus_i=X"830" and mem_rd_i='1') else '0';
    read_en_w(2) <= '1' when (addr_bus_i=X"834" and mem_rd_i='1') else '0';
    read_en_w(3) <= '1' when (addr_bus_i=X"838" and mem_rd_i='1') else '0';
    read_en_w(4) <= '1' when (addr_bus_i=X"83C" and mem_rd_i='1') else '0';

    data_bus_io <= zero_vec_w & FIRCTL_w when read_en_w(0)='1' else
                    FIRIN_w  when read_en_w(1)='1' else
                    FIROUT_w when read_en_w(2)='1' else
                    COEF3_0_w when read_en_w(3)='1' else
                    COEF7_4_w when read_en_w(4)='1' else
                    (others=>'Z');

    div_cnt: process(clk_i,rst_i)
    begin 
        if (rst_i='1') then
            mclk2_w <= '0';
			mclk4_w <= '0';
			mclk8_w <= '0';
            div4 <= '0';
            div8 <= "00";
        end if;
        if (rising_edge(clk_i)) then
            mclk2_w <= not (mclk2_w);
            div4 <= not(div4);
			if (div4='1') then
				mclk4_w <= not(mclk4_w);
			end if;
            div8 <= std_logic_vector(ieee.numeric_std.unsigned(div8) + 1);
			if (div8="11") then
				mclk8_w <= not(mclk8_w);
			end if;
        end if;
    end process;

    -- logic --
    FIR_filter: FIR port map(
        FIRIN_i     =>  FIRIN_w,
        coef0_i     =>  COEF3_0_w(7 downto 0),
        coef1_i     =>  COEF3_0_w(15 downto 8),
        coef2_i     =>  COEF3_0_w(23 downto 16),
        coef3_i     =>  COEF3_0_w(DATA_BUS_WIDTH-1 downto 24),
        coef4_i     =>  COEF7_4_w(7 downto 0),
        coef5_i     =>  COEF7_4_w(15 downto 8),
        coef6_i     =>  COEF7_4_w(23 downto 16),
        coef7_i     =>  COEF7_4_w(DATA_BUS_WIDTH-1 downto 24),
        FIFORST_i   =>  FIRCTL_w(4),
        FIFOCLK_i   =>  clk_i,
        FIFOWEN_i   =>  FIRCTL_w(5),
        FIRCLK_i    =>  mclk8_w,
        FIRRST_i    =>  FIRCTL_w(1),
        FIRENA_i    =>  FIRCTL_w(0),
        FIROUT_o    =>  FIROUT_w,
        FIFOFULL_o  =>  FIRCTL_w(3),
        FIFOEMPTY_o =>  FIRCTL_w(2),
        FIRIFG_o    =>  fir_ifg_o
    );

    fifo_empty_o <= FIRCTL_w(2);
end architecture;
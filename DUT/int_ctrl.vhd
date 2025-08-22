library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------
ENTITY int_ctrl IS
    GENERIC (
        DATA_BUS_WIDTH : INTEGER := 32);
    PORT (
        clk_i           : in std_logic;
        rst_i           : in std_logic;
        RX_INT_i        : in std_logic;
        TX_INT_i        : in std_logic;
        BT_INT_i        : in std_logic;
        KEY1_INT_i      : in std_logic;
        KEY2_INT_i      : in std_logic;
        KEY3_INT_i      : in std_logic;
        FIR_INT_i       : in std_logic;
        CS_i            : in std_logic;
        INTA_i          : in std_logic;
        GIE             : in std_logic;
        MemRead_ctrl_i  : in std_logic;
        MemWrite_ctrl_i : in std_logic;
        A0_i            : in std_logic;
        fir_empty_i     : in std_logic;
        -- addr_bus_i		: in std_logic_vector(DTCM_ADDR_WIDTH-1 downto 0);
        INTR_o          : out std_logic;  
        data_bus_io     : inout std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
    );
END int_ctrl;
--------------------------------------------------------------
architecture int_ctrl_arc of int_ctrl is
TYPE type_register IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal TYPE_r      : type_register := (X"00",X"04",X"08",X"0C",X"10",X"14",X"18",X"1C"
                                            ,X"20",X"24");
    signal IE_r      : std_logic_vector(7 downto 0);
    signal IFG_r      : std_logic_vector(7 downto 0);
    signal highest_priority_w : integer range 0 to 7;
    signal enabled_flags_w  : std_logic_vector(7 downto 0);
    signal zero_vec_w       : std_logic_vector(23 downto 0) := (others=>'0');
    signal cur_type         : std_logic_vector(7 downto 0);
begin

    rd_wr_regs: process (clk_i)
    begin
    end process;

    ifg_handle: process (clk_i, rst_i)
    begin
        if (rst_i='1') then
            IFG_r <= (others=>'0');
        elsif (falling_edge(clk_i)) then
            --- set flag according to interrupt ---
            if RX_INT_i   = '1' then IFG_r(0) <= '1'; end if;
            if TX_INT_i   = '1' then IFG_r(1) <= '1'; end if;
            if BT_INT_i   = '1' then IFG_r(2) <= '1'; end if;
            if KEY1_INT_i = '1' then IFG_r(3) <= '1'; end if;
            if KEY2_INT_i = '1' then IFG_r(4) <= '1'; end if;
            if KEY3_INT_i = '1' then IFG_r(5) <= '1'; end if;
            if FIR_INT_i  = '1' then IFG_r(6) <= '1'; end if;
            --- set handled falg to 0 ---
            if (INTA_i = '0') then
                if (highest_priority_w=1) then
                    IFG_r(highest_priority_w) <= '0';
                else
                    IFG_r(highest_priority_w - 2) <= '0';
                end if;
            end if;
            --- read / write internal registers ---
            if (CS_i='1') then
                if (MemWrite_ctrl_i='1') then 
                    if (A0_i='0') then
                        IE_r <= data_bus_io(7 downto 0);
                    else
                        IFG_r <= data_bus_io(7 downto 0);
                    end if;
                elsif (MemRead_ctrl_i='1') then
                    if (A0_i='0') then
                        data_bus_io <= zero_vec_w & IE_r;
                    else
                        data_bus_io <= zero_vec_w & IFG_r;
                    end if;
                end if;
            end if;
        end if;
    end process;

    --- set highest priority flag ---
    enabled_flags_w <= IFG_r and IE_r;

    priority: process (enabled_flags_w)
    begin
        if    enabled_flags_w(0) = '1' then highest_priority_w <= 1;
        elsif enabled_flags_w(1) = '1' then highest_priority_w <= 3;
        elsif enabled_flags_w(2) = '1' then highest_priority_w <= 4;
        elsif enabled_flags_w(3) = '1' then highest_priority_w <= 5;
        elsif enabled_flags_w(4) = '1' then highest_priority_w <= 6;
        elsif enabled_flags_w(5) = '1' then highest_priority_w <= 7;
        elsif enabled_flags_w(6) = '1' then highest_priority_w <= 8;
        else                                highest_priority_w <= 9; -- Default case
        end if;
    end process;

    --- set INTR=1 when there is an interrupt to handle ---
    INTR_o <= '1' when (enabled_flags_w /= X"00" and GIE = '1') else '0';
    
    -- write type value of highest priority to data bus ---
    cur_type <= TYPE_r(highest_priority_w + 1) when (fir_empty_i='0' and highest_priority_w=8) else
                TYPE_r(highest_priority_w); -- Rx should coose one of two!
    data_bus_io <= cur_type when INTA_i = '0' else (others => 'Z');
end architecture;
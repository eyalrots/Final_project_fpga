LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;
-------------------------------------
ENTITY mcu IS
    	generic( 
			WORD_GRANULARITY : boolean 	:= G_WORD_GRANULARITY;
	        MODELSIM : integer 			:= G_MODELSIM;
			DATA_BUS_WIDTH : integer 	:= 32;
			ITCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
			DTCM_ADDR_WIDTH : integer 	:= 12;
			PC_WIDTH : integer 			:= 10;
			FUNCT_WIDTH : integer 		:= 6;
			DATA_WORDS_NUM : integer 	:= G_DATA_WORDS_NUM;
			CLK_CNT_WIDTH : integer 	:= 16;
			INST_CNT_WIDTH : integer 	:= 16
	);
    PORT (
        clk_i               : std_logic;
        rst_i               : std_logic;
        --- GPIO ---
        sw_i                : in  std_logic_vector(7 downto 0);
        hex0_o              : out std_logic_vector(6 downto 0);
        hex1_o              : out std_logic_vector(6 downto 0);
        hex2_o              : out std_logic_vector(6 downto 0);
        hex3_o              : out std_logic_vector(6 downto 0);
        hex4_o              : out std_logic_vector(6 downto 0);
        hex5_o              : out std_logic_vector(6 downto 0);
        led_o               : out std_logic_vector(7 downto 0);
        pc_o                : out std_logic_vector(PC_WIDTH-1 downto 0);
        instruction_o       : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
        data_bus_o          : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);
        address_bus_o       : out std_logic_vector (DTCM_ADDR_WIDTH-1 downto 0);
        mem_wr_o            : out std_logic;
        mem_rd_o            : out std_logic;
		alu_result_o 		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		read_data1_o 		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		read_data2_o 		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		write_data_o		: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		Branch_ctrl_o		: OUT STD_LOGIC;
		Zero_o				: OUT STD_LOGIC; 
		RegWrite_ctrl_o		: OUT STD_LOGIC;
		inst_cnt_o 			: OUT STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
        pwm_o               : out std_logic
    );
END mcu;
--------------------------------------------------------------
ARCHITECTURE mcu_arc OF mcu is
    --- tri bus ---
    signal data_bus_w   : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal addr_bus_w   : std_logic_vector(11 downto 0);
    signal mem_wr_en_w  : std_logic;
    signal mem_rd_en_w  : std_logic;
    --- address decoder ---
    signal cs_vec_w     : std_logic_vector(7 downto 0) := (others=> '0');
    --- hex displays ---
    signal A0_not_w     : std_logic;
    signal hex0_data_w  : std_logic_vector(3 downto 0);
    signal hex1_data_w  : std_logic_vector(3 downto 0);
    signal hex2_data_w  : std_logic_vector(3 downto 0);
    signal hex3_data_w  : std_logic_vector(3 downto 0);
    signal hex4_data_w  : std_logic_vector(3 downto 0);
    signal hex5_data_w  : std_logic_vector(3 downto 0);
    --- basic timer ---
    signal BTCTL_w      : std_logic_vector(7 downto 0);
    signal BTCNT_w      : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal BTCCR0_w     : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal BTCCR1_w     : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal mclk2_w      : std_logic;
    signal mclk4_w      : std_logic;
    signal mclk8_w      : std_logic;
    signal div4         : std_logic;
    signal div8         : std_logic_vector(1 downto 0);
    signal BTIFG_w      : std_logic;
    --- FIR filter ---
    signal FIRIN_w     : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal FIROUT_w    : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal FIRCTL_w    : std_logic_vector(7 downto 0);
    signal COEF3_0_w   : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal COEF7_4_w   : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
    signal fifo_clk_w  : std_logic;
    signal fir_clk_w   : std_logic;
    signal fir_ifg_w   : std_logic;
    --- interrupts ---
    signal IFG_w        : std_logic_vector(7 downto 0);
    signal IE_w         : std_logic_vector(7 downto 0);
    --- random ---
    signal zero_vec_w   : std_logic_vector(23 downto 0);
begin
    --- out signals ---
    data_bus_o      <= data_bus_w;
    address_bus_o   <= addr_bus_w;
    mem_wr_o        <= mem_wr_en_w;
    mem_rd_o        <= mem_rd_en_w;


    --- mips core ---
    core: mips 
    generic map(
		WORD_GRANULARITY 			=> WORD_GRANULARITY,
	    MODELSIM 					=> MODELSIM,
		DATA_BUS_WIDTH				=> DATA_BUS_WIDTH,
		ITCM_ADDR_WIDTH				=> ITCM_ADDR_WIDTH,
		DTCM_ADDR_WIDTH				=> DTCM_ADDR_WIDTH,
		PC_WIDTH					=> PC_WIDTH,
		FUNCT_WIDTH					=> FUNCT_WIDTH,
		DATA_WORDS_NUM				=> DATA_WORDS_NUM,
		CLK_CNT_WIDTH				=> CLK_CNT_WIDTH,
		INST_CNT_WIDTH				=> INST_CNT_WIDTH
	)
    port map (
        rst_i           => rst_i,
        clk_i           => clk_i,
        data_bus_io     => data_bus_w,
        addr_bus_o      => addr_bus_w,
        MemWrite_ctrl_o => mem_wr_en_w,
        MemRead_ctrl_o  => mem_rd_en_w,
        pc_o            => pc_o,
        instruction_o   => instruction_o,
        Branch_ctrl_o   => Branch_ctrl_o,
        Zero_o          => Zero_o,
        RegWrite_ctrl_o => RegWrite_ctrl_o,
        alu_result_o    => alu_result_o,
        read_data1_o    => read_data1_o,
        read_data2_o    => read_data2_o,
        inst_cnt_o  => inst_cnt_o,
        write_data_o=> write_data_o
    );

    --- address decoder
    addr_decoder: address_decoder port map (
        address_bus_i   => addr_bus_w,
        cs_vec_o        => cs_vec_w
    );

    --- switches ---
    switch: sw_io port map (
        data_i          => sw_i,
        MemRead_i       => mem_rd_en_w,
        CS_i            => cs_vec_w(4),
        data_bus_io     => data_bus_w        
    );

    --- LEDs ---
    leds: led_io port map (
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        CS_i            => cs_vec_w(0),
        data_bus_io     => data_bus_w,
        data_o          => led_o
    );

    --- hex displays ---
    A0_not_w <= not(addr_bus_w(0));
    hex0: hex_seg port map (
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => A0_not_w,
        CS_i            => cs_vec_w(1),
        data_bus_io     => data_bus_w,
        data_o          => hex0_data_w
    );
    seg0: hex_decoder port map (
        Hex_in          => hex0_data_w,
        seg             => hex0_o
    );
    hex1: hex_seg port map (
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => A0_not_w,
        CS_i            => cs_vec_w(1),
        data_bus_io     => data_bus_w,
        data_o          => hex1_data_w
    );
    seg1: hex_decoder port map (
        Hex_in          => hex1_data_w,
        seg             => hex1_o
    );
    hex2: hex_seg port map (
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => A0_not_w,
        CS_i            => cs_vec_w(2),
        data_bus_io     => data_bus_w,
        data_o          => hex2_data_w
    );
    seg2: hex_decoder port map (
        Hex_in          => hex2_data_w,
        seg             => hex2_o
    );
    hex3: hex_seg port map (
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => A0_not_w,
        CS_i            => cs_vec_w(2),
        data_bus_io     => data_bus_w,
        data_o          => hex3_data_w
    );
    seg3: hex_decoder port map (
        Hex_in          => hex3_data_w,
        seg             => hex3_o
    );
    hex4: hex_seg port map (
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => A0_not_w,
        CS_i            => cs_vec_w(3),
        data_bus_io     => data_bus_w,
        data_o          => hex4_data_w
    );
    seg4: hex_decoder port map (
        Hex_in          => hex4_data_w,
        seg             => hex4_o
    );
    hex5: hex_seg port map (
        MemRead_i       => mem_rd_en_w,
        MemWrite_i      => mem_wr_en_w,
        A0_i            => A0_not_w,
        CS_i            => cs_vec_w(3),
        data_bus_io     => data_bus_w,
        data_o          => hex5_data_w
    );
    seg5: hex_decoder port map (
        Hex_in          => hex5_data_w,
        seg             => hex5_o
    );

    --- basic timer ---
    -- registers --
    bt_regs: process (clk_i)
    begin
        if (falling_edge(clk_i)) then
            write_mem: if (mem_wr_en_w='1') then
                case addr_bus_w is
                    when X"81C" =>
                        BTCTL_w <= zero_vec_w & data_bus_w(7 downto 0);
                    when X"820" =>
                        BTCNT_w <= data_bus_w;
                    when X"824" =>
                        BTCCR0_w <= data_bus_w;
                    when X"828" =>
                        BTCCR1_w <= data_bus_w;
                    when others =>
                        null;
                end case;
            end if;
            read_mem: if (mem_rd_en_w='1') then
                case addr_bus_w is
                    when X"81C" =>
                        data_bus_w <= zero_vec_w & BTCTL_w;
                    when X"820" =>
                        data_bus_w <= BTCNT_w;
                    when X"824" =>
                        data_bus_w <= BTCCR0_w;
                    when X"828" =>
                        data_bus_w <= BTCCR1_w;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;
    -- logic --
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

    timer: basic_timer port map (
        addr_bus_i      => addr_bus_w,
        BTCCR0_i        => BTCCR0_w,
        BTCCR1_i        => BTCCR1_w,
        BTCLR_i         => BTCTL_w(2),
        BTHOLD_i        => BTCTL_w(5),
        BTSSELx_i       => BTCTL_w(4 downto 3),
        MCLK_i          => clk_i,
        MCLK2_i         => mclk2_w,
        MCLK4_i         => mclk4_w,
        MCLK8_i         => mclk8_w,
        BTIPx_i         => BTCTL_w(1 downto 0),
        BTOUTMD_i       => BTCTL_w(7),
        BTOUTEN_i       => BTCTL_w(6),
        MemWrite_i      => mem_wr_en_w,
        MemRead_i       => mem_rd_en_w,
        PWM_o           => pwm_o,
        BTIFG_o         => BTIFG_w,
        BTCNT_io         => BTCNT_w
    );

    --- FIR filter ---
    -- clks --
    fifo_clk_w <= clk_i;
    fir_clk_w <= mclk8_w;
    -- registers --
    fir_regs: process (clk_i)
    begin
        if (falling_edge(clk_i)) then
            write_mem: if (mem_wr_en_w='1') then
                case addr_bus_w is
                    when X"82C" =>
                        FIRCTL_w(0) <= data_bus_w(0);
                        FIRCTL_w(1) <= data_bus_w(1);
                        FIRCTL_w(4) <= data_bus_w(4);
                        FIRCTL_w(5) <= data_bus_w(5);
                    when X"830" =>
                        FIRIN_w <= data_bus_w;
                    when X"838" =>
                        COEF3_0_w <= data_bus_w;
                    when X"83C" =>
                        COEF7_4_w <= data_bus_w;
                    when others => 
                        FIRCTL_w(5) <= '0';
                end case;
            end if;
            read_mem: if (mem_rd_en_w='1') then
                case addr_bus_w is
                    when X"82C" =>
                        data_bus_w <= zero_vec_w & FIRCTL_w;
                    when X"830" =>
                        data_bus_w <= FIRIN_w;
                    when X"834" =>
                        data_bus_w <= FIROUT_w;
                    when X"838" =>
                        data_bus_w <= COEF3_0_w;
                    when X"83C" =>
                        data_bus_w <= COEF7_4_w;
                    when others =>
                        null;
                end case;
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
        FIFOCLK_i   =>  fifo_clk_w,
        FIFOWEN_i  =>  FIRCTL_w(5),
        FIRCLK_i    =>  fir_clk_w,
        FIRRsT_i    =>  FIRCTL_w(1),
        FIRENA_i    =>  FIRCTL_w(0),
        FIROUT_o    =>  FIROUT_w,
        FIFOFULL_o  =>  FIRCTL_w(3),
        FIFOEMPTY_o =>  FIRCTL_w(2),
        FIRIFG_o    =>  fir_ifg_w
    );
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity neorv32_pynz2_ocd_wrapper is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY   : natural := 100000000; -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE : natural := 64*1024;   -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE : natural := 32*1024     -- size of processor-internal data memory in bytes
  );
  port (
    -- Global control --
    sysclk_i    : in  std_ulogic; -- global clock, rising edge
    rst_i       : in  std_ulogic; -- global reset, high-active, async
    -- JTAG on-chip debugger interface --
    jtag_trst_i : in  std_ulogic; -- low-active TAP reset (optional)
    jtag_tck_i  : in  std_ulogic; -- serial clock
    jtag_tdi_i  : in  std_ulogic; -- serial data input
    jtag_tdo_o  : out std_ulogic; -- serial data output
    jtag_tms_i  : in  std_ulogic; -- mode select
    -- GPIO --
    gpio_o      : out std_ulogic_vector(7 downto 0); -- parallel output
    -- UART0 --
    uart0_txd_o : out std_ulogic; -- UART0 send data
    uart0_rxd_i : in  std_ulogic  -- UART0 receive data
  );
end neorv32_pynz2_ocd_wrapper;

architecture Behavioral of neorv32_pynz2_ocd_wrapper is

  signal clk_100MHz   : std_ulogic;
  signal rstn         : std_ulogic;
  
  component neorv32_test_on_chip_debugger is
  generic (
    -- adapt these for your setup --
    CLOCK_FREQUENCY   : natural := 100000000; -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE : natural := 16*1024;   -- size of processor-internal instruction memory in bytes (16)
    MEM_INT_DMEM_SIZE : natural := 8*1024     -- size of processor-internal data memory in bytes (8)
  );
  port (
    -- Global control --
    clk_i       : in  std_ulogic; -- global clock, rising edge
    rstn_i      : in  std_ulogic; -- global reset, low-active, async
    -- JTAG on-chip debugger interface --
    jtag_trst_i : in  std_ulogic; -- low-active TAP reset (optional)
    jtag_tck_i  : in  std_ulogic; -- serial clock
    jtag_tdi_i  : in  std_ulogic; -- serial data input
    jtag_tdo_o  : out std_ulogic; -- serial data output
    jtag_tms_i  : in  std_ulogic; -- mode select
    -- GPIO --
    gpio_o      : out std_ulogic_vector(7 downto 0); -- parallel output
    -- UART0 --
    uart0_txd_o : out std_ulogic; -- UART0 send data
    uart0_rxd_i : in  std_ulogic  -- UART0 receive data
  );
  end component;
  
  component clkgen_pynqz2 is
  port (
    IO_CLK      : in  std_ulogic; 
    IO_RST_N    : in  std_ulogic; 
    clk_sys     : out  std_ulogic; 
    rst_sys_n   : out  std_ulogic 
  );
  end component;
  
begin

  neorv32_test_on_chip_debugger_inst: neorv32_test_on_chip_debugger
  generic map (
    -- General --
    CLOCK_FREQUENCY            => CLOCK_FREQUENCY,    -- clock frequency of clk_i in Hz
    MEM_INT_IMEM_SIZE          => MEM_INT_IMEM_SIZE,  -- size of processor-internal instruction memory in bytes
    MEM_INT_DMEM_SIZE          => MEM_INT_DMEM_SIZE   -- size of processor-internal data memory in bytes
  )
  port map (
    -- Global control --
    clk_i       => clk_100MHz,        -- global clock, rising edge
    rstn_i      => rstn,              -- global reset, low-active, async
    -- JTAG on-chip debugger interface (available if ON_CHIP_DEBUGGER_EN = true) --
    jtag_trst_i => '1',               -- low-active TAP reset (optional)
    jtag_tck_i  => jtag_tck_i,        -- serial clock
    jtag_tdi_i  => jtag_tdi_i,        -- serial data input
    jtag_tdo_o  => jtag_tdo_o,        -- serial data output
    jtag_tms_i  => jtag_tms_i,        -- mode select
    -- GPIO (available if IO_GPIO_NUM > 0) --
    gpio_o      => gpio_o,            -- parallel output
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o => uart0_txd_o,       -- UART0 send data
    uart0_rxd_i => uart0_rxd_i        -- UART0 receive data
  );

  -- Adapt for 100 MHz clock ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  rstn <= not(rst_i);
  
  clkgen_pynqz2_inst: clkgen_pynqz2
  port map (
    -- input clock/reset --
    IO_CLK        => sysclk_i,     
    IO_RST_N      => rstn,     
    -- output clock/reset
    clk_sys       => clk_100MHz, 			
    rst_sys_n     => open  
  );

end Behavioral;

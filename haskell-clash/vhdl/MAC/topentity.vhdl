-- Automatically generated VHDL-93
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use std.textio.all;
use work.all;
use work.mac_types.all;

entity topentity is
  port(-- clock
       clk       : in mac_types.clk_system;
       -- reset
       rst       : in mac_types.rst_system;
       en        : in boolean;
       \c$arg_0\ : in signed(63 downto 0);
       \c$arg_1\ : in signed(63 downto 0);
       result    : out signed(63 downto 0));
end;

architecture structural of topentity is
  -- MAC.hs:6:1-39
  signal acc            : signed(63 downto 0) := to_signed(0,64);
  -- MAC.hs:6:1-39
  signal x              : signed(63 downto 0);
  -- MAC.hs:6:1-39
  signal y              : signed(63 downto 0);
  signal x_0            : signed(63 downto 0);
  signal y_0            : signed(63 downto 0);
  signal x_1            : signed(63 downto 0);
  signal y_1            : signed(63 downto 0);
  signal \c$arg\        : mac_types.tup2;
  signal y_0_projection : signed(63 downto 0);

begin
  \c$arg\ <= ( tup2_sel0_signed_0 => \c$arg_0\
             , tup2_sel1_signed_1 => \c$arg_1\ );

  -- register begin 
  acc_register : process(clk,rst)
  begin
    if rst =  '1'  then
      acc <= to_signed(0,64);
    elsif rising_edge(clk) then
      if en then
        acc <= ((x_0 + y_0));
      end if;
    end if;
  end process;
  -- register end

  x <= \c$arg\.tup2_sel0_signed_0;

  y <= \c$arg\.tup2_sel1_signed_1;

  x_0 <= acc;

  y_0_projection <= (resize(x_1 * y_1,64));

  y_0 <= y_0_projection;

  x_1 <= x;

  y_1 <= y;

  result <= acc;


end;


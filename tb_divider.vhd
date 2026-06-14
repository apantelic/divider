library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_divider is
end entity;

architecture test of tb_divider is

    signal a       : std_logic_vector(15 downto 0) := (others => '0');
    signal b       : std_logic_vector(15 downto 0) := (others => '0');
    signal y_div   : std_logic_vector(15 downto 0);
    signal y_rem   : std_logic_vector(15 downto 0);
    signal y_valid : std_logic;

    signal clk   : std_logic := '0';
    signal reset : std_logic := '0';

    constant Tclk : time := 10 ns;

begin
    clk <= not clk after Tclk/2;

    dut: entity work.divider 
        port map(
            clk => clk,
            reset => reset,
            a=> a,
            b=> b,
            y_div => y_div,
            y_rem => y_rem,
            y_valid => y_valid
        );
    
    stimulus : process is
    begin
        reset <= '1';
        a <= (others => '0');
        b <= (others => '0');

        wait for 4*Tclk;

        reset <= '0';
        wait for 4*Tclk;

        a <= std_logic_vector(to_unsigned(11, a'length));
        b <= std_logic_vector(to_unsigned(3, b'length));

        wait for 25*Tclk;

        a <= std_logic_vector(to_unsigned(10, a'length));
        b <= std_logic_vector(to_unsigned(2, b'length));

        wait for 25*Tclk;

        a <= std_logic_vector(to_unsigned(15, a'length));
        b <= std_logic_vector(to_unsigned(4, b'length));

        wait for 25*Tclk;

        a <= std_logic_vector(to_unsigned(7, a'length));
        b <= std_logic_vector(to_unsigned(9, b'length));

        wait for 25*Tclk;

        a <= std_logic_vector(to_unsigned(25, a'length));
        b <= std_logic_vector(to_unsigned(25, b'length));

        wait for 25*Tclk;

        a <= std_logic_vector(to_unsigned(65535, a'length));
        b <= std_logic_vector(to_unsigned(255, b'length));

        wait for 25*Tclk;

        a <= std_logic_vector(to_unsigned(123, a'length));
        b <= std_logic_vector(to_unsigned(0, b'length));

        wait for 25*Tclk;

        wait;

    end process;

end test;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divider is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;

        a       : in  std_logic_vector(15 downto 0);
        b       : in  std_logic_vector(15 downto 0);

        y_div   : out std_logic_vector(15 downto 0);
        y_rem   : out std_logic_vector(15 downto 0);
        y_valid : out std_logic
    );
end entity divider;

architecture rtl of divider is
    type state_type is (idle, start, div);
    signal state, next_state : state_type;

    signal a_reg : std_logic_vector(15 downto 0);
    signal b_reg : std_logic_vector(15 downto 0);

    signal shift_reg : std_logic_vector(31 downto 0);

    signal cnt : natural range 0 to 15;

    signal partial_diff : std_logic_vector(15 downto 0);
    signal result_bit   : std_logic;

begin


    partial_diff_proc : process(shift_reg, b_reg)

        variable upper_after_shift : unsigned(15 downto 0);
        variable divisor           : unsigned(15 downto 0);

    begin
        upper_after_shift := unsigned(shift_reg(30 downto 15));
        divisor := unsigned(b_reg);

        if divisor = 0 then
            partial_diff <= (others => '0');
            result_bit <= '0';

        elsif upper_after_shift >= divisor then
            partial_diff <= std_logic_vector(upper_after_shift - divisor);
            result_bit <= '1';

        else
            partial_diff <= std_logic_vector(upper_after_shift);
            result_bit <='0';
        end if;

    end process;

    next_state_logic : process (a,b, state, a_reg, b_reg,cnt)
    begin
        next_state <= state;

        case state is
            when idle =>
                if (a = a_reg) and (b = b_reg) then
                    next_state <= idle;
                else
                    next_state <= start;
                end if;
            when start => 
                next_state <= div;
            when div =>
                if cnt = 15 then
                next_state <= idle;
                else
                    next_state <= div;
                end if;
        end case;

    end process;

    state_reg_proc : process(clk, reset)
    begin
        if (reset = '1') then
            state <= idle;

            a_reg <= (others => '0');
            b_reg <= (others => '0');

            shift_reg <= (others => '0');
            cnt <= 0;

            y_div <= (others => '0');
            y_rem <= (others => '0');
            y_valid <= '0';

        elsif (rising_edge(clk)) then
            state <= next_state;

            case state is 
                when idle=>
                    y_valid <= '1';

                    if (a /= a_reg) or (b /= b_reg) then
                        a_reg <= a;
                        b_reg <= b;
                        y_valid <= '0';
                    end if;

                when start =>
                    shift_reg <= (others => '0');
                    shift_reg(15 downto 0) <= a_reg;
                    cnt <= 0;
                    y_valid <= '0';

                when div =>
                    shift_reg <= partial_diff & shift_reg(14 downto 0) & result_bit;
                    if cnt = 15 then
                        y_div <= shift_reg(14 downto 0) & result_bit;
                        y_rem <= partial_diff;
                        y_valid <= '1';
                    else
                        cnt <= cnt + 1;
                        y_valid <= '0';
                    end if;
            end case;
        end if;
    end process;


end rtl;
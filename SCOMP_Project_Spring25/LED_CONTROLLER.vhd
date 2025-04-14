-- LEDController.VHD
-- 2025.03.09
--
-- This SCOMP peripheral drives ten outputs high or low based on
-- a value from SCOMP.

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE LPM.LPM_COMPONENTS.ALL;

ENTITY LED_CONTROLLER IS
PORT(
    CS          : IN  STD_LOGIC;
    WRITE_EN    : IN  STD_LOGIC;
    CLOCK       : IN  STD_LOGIC; -- 10khz = 10000 cycles per second
    RESETN      : IN  STD_LOGIC;
    LEDs        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    IO_DATA     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
);
END LED_CONTROLLER;

ARCHITECTURE a OF LED_CONTROLLER IS
    SIGNAL mode : STD_LOGIC;
    SIGNAL brightness_select : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL led_select : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL counter_uniform: natural range 0 to 199 := 0; 
    SIGNAL c1: natural range 0 to 199 := 0;
    SIGNAL c2: natural range 0 to 199 := 0; 
    SIGNAL c3: natural range 0 to 199 := 0;
    SIGNAL PULSE : STD_LOGIC := '0';
    SIGNAL count : std_logic_vector(15 DOWNTO 0) := (others => '0');
    SIGNAL leds_mode0 : STD_LOGIC_VECTOR(9 DOWNTO 0) := (others => '0');
BEGIN

-- Register logic
PROCESS(RESETN, CLOCK)
BEGIN
    IF (RESETN = '0') THEN
        mode <= '0';
        brightness_select <= (others => '0');
        led_select <= (others => '0');
    ELSIF (RISING_EDGE(CLOCK)) THEN
        IF WRITE_EN = '1' AND CS = '1' THEN
            mode <= IO_DATA(15);
            brightness_select <= IO_DATA(14 DOWNTO 10);
            led_select <= IO_DATA(9 DOWNTO 0);
        END IF;
    END IF;
END PROCESS;

-- Mode-select process with LED group assignments
PROCESS(mode, brightness_select, led_select)
    VARIABLE g1, g2, g3 : STD_LOGIC_VECTOR(9 DOWNTO 0);
BEGIN
    g1 := (others => '0');
    g2 := (others => '0');
    g3 := (others => '0');

    IF mode = '0' THEN
        c1 <= 21;
        c2 <= 89;
        c3 <= 199;

        FOR i IN 0 TO 9 LOOP
            IF led_select(i) = '1' THEN
                IF brightness_select(i MOD 5) = '1' THEN
                    g3(i) := '1';
                ELSE
                    g2(i) := '1';
                END IF;
            ELSE
                IF brightness_select(i MOD 5) = '1' THEN
                    g2(i) := '1';
                ELSE
                    g1(i) := '1';
                END IF;
            END IF;
        END LOOP;
    END IF;

    leds_mode0 <= g1 OR g2 OR g3;
END PROCESS;

-- PWM generation and LED output
PROCESS(RESETN, CLOCK)
BEGIN
    IF RESETN = '0' THEN
        count <= x"0000";
        LEDs <= (others => '0');
        PULSE <= '0';
    ELSIF rising_edge(CLOCK) THEN
        count <= std_logic_vector(unsigned(count) + 1);

        IF mode = '0' THEN
            IF count = x"00C7" THEN
                count <= x"0000";
            END IF;

            IF count < std_logic_vector(to_unsigned(c1, count'length)) THEN
                LEDs <= leds_mode0;
            ELSIF count < std_logic_vector(to_unsigned(c2, count'length)) THEN
                LEDs <= leds_mode0;
            ELSE
                LEDs <= leds_mode0;
            END IF;

        ELSIF mode = '1' THEN
			 -- Map brightness_select (0-31) to counter_uniform (0-199)
			 counter_uniform <= (to_integer(unsigned(brightness_select)) * 199) / 31;

			 -- Check if the count is less than counter_uniform, meaning the LED should be ON
			 IF to_integer(unsigned(count)) < counter_uniform THEN
				  PULSE <= '1';  -- LED is ON
			 ELSE
				  PULSE <= '0';  -- LED is OFF
			 END IF;

			 -- Increment the counter (wraps every 199 clock cycles)
			 IF to_integer(unsigned(count)) >= 199 THEN
				  count <= (others => '0');  -- Reset counter
			 ELSE
				  -- Increment the count value for the next clock cycle
				  count <= std_logic_vector(unsigned(count) + 1);
			 END IF;

			 -- Control LEDs based on PULSE
			 -- LEDs will only be ON if PULSE is '1'
			 IF PULSE = '1' THEN
				  LEDs <= led_select;  -- LEDs ON based on led_select
			 ELSE
				  LEDs <= (others => '0');  -- LEDs OFF
			 END IF;
			END IF;

    END IF;
END PROCESS;

END a;

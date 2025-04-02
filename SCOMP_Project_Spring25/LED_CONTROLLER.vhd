-- LEDController.VHD
-- 2025.03.09
--
-- This SCOMP peripheral drives ten outputs high or low based on
-- a value from SCOMP.

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
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

ARCHITECTURE a OF LED_CONTROLLER IS --added by henry
    SIGNAL mode : STD_LOGIC;
    SIGNAL brightness_select : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL led_select : STD_LOGIC_VECTOR(9 DOWNTO 0);
	 SIGNAL counter_uniform: natural range 0 to 199 := 0; 
	 SIGNAL PULSE : STD_LOGIC;
	 signal count   : std_logic_vector(15 downto 0);  -- internal counter


BEGIN
    PROCESS (RESETN, CS, CLOCK)
    BEGIN
        IF (RESETN = '0') THEN
            -- Turn off LEDs at reset (a nice usability feature)
            LEDs <= "0000000000";
				count <= x"0000";
				mode <= '0';
				brightness_select <= (others => '0');
				led_select <= (others => '0');
        ELSIF (RISING_EDGE(CLOCK)) THEN
            IF WRITE_EN = '1' and CS = '1' THEN
                -- If SCOMP is sending data to this peripheral,
                -- use that data directly to determine the modes,
                     --brightness and led selection.
                     
					 mode <= IO_DATA(15); --added by henry 
                brightness_select <= IO_DATA(14 DOWNTO 10);
                led_select <= IO_DATA(9 DOWNTO 0);
            end if;    
					 
				IF mode = '0' THEN
					--code here for pairing mode
						
						

				ELSIF mode = '1' THEN
					--code here for uniform mode
					IF brightness_select(0) = '1' then
						counter_uniform <= 199;
					ELSIF (brightness_select & "00010") = "00010" then
						counter_uniform <= 127;
					ELSIF (brightness_select & "00100") = "00100" then
						counter_uniform <= 71;
					ELSIF (brightness_select & "01000") = "01000" then
						counter_uniform <= 31;
					ELSIF (brightness_select & "10000") = "10000" then
						counter_uniform <= 7;
					ELSE
						counter_uniform <= 0;
					END IF;
						
					-- Each clock cycle, a counter is incremented.
					count <= count + 1;
					-- When the counter reaches the full desired period, start the period over.
					if count = x"00C7" then  -- 20 ms has elapsed
						-- Reset the counter and set the output high.
						count <= x"0000";
						PULSE <= '1';

					-- Within the period, when the counter reaches the "command" value, set the output low.
					-- This will make larger command values produce longer pulses.
					elsif count = counter_uniform then
						PULSE <= '0';
					ELSE
						PULSE <= '1';
					end if;
						
					if PULSE = '1' THEN 
						LEDs <= led_select;
					else 
						LEDs <= (others => '0');
					end if;
            end if;
        end if;
    END PROCESS;
		  


END a;
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
	 SIGNAL led_g1 : STD_LOGIC_VECTOR(9 DOWNTO 0); -- leds grouped by 33% brightness
	 SIGNAL led_g2 : STD_LOGIC_VECTOR(9 DOWNTO 0); -- leds grouped by 67% brightness
	 SIGNAL led_g3 : STD_LOGIC_VECTOR(9 DOWNTO 0); -- leds grouped by full brightness
	 SIGNAL counter_uniform: natural range 0 to 199 := 0; 
	 SIGNAL c1: natural range 0 to 199 := 0; -- for mode 0
	 SIGNAL c2: natural range 0 to 199 := 0; 
	 SIGNAL c3: natural range 0 to 199 := 0; -- 
	 SIGNAL PULSE : STD_LOGIC;
	 signal count   : std_logic_vector(15 downto 0);  -- internal counter


BEGIN
    PROCESS (RESETN, CS, CLOCK)
	 -- POTENTIAL ISSUE "YOU CAN'T SET AND USE A VALUE AT THE SAME TIME"!!!
    BEGIN
        IF (RESETN = '0') THEN
            -- Turn off LEDs at reset (a nice usability feature)
            LEDs <= "0000000000";
				count <= x"0000";
				mode <= '0';
				brightness_select <= (others => '0');
				led_select <= (others => '0');
				led_g1 <= (others => '0');
				led_g2 <= (others => '0');
				led_g3 <= (others => '0');
        ELSIF (RISING_EDGE(CLOCK)) THEN
            IF WRITE_EN = '1' and CS = '1' THEN -- if1
                -- If SCOMP is sending data to this peripheral,
                -- use that data directly to determine the modes,
                     --brightness and led selection.
                     
					 mode <= IO_DATA(15); --added by henry 
                brightness_select <= IO_DATA(14 DOWNTO 10);
                led_select <= IO_DATA(9 DOWNTO 0);
            end if; -- endif1
					 
				IF mode = '0' THEN -- if2
					--code here for pairing mode
					c1 <= 21; --  33% brightness, g1 brightness
					c2 <= 89; --  67% brightness, g2 brightness
					c3 <= 199; -- full brightness, g3 brightness
					if brightness_select(4) = '1' then -- if3
						if led_select(9) = '1' then  -- if4
							led_g3(9) <= '1';
							led_g2(9) <= '0';
							led_g1(9) <= '0';
						else 
							led_g3(9) <= '0';
							led_g2(9) <= '1';
							led_g1(9) <= '0';
						end if; -- endif4
						if led_select(8) = '1' then -- if5
							led_g3(8) <= '1';
							led_g2(8) <= '0';
							led_g1(8) <= '0';
						else
							led_g3(8) <= '0';
							led_g2(8) <= '1';
							led_g1(8) <= '0';
						end if; -- endif5
					else 
						if led_select(9) = '1' then -- if6
							led_g3(9) <= '0';
							led_g2(9) <= '0';
							led_g1(9) <= '1';
						else
							led_g3(9) <= '0';
							led_g2(9) <= '0';
							led_g1(9) <= '0';
						end if; -- endif6
						if led_select(8) = '1' then -- if7
							led_g3(8) <= '0';
							led_g2(8) <= '0';
							led_g1(8) <= '1';
						else
							led_g3(8) <= '0';
							led_g2(8) <= '0';
							led_g1(8) <= '0';
						end if; -- endif7
					end if;
					
					if brightness_select(3) = '1' then -- if8
						if led_select(7) = '1' then -- if9
							  led_g3(7) <= '1';
							  led_g2(7) <= '0';
							  led_g1(7) <= '0';
						 else 
							  led_g3(7) <= '0';
							  led_g2(7) <= '1';
							  led_g1(7) <= '0';
						 end if;
						 if led_select(6) = '1' then
							  led_g3(6) <= '1';
							  led_g2(6) <= '0';
							  led_g1(6) <= '0';
						 else
							  led_g3(6) <= '0';
							  led_g2(6) <= '1';
							  led_g3(6) <= '0';
						 end if;
					else
						if led_select(7) = '1' then
							led_g3(7) <= '0';
							led_g2(7) <= '0';
							led_g1(7) <= '1';
						else
							led_g3(7) <= '0';
							led_g2(7) <= '0';
							led_g1(7) <= '0';
						end if;
						if led_select(6) = '1' then
							led_g3(6) <= '0';
							led_g2(6) <= '0';
							led_g1(6) <= '1';
						else
							led_g3(6) <= '0';
							led_g2(6) <= '0';
							led_g1(6) <= '0';
						end if;
					end if;

					if brightness_select(2) = '1' then
						if led_select(5) = '1' then
							led_g3(5) <= '1';
							led_g2(5) <= '0';
							led_g1(5) <= '0';
						else 
							led_g3(5) <= '0';
							led_g2(5) <= '1';
							led_g1(5) <= '0';
						end if;
						if led_select(4) = '1' then
							led_g3(4) <= '1';
							led_g2(4) <= '0';
							led_g1(4) <= '0';
						else 
							led_g3(4) <= '0';
							led_g2(4) <= '1';
							led_g1(4) <= '0';
						end if;
					else 
						if led_select(5) = '1' then
							led_g3(5) <= '0';
							led_g2(5) <= '0';
							led_g1(5) <= '1';
						else
							led_g3(5) <= '0';
							led_g2(5) <= '0';
							led_g1(5) <= '0';
						end if;
						if led_select(4) = '1' then
							led_g3(4) <= '0';
							led_g2(4) <= '0';
							led_g1(4) <= '1';
						else
							led_g3(4) <= '0';
							led_g2(4) <= '0';
							led_g1(4) <= '0';
						end if;
					end if;

					if brightness_select(1) = '1' then
						if led_select(3) = '1' then
							led_g3(3) <= '1';
							led_g2(3) <= '0';
							led_g1(3) <= '0';
						else 
							led_g3(3) <= '0';
							led_g2(3) <= '1';
							led_g1(3) <= '0';
						end if;
						if led_select(2) = '1' then
							led_g3(2) <= '1';
							led_g2(2) <= '0';
							led_g1(2) <= '0';
						else 
							led_g3(2) <= '0';
							led_g2(2) <= '1';
							led_g1(2) <= '0';
						end if;
					else 
						if led_select(3) = '1' then
							led_g3(3) <= '0';
							led_g2(3) <= '0';
							led_g1(3) <= '1';
						else
							led_g3(3) <= '0';
							led_g2(3) <= '0';
							led_g1(3) <= '0';
						end if;
						if led_select(2) = '1' then
							led_g3(2) <= '0';
							led_g2(2) <= '0';
							led_g1(2) <= '1';
						else
							led_g3(2) <= '0';
							led_g2(2) <= '0';
							led_g1(2) <= '0';
						end if;
					end if;

					if brightness_select(0) = '1' then
						if led_select(1) = '1' then
							led_g3(1) <= '1';
							led_g2(1) <= '0';
							led_g1(1) <= '0';
						else 
							led_g3(1) <= '0';
							led_g2(1) <= '1';
							led_g1(1) <= '0';
						end if;
						if led_select(0) = '1' then
							led_g3(0) <= '1';
							led_g2(0) <= '0';
							led_g1(0) <= '0';
						else 
							led_g3(0) <= '0';
							led_g2(0) <= '1';
							led_g1(0) <= '0';
						end if;
					else 
						if led_select(1) = '1' then
							led_g3(1) <= '0';
							led_g2(1) <= '0';
							led_g1(1) <= '1';
						else
							led_g3(1) <= '0';
							led_g2(1) <= '0';
							led_g1(1) <= '0';
						end if;
						if led_select(0) = '1' then
							led_g3(0) <= '0';
							led_g2(0) <= '0';
							led_g1(0) <= '1';
						else
							led_g3(0) <= '0';
							led_g2(0) <= '0';
							led_g1(0) <= '0';
						end if;
					end if;
					
					
					-- Each clock cycle, a counter is incremented.
					count <= count + 1;	
					if count = x"00C7" then  -- 20 ms has elapsed
						-- Reset the counter and set the output high.
						count <= x"0000";
					end if;
					if count < c1 then
						LEDs <= led_g1 or led_g2 or led_g3;
					elsif count < c2 then
						LEDs <= led_g2 or led_g3;
					else
						LEDs <= led_g3;
					end if;

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
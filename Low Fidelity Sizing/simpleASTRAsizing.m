TWR = 1.7/1.6; % TWR, currently set to gyruruereee's for testing purposes
g = 9.8; % gravity
mass_factor = 3.5; 

data_file = readtable("Matlab Simple Sizing.csv");

thrust = data_file.Thrust_g_; % Thrust in g
mass_fan = data_file.Mass_g__2; % mass of fan in kg
mass_battery = data_file.Mass_g_; % mass of battery in kg
fan_amps = data_file.Amps; % Current of motors in amps
battery_Ah = data_file.Ah; % Capacity of batteries in Ah



for battery_looping = 1:length(mass_battery) % battery
    for fan_looping = 1:length(mass_fan) % fan/propeller/edf
        elimination(battery_looping,fan_looping) = (thrust(fan_looping) / TWR) - mass_fan(fan_looping) - mass_battery(battery_looping);
        if elimination(battery_looping,fan_looping) <= ((mass_fan(fan_looping)+mass_battery(battery_looping))*3.5-mass_fan(fan_looping)-mass_battery(battery_looping))
            elimination(battery_looping,fan_looping) = 0;
        end
    end
end

flight_time_elimination = elimination;
for battery_looping = 1:length(mass_battery) % battery
    for fan_looping = 1:length(mass_fan) % fan/propeller/edf
    flight_time_elimination(battery_looping,fan_looping) = ((battery_Ah(battery_looping)/fan_amps(fan_looping))*3600)*0.8;
        if flight_time_elimination(battery_looping,fan_looping) < 90
            flight_time_elimination(battery_looping,fan_looping) = 0;
        end
    end
end
 
elimination;
flight_time_elimination;
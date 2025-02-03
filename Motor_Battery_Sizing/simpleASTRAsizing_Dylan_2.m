clear
close all

% Load Specs
data_file = readtable("Matlab Simple Sizing2.csv");

% Battery Values
batt_vals = data_file(:,{'Ah','Mass_g_','Voltage'});
batt_vals = batt_vals{:,:};

% Propeller Values
propeller_vals = data_file(:,{'Mass_g__1','Amps','Thrust_g_','Voltage_1'});
propeller_vals = propeller_vals{:,:};

% Single EDF Values
single_edf_vals = data_file(:,{'Mass_g__3','Amps_2','Thrust_g__2','Voltage_3'});
single_edf_vals = single_edf_vals{:,:};

% Dual EDF Values
dual_edf_vals = data_file(:,{'Mass_g__2','Amps_1','Thrust_g__1','Voltage_2'});
dual_edf_vals = dual_edf_vals{:,:};

% Run Visualizer
calcVals(propeller_vals,batt_vals,'Propeller')
calcVals(single_edf_vals,batt_vals,'Single EDF')
calcVals(dual_edf_vals,batt_vals,'Dual EDF')

function calcVals(propulsion,batt,Prop_name_type)
    % Settings
    twr_target = 1.7/1.6; % TWR, currently set to gyruruereee's for testing purposes
    batt_margin = 0.2; % Percentage battery charge to leave in reserve

    % Propulsion Device    
    prop_mass = propulsion(:,1); % Motor Mass in kg
    prop_amps = propulsion(:,2); % Motor Current in amps
    prop_thrust = propulsion(:,3); % Motor Thrust in g
    prop_volt = propulsion(:,4); % Motor Voltage in V
    prop_count = length(prop_mass(~isnan(prop_mass)));

    % Batteries
    batt_Ah = batt(:,1); % Capacity of batteries in Ah
    mass_battery = batt(:,2); % mass of battery in kg
    batt_volt = batt(:,3); % Battery Voltages in V
    batt_count = length(batt_Ah);
    
    twr_vals = zeros(prop_count,batt_count);
    flt_time_vals = zeros(prop_count,batt_count);
    payload_vals = zeros(prop_count,batt_count);
    score = zeros(prop_count,batt_count);
    score2 = zeros(prop_count,batt_count);
    
    for fan_num = 1:prop_count
        for batt_num = 1:batt_count

            % Calculate Values
            twr = prop_thrust(fan_num)/(prop_mass(fan_num)+mass_battery(batt_num)); % Calculate Propuslion Stack TWR
            flt_time = batt_Ah(batt_num)*(1-batt_margin)*3600/prop_amps(fan_num); % Calculate flight time assuming max draw with 20% reserve
            payload = (prop_thrust(fan_num)/twr_target)-(prop_mass(fan_num)+mass_battery(batt_num)); % Calculate Paload Capacity using target twr
            voltage_diff = batt_volt(batt_num)-prop_volt(fan_num); % Difference between Battery and Motor Voltage
            
            if((3>=voltage_diff) && (voltage_diff>=0) && flt_time >= 90)
                
                % Update Arrays
                twr_vals(fan_num,batt_num) = twr;
                flt_time_vals(fan_num,batt_num) = flt_time;
                payload_vals(fan_num,batt_num) = (prop_thrust(fan_num)/twr_target)-(prop_mass(fan_num)+mass_battery(batt_num));
                score(fan_num,batt_num) = twr*flt_time;
                score2(fan_num,batt_num) = payload*flt_time;
            
            end
            
        end
    end

    figure('Name',Prop_name_type,'NumberTitle','off')
    % subplot(2,3,1)
    % surf(score)
    % xlabel("batt")
    % ylabel("fan")
    % zlabel("twr * flt time")
    % 
    % subplot(2,3,2)
    % surf(score2)
    % xlabel("batt")
    % ylabel("fan")
    % zlabel("payload capacity * flt time")
    
    subplot(1,3,1)
    surf(twr_vals)
    xlabel("batt")
    ylabel("fan")
    zlabel("prop stack twr")

    subplot(1,3,2)
    surf(payload_vals)
    xlabel("batt")
    ylabel("fan")
    zlabel("payload capacity (g)")

    subplot(1,3,3)
    surf(flt_time_vals)
    xlabel("batt")
    ylabel("fan")
    zlabel("flt time (s)")
    
end

function A = clearZeros(A)
    A( ~any(A,2), : ) = [];  %rows
    A( :, ~any(A,1) ) = [];  %columns
end
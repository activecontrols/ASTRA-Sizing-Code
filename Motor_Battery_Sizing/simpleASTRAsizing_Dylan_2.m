clear
close all

twr_target = 1.7/1.6; % TWR, currently set to gyruruereee's for testing purposes
g = 9.8; % gravity

mass_structure = 3.5;
batt_margin = 0.2;

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


%calcVals(propeller_vals,batt_vals)
calcVals(single_edf_vals,batt_vals)




function calcVals(propulsion,batt)
    % Settings
    twr_target = 1.7/1.6;
    batt_margin = 0.2;

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
    
    twr_vals = zeros(prop_count,length(batt_Ah));
    flt_time_vals = zeros(prop_count,length(batt_Ah));
    payload_vals = zeros(prop_count,length(batt_Ah));
    score = zeros(prop_count,length(batt_Ah));
    score2 = zeros(prop_count,length(batt_Ah));
    
    for fan_num = 1:prop_count
        for batt_num = 1:length(batt_Ah)
            if((3>=batt_volt(batt_num)-prop_volt(fan_num)) && (batt_volt(batt_num)-prop_volt(fan_num)>=0))
                % Calculate Values
                twr = prop_thrust(fan_num)/(prop_mass(fan_num)+mass_battery(batt_num)); % Calculate Propuslion Stack TWR
                flt_time = batt_Ah(batt_num)*(1-batt_margin)*1200/prop_amps(fan_num); % Calculate flight time assuming max draw with 20% reserve
                payload = (prop_thrust(fan_num)/twr_target)-(prop_mass(fan_num)+mass_battery(batt_num)); % Calculate Paload Capacity using target twr
                
                % Update Arrays
                twr_vals(fan_num,batt_num) = twr;
                flt_time_vals(fan_num,batt_num) = flt_time;
                payload_vals(fan_num,batt_num) = (prop_thrust(fan_num)/twr_target)-(prop_mass(fan_num)+mass_battery(batt_num));
                score(fan_num,batt_num) = twr*flt_time;
                score2(fan_num,batt_num) = payload*flt_time;
            
            end
        end
    end
    
    score = clearZeros(score);

    %figure()
    subplot(2,3,1)
    surf(score)
    xlabel("batt")
    ylabel("fan")
    zlabel("twr * flt time")
    
    score2 = clearZeros(score2);

    %figure()
    subplot(2,3,2)
    surf(score2)
    xlabel("batt")
    ylabel("fan")
    zlabel("payload capacity * flt time")
    
    twr_vals = clearZeros(twr_vals);

    %figure()
    subplot(2,3,3)
    surf(twr_vals)
    xlabel("batt")
    ylabel("fan")
    zlabel("prop stack twr")
    
    payload_vals = clearZeros(payload_vals);

    %figure()
    subplot(2,3,4)
    surf(payload_vals)
    xlabel("batt")
    ylabel("fan")
    zlabel("payload capacity (g)")
    
    flt_time_vals = clearZeros(flt_time_vals);

    %figure()
    subplot(2,3,5)
    surf(flt_time_vals)
    xlabel("batt")
    ylabel("fan")
    zlabel("flt time (s)")
    
end

function A = clearZeros(A)
    A( ~any(A,2), : ) = [];  %rows
    A( :, ~any(A,1) ) = [];  %columns
end
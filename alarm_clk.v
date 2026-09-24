`timescale 1ns / 1ps
module alarm_clk (
    clk, reset, shutdown, reset_minute, reset_hour, alarm_minute, alarm_hour,
    second, minute, hour, alarm_flag
);

// Inputs
input clk, reset, shutdown;               // system clock, reset, shutdown button
input [5:0] reset_minute;                 // Reset minute input (0-59)
input [4:0] reset_hour;                   // Reset hour input (0-23)
input [5:0] alarm_minute;                 // Alarm minute input (0-59)
input [4:0] alarm_hour;                   // Alarm hour input (0-23)

// Outputs
output [5:0] second, minute;              // Seconds and minutes output (0-59)
output [4:0] hour;                        // Hours output (0-23)
output reg alarm_flag;                    // Alarm flag (1 when alarm active)

// Internal Registers
reg [5:0] sec_counter;                    // Seconds counter
reg [5:0] min_counter;                    // Minutes counter
reg [4:0] hr_counter;                     // Hours counter
reg [5:0] prev_minute;                    // Store previous minute to detect changes
reg alarm_active;                         // Flag to track if alarm is currently active

// 1. Timekeeping
// This module increments the time (seconds, minutes, hours) based on the clock.
always @(posedge clk or posedge reset) begin
    if (reset) begin
        sec_counter <= 0;
        min_counter <= reset_minute;
        hr_counter <= reset_hour;
        alarm_flag <= 0;                  // Reset alarm flag on reset
        prev_minute <= reset_minute;      // Store initial minute
        alarm_active <= 0;                // Reset alarm active flag
    end else begin
        // Increment seconds
        if (sec_counter == 59) begin
            sec_counter <= 0;
            // Increment minutes when seconds overflow
            if (min_counter == 59) begin
                min_counter <= 0;
                // Increment hours when minutes overflow
                if (hr_counter == 23)
                    hr_counter <= 0;
                else
                    hr_counter <= hr_counter + 1;
            end else begin
                min_counter <= min_counter + 1;
            end
        end else begin
            sec_counter <= sec_counter + 1;
        end
    end
end

// 2. Alarm Logic
// This module handles alarm flag, setting it when the time matches the alarm.
always @(posedge clk or posedge reset) begin
    if (reset) begin
        alarm_flag <= 0;                  // Reset alarm flag on reset
        alarm_active <= 0;                // Reset active alarm flag
    end else begin
        // Shutdown Check
        // Only reset alarm if it's active and shutdown is triggered
        if (shutdown && alarm_active) begin
            alarm_flag <= 0;              // Deactivate the currently active alarm
            alarm_active <= 0;            // Mark alarm as inactive
        end else begin
            // Alarm Time Match
            if (hour == alarm_hour && minute == alarm_minute && !alarm_active) begin
                alarm_flag <= 1;          // Set alarm flag when the time matches
                alarm_active <= 1;        // Mark alarm as active
            end
            // Deactivate Alarm if Time Changes
            else if (hour != alarm_hour || minute != alarm_minute) begin
                alarm_flag <= 0;          // Reset alarm flag when time no longer matches
                alarm_active <= 0;        // Mark alarm as inactive
            end
        end
    end
end

// 3. Output Assignments
// This section assigns the current time to the outputs: second, minute, and hour.
assign second = sec_counter;
assign minute = min_counter;
assign hour = hr_counter;

endmodule

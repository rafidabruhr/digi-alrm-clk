`timescale 1ns / 1ps
module tb_alarm_clk;

// Inputs
reg clk;
reg reset;
reg shutdown;
reg [5:0] reset_minute;
reg [4:0] reset_hour;
reg [5:0] alarm_minute;
reg [4:0] alarm_hour;

// Outputs
wire [5:0] second;
wire [5:0] minute;
wire [4:0] hour;
wire alarm_flag;

// Instantiate AlarmClock
alarm_clk uut (
    .clk(clk),
    .reset(reset),
    .shutdown(shutdown),
    .reset_minute(reset_minute),
    .reset_hour(reset_hour),
    .alarm_minute(alarm_minute),
    .alarm_hour(alarm_hour),
    .second(second),
    .minute(minute),
    .hour(hour),
    .alarm_flag(alarm_flag)
);

// Clock Generation
initial clk = 0;
always #5 clk = ~clk; // 100 MHz clock

// Simulation
initial begin
    // Enable waveform dumping for GTKWave
    $dumpfile("alarm_clk.vcd");
    $dumpvars(0, tb_alarm_clk);

    // Initialize inputs
    reset = 1;
    shutdown = 0;
    reset_hour = 1;
    reset_minute = 20;
    alarm_hour = 0;
    alarm_minute = 0;

    // Release reset
    #10;
    reset = 0;

    // Alarm 1 at 02:00
    alarm_hour = 2;
    alarm_minute = 0;
    wait (hour == 2 && minute == 0);
    $display("Time = %0d:%0d:%0d -> Alarm 1 ON: %b", hour, minute, second, alarm_flag);

    // Shutdown at 02:00:30
    wait(second == 30);
    shutdown = 1;
    #10;
    shutdown = 0;
    $display("Shutdown at Time = %0d:%0d:%0d -> Alarm 1 OFF: %b", hour, minute, second, alarm_flag);

    // Alarm 2 at 03:15
    alarm_hour = 3;
    alarm_minute = 15;
    wait(hour == 3 && minute == 15);
    $display("Time = %0d:%0d:%0d -> Alarm 2 ON: %b", hour, minute, second, alarm_flag);

    // Wait until 03:16 (alarm deactivates automatically)
    wait (minute == 16);
    $display("Time = %0d:%0d:%0d -> Alarm 2 OFF: %b", hour, minute, second, alarm_flag);

    #6000;
    $finish;
end

endmodule

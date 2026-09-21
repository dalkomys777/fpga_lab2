`timescale 1ns/1ps

module tb_shift_register4;

reg clk=0, rst=1;
integer checks=0;

always #5 clk=~clk;

task step;
begin
    @(posedge clk);
    #1;
end
endtask

task check(input condition, input [8*100-1:0] description);
begin
    checks=checks+1;
    if (condition !== 1'b1) begin
        $display("LAB2_FAIL %0s time=%0t",description,$time);
        $fatal(1,"check failed");
    end
end
endtask

task finish;
begin
    $display("LAB2_PASS shift_register4 checks=%0d",checks);
    $finish;
end
endtask

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,tb_shift_register4);
end

initial begin
    #1000000;
    $fatal(1,"watchdog timeout");
end

reg enable=0, serial_in=0;
wire [3:0] value;

shift_register4 dut(clk,rst,enable,serial_in,value);

initial begin
    step;
    check(value===4'h0,"reset");
    rst=0;

    enable=1;
    serial_in=1;
    step;
    check(value===4'h8,"shift 1");

    serial_in=0;
    step;
    check(value===4'h4,"shift 0");

    enable=0;
    serial_in=1;
    step;
    check(value===4'h4,"hold");

    enable=1;
    step;
    check(value===4'hA,"shift 1 after hold");

    serial_in=0;
    step;
    check(value===4'h5,"shift 0");

    repeat(4) step;
    check(value===4'h0,"four more zeros");

    rst=1;
    serial_in=1;
    step;
    check(value===4'h0,"reset priority");

    finish;
end

endmodule

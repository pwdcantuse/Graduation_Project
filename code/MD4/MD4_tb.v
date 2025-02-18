`timescale 1ns/1ps
`define CYCLE  7.2
`define SDFFILE   "./MD4_syn.sdf" 
module test;
     `ifdef SDF
       initial $sdf_annotate(`SDFFILE, UUT);
    `endif
    //reg
    reg clk;
    reg reset;
    reg [511:0] message;

    //wire
    wire [127:0] hash;
    wire done;

    //test
    //wire [31:0] A,B,C,D,E;
    //wire [5:0] t;
    //wire [31:0] wt,wt2;
    //wire [3:0] t2,t21;

    //SHA1 UUT(.clk(clk),.reset(reset),.message(message),.hash(hash),.done(done),.A(A),.B(B),.C(C),.D(D),.E(E),.t(t),.wt(wt),.wt2(wt2),.t2(t2),.t21(t21));
    MD4 UUT(.clk(clk),.reset(reset),.message(message),.hash(hash),.done(done));

    //monitor
    //initial $monitor("t=%d, A=%h, B=%h, C=%h, D=%h, E=%h,",t,A,B,C,D,E);
    //initial $monitor("w%d : %h , w%d : %h",t2,wt,t21,wt2);

    //clock generator
    always #(`CYCLE/2) clk = ~clk;

    initial begin
        clk = 1; 
        reset = 1; 
        message = 512'h64636261686766656c6b6a69706f6e6d747372717877767500807a7900000000000000000000000000000000000000000000000000000000000000d000000000;
    #(`CYCLE/2) reset = 0;

        wait(done);
   #(`CYCLE/2) $display("hash : %h",hash);
        $finish;

    end

    initial begin

       $fsdbDumpfile("SHA1.fsdb");
       $fsdbDumpvars;
       $fsdbDumpMDA;
    end

endmodule

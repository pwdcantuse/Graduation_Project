`timescale 1ns/10ps
`define CYCLE      6
`define SDFFILE   "./SHA1_syn.sdf"  
module test;

    //reg
    reg clk;
    reg reset;
    reg [511:0] message;

    //wire
    wire [159:0] hash;
    wire done;
    wire [31:0] A,B,C,D,E;
    wire [5:0] t;
    wire [31:0] wt,wt2;
    wire [3:0] t2,t21;

    SHA1 UUT(.clk(clk),.reset(reset),.message(message),.hash(hash),.done(done));

    //monitor
    //initial $monitor("t=%d, A=%h, B=%h, C=%h, D=%h, E=%h,",t,A,B,C,D,E);
    //initial $monitor("w%d : %h , w%d : %h",t2,wt,t21,wt2);

    //clock generator
    always #(`CYCLE/2) clk = ~clk;

    initial begin
        clk = 1; 
        reset = 1;
        //message = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
        message = 512'h6162636465666768696a6b6c6d6e6f707172737475767778797a80000000000000000000000000000000000000000000000000000000000000000000000000d0;
           #(`CYCLE/2) reset = 0;
        wait(done);
      #(`CYCLE/2) $display("hash : %h",hash);
        $finish;

    end
    `ifdef SDF
       initial $sdf_annotate(`SDFFILE, UUT);
    `endif

endmodule

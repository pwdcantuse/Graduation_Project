`timescale 1ns/1ps


`define CYCLE  6.50    
`define SDFFILE   "./SHA2_syn.sdf" 
module test;

    //reg
    reg clk;
    reg reset;
    reg [511:0] message;

    //wire
    wire [255:0] hash,ooo;
    wire done;
  //  wire [31:0] A,B,C,D,E,F,G,H;
    wire [5:0] t;
    wire [31:0] w;
    reg [31:0] k [0:63];
    reg [31:0] A,B,C,D,E,F,G,H;
    wire [1:0] State;
    reg [2:0] cc;
    //wire [3:0] t2,t21;
    initial begin
      $readmemh("k.mem",k);
    end
     `ifdef SDF
       initial $sdf_annotate(`SDFFILE, UUT);
    `endif
    assign ooo={32'h6a09e667+A,32'hbb67ae85+B,32'h3c6ef372+C,32'ha54ff53a+D,32'h510e527f+E,32'h9b05688c+F,32'h1f83d9ab+G,32'h5be0cd19+H};
    //SHA1 UUT(.clk(clk),.reset(reset),.message(message),.hash(hash),.done(done),.A(A),.B(B),.C(C),.D(D),.E(E),.t(t),.wt(wt),.wt2(wt2),.t2(t2),.t21(t21));
    SHA2 UUT(clk, reset, hash, done,t,k[t],message);
    //monitor
   // initial $monitor("t=%d, A=%h, B=%h, C=%h, D=%h, E=%h,",t,A,B,C,D,E);
    //initial $monitor("w%d : %h , w%d : %h",t2,wt,t21,wt2);

    //clock generator
    always #(`CYCLE/2) clk = ~clk;
    always@(posedge clk) begin
      if(done) cc = cc+3'd1;
      else cc = 3'd0;
    end
    always@(posedge clk) begin
      if(done) begin
        if(cc == 3'd1) H <= hash[31:0] ;
        if(cc == 3'd2) begin
           G <= hash[63:32];
           D <= hash[159:128];
        end
        if(cc == 3'd3) begin
           F <= hash[95:64];
           E <= hash[127:96];
           C <= hash[191:160];
        end
        if(cc == 3'd4) begin
           B <= hash[223:192];
           A <= hash[255:224];
        end
      end
    end
    initial begin
        clk = 0; 
        reset = 1;
        //message = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
        message = 512'h6162636465666768696a6b6c6d6e6f707172737475767778797a80000000000000000000000000000000000000000000000000000000000000000000000000d0;
    #(`CYCLE/2) reset = 0;

        wait(cc == 3'd5);
        $display("hash : %h",ooo);
        $finish;

    end

 /*   initial begin

       $fsdbDumpfile("SHA2.fsdb");
       $fsdbDumpvars;
       $fsdbDumpMDA;
    end*/
endmodule

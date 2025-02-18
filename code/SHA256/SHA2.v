`define RESET 2'd0
`define CAL 2'd1
`define DONE 2'd2

module SHA2(clk, reset, hash, done,t,k,message);
  input clk;
  input reset;
  input [31:0] k;
  input [511:0] message;
  output [255:0] hash;
  output done;
  

  output [5:0] t;

  reg [31:0] w [0:15];
  reg [31:0] A,B,T1,T2,T3,T4,T5,T6,E,F;
  reg [5:0] t;
  reg [1:0] State;

  wire [31:0] C,D,G,H,tempT1,tempT3,tempT4,wire1,wire2,wire3,wire4,wire5,wire6,wire7,wire8,wire9,wire10,wire11,wire12;
  wire [31:0] tempA,tempB,tempE,tempF;
  wire [1:0] nextState;
  wire [3:0] t14,t9,t1,t0; 
  ///////// wire ////////////
  assign tempT1 = wire1+wire2;
  assign tempT3 = D+T1;
  assign wire3 = (E&F)|((~E)&T6);
  assign wire4 = {E[5:0],E[31:6]}^{E[10:0],E[31:11]}^{E[24:0],E[31:25]};
  assign tempE = (t==6'd1)?32'h510e527f :wire7+wire8;
  assign wire9={A[1:0],A[31:2]}^{A[12:0],A[31:13]}^{A[21:0],A[31:22]};
  assign wire10 = (A&B)^(A&T5)^(B&T5);
  assign tempA = (t==6'd0)? 32'h3c6ef372:(t==6'd2)? 32'h6a09e667 :wire11+wire12;
  assign tempT4 = wire5+wire6;
  assign C=B;
  assign D=C;
  assign H=G;
  assign G=F;
  assign tempB = (t==6'd2)? 32'hbb67ae85: A;
  assign tempF = (t==6'd1)? 32'h9b05688c: E;
  assign hash = {A,B,C,D,E,F,G,H};
  //////////////////////////

  always@(posedge clk or posedge reset) begin
    if(reset) State <= `RESET;
    else State <= nextState;
  end
  assign done = (State==`DONE)?1'b1:1'b0;
  assign nextState = (&t)? `DONE : `CAL ;
  always@(posedge clk or posedge reset) begin
   if(reset) t <= 6'd0;
   else begin
    if(State == `CAL||State == `DONE) begin
      if(!(&t)) t <= t+6'd1;
     end
    else t<= 6'd0;
   end
  end
  always@(posedge clk or posedge reset) begin
    if(reset) begin
      A <= 32'ha54ff53a; //ini D 
      B <= 32'd0; // unknown
      T6 <= 32'd0;
      T5 <= 32'd0;
      T4 <= 32'd0;
      T3 <= 32'd0;
      T2 <= 32'd0;
      T1 <= 32'd0;
      E <= 32'h1f83d9ab;
      F <= 32'h5be0cd19;
    end
    else if(State != `RESET) begin
      A <= tempA;
      B <= tempB;
      T6 <= G;
      T5 <= C;
      T4 <= tempT4;
      T3 <= tempT3;
      T2 <= T1;
      T1 <= tempT1;
      E <= tempE;
      F <= tempF;
    end
  end

   assign t14 = t[3:0] + 4'd14;
   assign t9 = t[3:0] + 4'd9;
   assign t0 = t[3:0];
   assign t1 = t0+4'd1;
   always@(posedge clk or posedge reset) begin
      if(reset) {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= message;
      else if(State!=`RESET)begin
         w[t0] <= ({w[t14][16:0],w[t14][31:17]}^{w[t14][18:0],w[t14][31:19]}^{10'd0,w[t14][31:10]})+w[t9]+({w[t1][6:0],w[t1][31:7]}^{w[t1][17:0],w[t1][31:18]}^{3'd0,w[t1][31:3]})+w[t0] ;
      end
   end




  CSA csa1(H,w[t0],k,wire1,wire2);
  CSA csa2(T2,wire3,wire4,wire5,wire6);
  CSA csa3(T3,wire3,wire4,wire7,wire8);
  CSA csa4(wire9,wire10,T4,wire11,wire12);
endmodule

module CSA(a,b,ci,s,co);
  input [31:0] a,b,ci;
  output [31:0] s,co;

  assign s=(a^b)^ci;
  assign co={(a^b^ci)^(a|b|ci)^(a&b&ci),1'b0};

endmodule











`define RESET 3'd0
`define R0 3'd1
`define R1 3'd2
`define R2 3'd3
`define R3 3'd4
`define DONE 3'd5

module SHA1(clk, reset, message, hash, done);
  input clk;
  input reset;
  input [511:0] message;
  output [159:0] hash;
  output done;
  
  //testing
  //wire [31:0] wt,wt2;
  //output [3:0] t2,t21;
  
  //output [31:0] A,B,C,D,E;
  //output [5:0] t;
  

  //reg
  reg [31:0] w [0:15];
  reg [31:0] B;
  reg [31:0] C;
  reg [31:0] D;
  reg [31:0] E;
  reg [31:0] T1;
  reg [5:0] t;
  reg [2:0] State, nextState;
  reg [31:0] k;



  //assign wt = w[t2];
  //assign wt2 = w[t21];
  //wire
  wire [3:0] t2,t21; 
  wire [3:0] t22,t28,t213,t212,t218,t2113;
  wire [31:0] A, s0, s1, s2, s3, co0, co1, co2, co3, fout0, fout1;


  assign t2 = {t[2:0],1'b0};
  assign t21 = {t[2:0],1'b1};
  assign done = (State==`DONE)?1'b1:1'b0;
  assign t22 = t2 + 4'd2;
  assign t28 = t2 + 4'd8;
  assign t213 = t2 + 4'd13;
  assign t212 = t21 + 4'd2;
  assign t218 = t21 + 4'd8;
  assign t2113 = t21 + 4'd13;
  assign A = T1+{B[26:0],B[31:27]};
  assign hash = (State==`DONE) ? {32'h67452301+A,32'hefcdab89+B,32'h98badcfe+C,32'h10325476+D,32'hc3d2e1f0+E}:160'd0;

  // state and next state
  always@(posedge clk or posedge reset) begin
    if(reset) State <= `RESET;
    else State <= nextState;
  end
  
  always@(*)begin
    case(State)
        `RESET: nextState=`R0;
 	      `R0: nextState=(t==6'd9)?`R1:`R0;
        `R1: nextState=(t==6'd19)?`R2:`R1; 
 	      `R2: nextState=(t==6'd29)?`R3:`R2;
 	      `R3: nextState=(t==6'd39)?`DONE:`R3;
          default nextState=State;
    endcase
  end

  //w array generate
  always@(posedge clk or posedge reset) begin
    if(reset) {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15]} <= message;
      else if(State!=`RESET)begin
          {w[t2][0],w[t2][31:1]} <= (w[t2]^w[t22]^w[t28]^w[t213]);
          {w[t21][0],w[t21][31:1]} <= (w[t21]^w[t212]^w[t218]^w[t2113]);
      end
  end
  
  //t
  always @(posedge clk or posedge reset) begin
    if(reset) t <= 6'd0;
    else if(State!=`RESET) t <= t+6'd1;
  end
  
  //k
  always @(*) begin
    case (State)
    `R1 : k = 32'h6ed9eba1;
    `R2 : k = 32'h8f1bbcdc;
    `R3 : k = 32'hca62c1d6;
    default: k = 32'h5a827999;
    endcase
  end

  //register initialize
  always @(posedge clk or posedge reset) begin
    if(reset)begin
      T1 <= 32'h6D8FB1C4;
      B <= 32'hefcdab89;
      C <= 32'h98badcfe;
      D <= 32'h10325476;
      E <= 32'hc3d2e1f0;
    end
    else if(State!=`RESET) begin
      T1 <= fout1+s3+co3;
      B <= s2+co2;
      {C[29:0],C[31:30]} <= A;
      {D[29:0],D[31:30]} <= B; 
      E <= C;
    end
  end
  
  //CSA
  CSA C0(E,k,w[t2],s0,co0);
  CSA C1(fout0,s0,co0,s1,co1);
  CSA C2({A[26:0],A[31:27]},s1,co1,s2,co2);
  CSA C3(D,k,w[t21],s3,co3);  
  
  //F
  F F2(State,B,C,D,fout0);
  F F21(State,A,{B[1:0],B[31:2]},C,fout1);
   
endmodule

module CSA(a,b,ci,s,co);
  input [31:0] a,b,ci;
  output [31:0] s,co;

  assign s=(a^b)^ci;
  assign co={((a&b)|(ci&b)|(a&ci)),1'b0};

endmodule


module F(State,x,y,z,fout);
  input [2:0] State;
  input [31:0] x,y,z;
  output reg [31:0] fout;

  always@(*) begin
    case (State)
      `R0: fout = (x&y)|(~x&z);
      `R2: fout = (x&y)^(x&z)^(y&z);
      default: fout = x^y^z;  
    endcase 
  end

endmodule









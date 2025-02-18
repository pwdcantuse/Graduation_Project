`define RESET 3'd0
`define R0  3'd1
`define R1  3'd2
`define R2  3'd3
`define DONE 3'd4

module MD4(clk, reset, message, hash, done);
    input clk;
    input reset;
    input [511:0] message;
    output [127:0] hash;
    output done;

    //reg
    reg [31:0] A,B,C,D,k;
    reg [5:0] i;
    reg [2:0] State, nextState;
    reg [4:0] b;
    reg [3:0] x;
    
    //wire
    wire [31:0] m [0:15];
    wire [31:0] s0,s1,co0,co1,fout,rout;
    wire [31:0] H0,H1,H2,H3,H0_,H1_,H2_,H3_;

    
    assign {m[0],m[1],m[2],m[3],m[4],m[5],m[6],m[7],m[8],m[9],m[10],m[11],m[12],m[13],m[14],m[15]} = message;
    assign done = (State==`DONE)?1'b1:1'b0;
    assign hash = {H0[7:0],H0[15:8],H0[23:16],H0[31:24],H1[7:0],H1[15:8],H1[23:16],H1[31:24],H2[7:0],H2[15:8],H2[23:16],H2[31:24],H3[7:0],H3[15:8],H3[23:16],H3[31:24]};
    assign H0 = 32'h67452301+A;
    assign H1 = 32'hefcdab89+B;
    assign H2 = 32'h98badcfe+C;
    assign H3 = 32'h10325476+D;

    //state
    always @(posedge clk or posedge reset) begin
        if(reset) State <= `RESET;
        else State <= nextState;
    end

    always @(*) begin
        case(State)
            `RESET: nextState = `R0;
            `R0 : nextState = (i==6'd15)?`R1:`R0;
            `R1 : nextState = (i==6'd31)?`R2:`R1;
            `R2 : nextState = (i==6'd47)?`DONE:`R2;
            default : nextState = State;
        endcase
    end

    //i
    always @(posedge clk or posedge reset) begin
        if(reset) i <= 6'd0;
        else if(State!=`RESET) i <= i+6'd1;
    end

    //k
    always @(*) begin
        case (State)
        `R1 : k = 32'h5a827999;
        `R2 : k = 32'h6ed9eba1;
        default: k = 32'd0;
        endcase
    end

    //x
    always @(*) begin
        case(State)
            `R1 : x = i[3:2]+{i[1:0],2'b00};
            `R2 : x = {i[2],i[3]}+{i[0],i[1],2'b00};
        default : x = i;
        endcase
    end

    //b
    always @(*) begin
        case(State)
            `R1 : begin
                case(i[1:0])
                    2'b00:b = 5'd3;
                    2'b01:b = 5'd5;
                    2'b10:b = 5'd9;
                    2'b11:b = 5'd13;
                endcase
            end 
            `R2 : begin
                case(i[1:0])
                    2'b00:b = 5'd3;
                    2'b01:b = 5'd9;
                    2'b10:b = 5'd11;
                    2'b11:b = 5'd15;
                endcase
            end 
        default : begin
            case(i[1:0])
                2'b00:b = 5'd3;
                2'b01:b = 5'd7;
                2'b10:b = 5'd11;
                2'b11:b = 5'd19;
            endcase
        end 
        endcase
    end

    //register initialize
    always @(posedge clk or posedge reset) begin
        if(reset)begin
          A <= 32'h67452301;
          B <= 32'hefcdab89;
          C <= 32'h98badcfe;
          D <= 32'h10325476;
        end
        else if(State!=`RESET) begin
          A <= D;
          B <= rout;
          C <= B;
          D <= C;
        end
    end

    //CSA
    CSA C0(A,m[x],k,s0,co0);
    CSA C1(fout,s0,co0,s1,co1);

    //F
    F F0(State,B,C,D,fout);

    //ROTATE
    ROTATE R0((s1+co1),b,rout);

endmodule

module CSA(a,b,ci,s,co);
  input [31:0] a,b,ci;
  output [31:0] s,co;

  assign s=(a^b)^ci;
  assign co={(a&b|a&ci|b&ci),1'b0};

endmodule

module F(State,x,y,z,fout);
  input [2:0] State;
  input [31:0] x,y,z;
  output reg [31:0] fout;

  always@(*) begin
    case (State)
      `R0: fout = (x&y)|(~x&z);
      `R1: fout = (x&y)|(x&z)|(y&z);
      default: fout = x^y^z;  
    endcase 
  end

endmodule

module ROTATE(n, b, out);
    input [31:0] n;
    input [4:0] b;
    output [31:0] out;

    assign out = (n<<b)|(n>>(6'd32-b));
endmodule
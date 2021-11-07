module mult #(
    parameter integer W = 16
) (
    input  wire signed [  W-1:0] A,
    input  wire signed [  W-1:0] B,
    output wire signed [2*W-1:0] C,
    output wire                  ser
);

  assign C   = A * B;
  assign ser = ^C[2*W-1 : 2*W-2];

endmodule

module sum #(
    parameter integer W = 16
) (
    input  wire signed [W-1:0] A,
    input  wire signed [W-1:0] B,
    output wire signed [W-1:0] C,
    output wire                ovr
);

  wire cout;

  assign {cout, C} = A + B;
  assign ovr = cout ^ C[W-1];


endmodule

module mult #(
    parameter integer W = 16
) (
    input  wire                clk,
    input  wire                arst_n,
    input  wire                ce,
    input  wire signed [  W-1:0] A,
    input  wire signed [  W-1:0] B,
    output wire signed [2*W-1:0] C,
    output wire                  ser
);

  wire [W-1:0] QA, QB;
  wire [2*W-1:0] QC, DC;

  DFF #(
      .EDGE ("NEG"),
      .WIDTH(W)
    ) DFF_MULT_A (
      .clk   (clk),
      .arst_n(arst_n),
      .ce    (ce),
      .D     (A),
      .Q     (QA)
  );

  DFF #(
      .EDGE ("NEG"),
      .WIDTH(W)
    ) DFF_MULT_B (
      .clk   (clk),
      .arst_n(arst_n),
      .ce    (ce),
      .D     (B),
      .Q     (QB)
  );

  assign DC   = QA * QB;
  assign ser = ^QC[2*W-1 : 2*W-2];

  DFF #(
      .EDGE ("POS"),
      .WIDTH(2*W)
    ) DFF_MULT_C (
      .clk   (clk),
      .arst_n(arst_n),
      .ce    (ce),
      .D     (DC),
      .Q     (QC)
  );
  
  assign C = QC;

endmodule

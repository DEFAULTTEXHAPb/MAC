`timescale 1ns / 1ps


module mac #(
    parameter integer N_LEN = 16,
    parameter integer Q_LEN = 8
) (
    input  wire                clk,
    input  wire                arst_n,
    input  wire                ce,
    input  wire                sload,
    input  wire signed [N_LEN-1:0] A,
    input  wire signed [N_LEN-1:0] B,
    output wire                rvalid,
    output wire signed [N_LEN-1:0] RES
);

  wire qsload;

  DFF #(
      .EDGE ("POS"),
      .WIDTH(1)
    ) DFF_SLOAD (
      .clk   (clk),
      .arst_n(arst_n),
      .ce    (ce),
      .D     (sload),
      .Q     (qsload)
  );

  wire signed [2*N_LEN-1:0] mult_reg;
  wire mult_err;

  mult #(
      .W(N_LEN)
    ) mult_dut (
      .clk   (clk),
      .arst_n(arst_n),
      .ce    (ce),
      .A  (A),
      .B  (B),
      .C  (mult_reg),
      .ser(mult_err)
  );

  wire signed [2*N_LEN-1:0] dacc_reg = (qsload == 1'b1) ? derr : dsumm;
  wire signed [2*N_LEN-1:0] qacc_reg;

  DFF #(
      .EDGE ("NEG"),
      .WIDTH(2*N_LEN)
    ) DFF_ACC (
      .clk   (clk),
      .arst_n(arst_n),
      .ce    (ce),
      .D     (dacc_reg),
      .Q     (qacc_reg)
  );

  wire sum_ovr;
  wire signed [2*N_LEN-1:0] dsumm;

  sum #(
      .W(2*N_LEN)
    ) sum_dut (
      .A  (qmult_reg),
      .B  (qacc_reg),
      .C  (dsumm),
      .ovr(sum_ovr)
  );

  wire signed [2*N_LEN-1:0] derr;
  wire signed [N_LEN-1:0] dres;

  round #(
      .N(N_LEN),
      .Q(Q_LEN)
    ) round_dut (
      .sum_err (sum_ovr),
      .mult_err(mult_err),
      .qsload  (qsload),
      .qacc    (qacc_reg),
      .rvalid  (rvalid),
      .res     (dres),
      .err     (derr)
  );


  DFF #(
      .EDGE ("POS"),
      .WIDTH(N_LEN)
    ) DFF_RES (
      .clk   (clk),
      .arst_n(arst_n),
      .ce    (ce),
      .D     (dres),
      .Q     (RES)
  );

  `ifdef COCOTB_SIM
    initial begin
      $dumpfile("mac.fst");
      $dumpvars(0, mac);
      #1;
    end
  `endif

endmodule

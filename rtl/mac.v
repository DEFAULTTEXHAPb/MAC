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

  wire signed [N_LEN-1:0] a_reg;

  DFF #(
    .EDGE ("NEG"),
    .WIDTH(N_LEN)
  ) DFF_A (
    .clk   (clk),
    .arst_n(arst_n),
    .ce    (ce),
    .D     (A),
    .Q     (a_reg)
  );

  wire signed [N_LEN-1:0] b_reg;

  DFF #(
    .EDGE ("NEG"),
    .WIDTH(N_LEN)
  ) DFF_B (
    .clk   (clk),
    .arst_n(arst_n),
    .ce    (ce),
    .D     (B),
    .Q     (b_reg)
  );

  wire signed [2*N_LEN-1:0] dmult_reg;
  wire mult_err;

  mult #(
    .W(N_LEN)
  ) mult_dut (
    .A  (a_reg),
    .B  (b_reg),
    .C  (dmult_reg),
    .ser(mult_err)
  );

  wire signed [2*N_LEN-1:0] qmult_reg;

  DFF #(
    .EDGE ("POS"),
    .WIDTH(2*N_LEN)
  ) DFF_MULT (
    .clk   (clk),
    .arst_n(arst_n),
    .ce    (ce),
    .D     (dmult_reg),
    .Q     (qmult_reg)
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
  wire signed [2*N_LEN-1:0] dres;

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

  // reg signed [  N_LEN-1:0] p_reg = {N_LEN{1'b0}};
  // reg signed [2*N_LEN-1:0] acc_reg = {2 * N_LEN{1'b0}};
  // reg                  sload_reg = 1'b1;
  // reg                  qpvalid = 1'b0;


  // always @(posedge clk or negedge arst_n) begin : init
  //   if (arst_n == 1'b0) begin
  //     sload_reg <= 1'b1;
  //     a_reg    <= {N_LEN{1'b0}};
  //     b_reg    <= {N_LEN{1'b0}};
  //   end else if (ce == 1'b1) begin
  //     sload_reg <= sload;
  //     a_reg <= A;
  //     b_reg <= B;
  //   end
  // end

  // always @(negedge clk or negedge arst_n) begin : mult
  //   if (arst_n == 1'b0) begin
  //     mult_reg <= {2 * N_LEN{1'b0}};
  //   end else if (ce == 1'b1) begin
  //     mult_reg <= a_reg * b_reg;
  //   end
  // end

  // always @(posedge clk or negedge arst_n) begin : accum
  //   if (arst_n == 1'b0) begin
  //     acc_reg <= {2 * N_LEN{1'b0}};
  //   end else if (ce == 1'b1) begin
  //     if (sload_reg == 1'b0) begin
  //       acc_reg <= acc_reg + mult_reg;
  //     end else begin
  //       acc_reg[2*N_LEN-1:N_LEN] <= {N_LEN{1'b0}};
  //     end
  //   end
  // end

  // always @(negedge clk or negedge arst_n) begin : result_extract
  //   if (arst_n == 1'b0) begin
  //     qpvalid <= 1'b0;
  //     p_reg   <= {N_LEN{1'b0}};
  //   end else if (ce == 1'b1) begin
  //     if (sload_reg == 1'b0) begin
  //       qpvalid <= 1'b0;
  //       p_reg   <= {N_LEN{1'b0}};
  //     end else begin
  //       qpvalid <= 1'b1;
  //       p_reg   <= acc_reg[2*N_LEN-1:N_LEN];
  //     end
  //   end
  // end

  // // always @(negedge clk or negedge arst_n) begin
  // //   if (arst_n == 1'b0) begin
  // //     sload_reg <= 1'b1;
  // //   end else if (ce == 1'b1) begin
  // //     sload_reg <= sload;
  // //   end
  // // end

  // assign P = (qpvalid == 1'b1) ? p_reg : {N_LEN{1'bz}};
  // assign pvalid = qpvalid;

`ifdef COCOTB_SIM
  initial begin
    $dumpfile("mac.fst");
    $dumpvars(0, mac);
    #1;
  end
`endif

endmodule

// module SE #(
//     parameter IN_WIDTH = 16,
//     parameter OUT_WIDTH = 32
//   ) (
//     input  wire [IN_WIDTH-1:0] in,
//     output wire [OUT_WIDTH-1:0] out
//   );

//   assign out = {{(OUT_WIDTH-IN_WIDTH){in[IN_WIDTH-1]}}, in};

// endmodule

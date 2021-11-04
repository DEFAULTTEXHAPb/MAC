`timescale 1ns/1ps

module mac #(
    parameter N = 16
  )(
    input  wire                clk,
    input  wire                arst_n,
    input  wire                ce,
    input  wire                sload,
    input  wire signed [N-1:0] A,
    input  wire signed [N-1:0] B,
    output wire                pvalid,
    output wire signed [N-1:0] P
  );

  reg signed [N-1:0]   a_reg = {N{1'b0}};
  reg signed [N-1:0]   b_reg = {N{1'b0}};
  reg signed [N-1:0]   p_reg = {N{1'b0}};
  reg signed [2*N-1:0] mult_reg = {2*N{1'b0}};
  reg signed [2*N-1:0] acc_reg = {2*N{1'b0}};
  reg                  sload_reg = 1'b1;
  reg                  qpvalid = 1'b0;

  always @(posedge clk or negedge arst_n) begin : init
    if (arst_n == 1'b0) begin
      sload_reg <= 1'b1;
      a_reg    <= {N{1'b0}};
      b_reg    <= {N{1'b0}};
    end else if (ce == 1'b1) begin
      sload_reg <= sload;
      a_reg <= A;
      b_reg <= B;
    end
  end

  always @(negedge clk or negedge arst_n) begin : mult
    if (arst_n == 1'b0) begin
      mult_reg <= {2*N{1'b0}};
    end else if (ce == 1'b1) begin
      mult_reg <= a_reg * b_reg;
    end
  end

  always @(posedge clk or negedge arst_n) begin : accum
    if (arst_n == 1'b0) begin
      acc_reg  <= {2*N{1'b0}};
    end else if (ce == 1'b1) begin
      if (sload_reg == 1'b0) begin
        acc_reg <= acc_reg + mult_reg;
      end else begin
        acc_reg[2*N-1:N] <= {N{1'b0}};
      end
    end
  end

  always @(negedge clk or negedge arst_n) begin : result_extract
    if (arst_n == 1'b0) begin
      qpvalid <= 1'b0;
      p_reg   <= {N{1'b0}};
    end else if (ce == 1'b1) begin
      if (sload_reg == 1'b0) begin
        qpvalid <= 1'b0;
        p_reg   <= {N{1'b0}};
      end else begin
        qpvalid <= 1'b1;
        p_reg   <= acc_reg[2*N-1:N];
      end
    end
  end

  // always @(negedge clk or negedge arst_n) begin
  //   if (arst_n == 1'b0) begin
  //     sload_reg <= 1'b1;
  //   end else if (ce == 1'b1) begin
  //     sload_reg <= sload;
  //   end
  // end

  assign P = (qpvalid == 1'b1)? p_reg : {N{1'bz}};
  assign pvalid = qpvalid;

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

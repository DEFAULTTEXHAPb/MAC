module MAC #(
    parameter N = 16
  )(
    input  wire                clk,
    input  wire                arst_n,
    input  wire                ce,
    input  wire                sload,
    input  wire signed [N-1:0] A,
    input  wire signed [N-1:0] B,
    output wire signed [N-1:0] P
  );

  reg signed [N-1:0]   a_reg;
  reg signed [N-1:0]   b_reg;
  reg signed [N-1:0]   p_reg;
  reg signed [2*N-1:0] mult_reg;
  reg signed [2*N-1:0] acc_reg;
  reg                  sload_reg;

  always @(posedge clk or negedge arst_n) begin : init
    if (arst_n == 1'b0) begin
      sload_reg <= 1'b1;
      a_reg    <= {N{1'b0}};
      b_reg    <= {N{1'b0}};
      acc_reg  <= {2*N{1'b0}};
    end else if (ce == 1'b1) begin
      sload_reg <= sload;
      a_reg <= A;
      b_reg <= B;
      acc_reg <= (sload_reg == 1'b0)? acc_reg + mult_reg : acc_reg;
    end
  end

  always @(posedge clk or negedge arst_n) begin : mult
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
        p_reg   <= {N{1'b0}};
      end else begin
        acc_reg[2*N-1:N] <= {N{1'b0}};
        p_reg            <= acc_reg[2*N-1:N];
      end
    end
  end

  assign P = (sload_reg == 1'b1)? p_reg : {N{1'bz}};



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

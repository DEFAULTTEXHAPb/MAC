module DFF #(
    parameter integer EDGE  = "POS",
    parameter integer WIDTH = 16
) (
    input  wire             clk,
    input  wire             arst_n,
    input  wire             ce,
    input  wire [WIDTH-1:0] D,
    output reg  [WIDTH-1:0] Q
);

  initial begin
    Q = {WIDTH{1'b0}};
  end

  generate
    if (EDGE == "POS") begin : g_posedge_trigger
      always @(posedge clk or negedge arst_n) begin : trigger
        if (arst_n == 1'b0) begin
          Q <= {WIDTH{1'b0}};
        end else if (ce == 1'b1) begin
          Q <= D;
        end
      end
    end else if (EDGE == "NEG") begin : g_negedge_trigger
      always @(negedge clk or negedge arst_n) begin : trigger
        if (arst_n == 1'b0) begin
          Q <= {WIDTH{1'b0}};
        end else if (ce == 1'b1) begin
          Q <= D;
        end
      end
    end else begin : g_conf_error
      initial begin
        $display("D-Trigger configuration check fail in %m");
        $finish(2);
      end
    end
  endgenerate

endmodule

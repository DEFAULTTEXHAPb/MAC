module round #(
    parameter integer N = 16,
    parameter integer Q = 8
) (
    input  wire           sum_err,
    input  wire           mult_err,
    input  wire           qsload,
    input  wire [2*N-1:0] qacc,
    output wire           rvalid,
    output wire [  N-1:0] res,
    output wire [2*N-1:0] err
);

  // localparam integer ACCUM_FRAC_LEN = 2 * Q;

  wire [2*N-1:0] ROUND_ADD = {{2*N-1{1'b0}}, 1'b1} << (Q-1);

  wire round_ovr;

  assign err = {{N{qacc[2*N-1]}}, qacc[N-1:0]};

  wire [2*N-1:0] round_acc;

  assign {round_ovr, round_acc} = qacc + ROUND_ADD;

  wire [2*N-1:0] trunc_acc = round_acc >>> (N-Q-1);

  assign rvalid = qsload & ~sum_err & ~mult_err & ~round_ovr;

  assign res = trunc_acc[N-1:0];


endmodule

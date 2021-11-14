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
  /*
  wire [2*N-1:0] ROUND_ADD = {{2*N-1{1'b0}}, 1'b1} << (Q-1);

  wire round_ovr, cround;

  assign err = {{N{qacc[2*N-1]}}, qacc[Q-1:0]};

  wire [2*N-1:0] temp_result, rounded_temp_result, round_acc;

  assign {cround, round_acc} = qacc + ROUND_ADD;

  assign round_ovr = cround ^ round_acc[2*N-1];

  wire [2*N-1:0] trunc_acc = round_acc >>> (N-Q-1);

  assign rvalid = qsload & ~sum_err & ~mult_err & ~round_ovr;

  assign res = trunc_acc[N-1:0];
  */

  localparam [2*N-1:0] ROUND_ADD = {{2*N-1{1'b0}}, 1'b1} << (Q-1);
  // localparam integer I_INT_LENGTH = 2*N - 2*Q;
  // localparam integer O_INT_LENGTH = N - Q;

  // -,00000
  // --,0000000000
  // --,-----10000

  wire round_ovr, cround;

  wire [2*N-1:0] temp_result = qacc >>> Q;

  wire [2*N-1:0] rtemp_result;

  assign {cround, rtemp_result} = temp_result + ROUND_ADD;

  assign round_ovr = cround ^ rtemp_result[2*N-1];

  assign res = rtemp_result[(N-1) -: N];

  assign err = {{(2*N-1-Q){qacc[2*N-1]}}, qacc[Q-1:0]};

  assign rvalid = qsload & ~sum_err & ~mult_err & ~round_ovr;

endmodule

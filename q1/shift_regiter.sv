module shift_register #(parameter N=4)
                      (input logic clk,
                       input logic rst_n,
                       input logic serial_parallel,
                       input logic load_enable,
                       input logic serial_in,
                       input logic [N-1:0] parallel_in,
                       output logic [N-1:0] parallel_out,
                       output logic serial_out);
  logic [N-1:0] shift_reg; // internal registor

//complete here
always_ff @( posedge clk or negedge rst_n ) 
begin
  if(!rst_n) begin
    shift_reg <= '0;
    end 
    else if (load_enable) begin
            if (serial_parallel) begin
                //
                shift_reg <= parallel_in;
            end 
            else begin
                // 
                shift_reg <= {shift_reg[N-2:0], serial_in};
            end
        end
end

  //output assign
    assign parallel_out = shift_reg;
    assign serial_out = shift_reg[N-1]; // MSB as serial output
endmodule


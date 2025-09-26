module shift_register_tb;

parameter N = 4;
    parameter CLK_PERIOD = 10;
    
    // all signal
    logic clk;
    logic rst_n;
    logic serial_parallel;
    logic load_enable;
    logic serial_in;
    logic [N-1:0] parallel_in;
    logic [N-1:0] parallel_out;
    logic serial_out;
    
    shift_register #(.N(N)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .serial_parallel(serial_parallel),
        .load_enable(load_enable),
        .serial_in(serial_in),
        .parallel_in(parallel_in),
        .parallel_out(parallel_out),
        .serial_out(serial_out)
    );
    
    // generate clock
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // parallel_load
    task test_parallel_load;
        input [N-1:0] test_data;
        begin
            serial_parallel = 1'b1;    // serial mode
            load_enable = 1'b1;        // enable
            parallel_in = test_data;   
            @(posedge clk);            
            #1;                        
            
            // verify output
            if (parallel_out !== test_data) begin
                $display("ERROR: Parallel load failed. Expected %b, Got %b", 
                         test_data, parallel_out);
            end else begin
                $display("PASS: Parallel load successful. Data = %b", parallel_out);
            end
        end
    endtask
    
    // serial_shift test
    task test_serial_shift;
        input [N-1:0] serial_pattern;
        begin
            serial_parallel = 1'b0;    // paralled mode
            load_enable = 1'b1;        // enable 
            
            //  input serial data by bit
            for (int i = N-1; i >= 0; i--) begin
                serial_in = serial_pattern[i];
                @(posedge clk);
                #1;
                $display("Shift step %0d: Input=%b, Output=%b", 
                         N-i, serial_in, parallel_out);
            end
            
            // verify output
            if (parallel_out !== serial_pattern) begin
                $display("ERROR: Serial shift failed. Expected %b, Got %b", 
                         serial_pattern, parallel_out);
            end else begin
                $display("PASS: Serial shift successful. Data = %b", parallel_out);
            end
        end
    endtask
    
    // disable load test
    task test_no_load;
        begin
            load_enable = 1'b0;        // disable load
            serial_in = 1'b1;          
            parallel_in = 4'b1111;     
            @(posedge clk);
            #1;
            
            // verify
            if (parallel_out !== 4'b0000) begin
                $display("ERROR: No load test failed. Output changed when load_enable=0");
            end else begin
                $display("PASS: No load test successful. Output remained unchanged");
            end
        end
    endtask
    
    //main test
    initial begin
        // initial signal
        clk = 0;
        rst_n = 0;
        serial_parallel = 0;
        load_enable = 0;
        serial_in = 0;
        parallel_in = 0;
        
        // rset
        #20;
        rst_n = 1;
        #10;
        
        $display("Starting testbench");
        
        
        $display("\n Parallel Load");
        test_parallel_load(4'b1010);
        test_parallel_load(4'b0101);
        test_parallel_load(4'b1111);
        test_parallel_load(4'b0000);
        
        
        $display("\n Serial Shift ");
        test_serial_shift(4'b1100);
        test_serial_shift(4'b1010);
        
        
        $display("\n  No Load Condition ");
        test_no_load();
        
    end
    
    // monitor
    always @(parallel_out) begin
        $display("Time %0t: parallel_out changed to %b", $time, parallel_out);
    end
    
    always @(serial_out) begin
        $display("Time %0t: serial_out changed to %b", $time, serial_out);
    end


endmodule
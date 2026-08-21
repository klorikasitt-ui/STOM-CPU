module testbench;
    reg clk_r;
    reg rst_nr;
    integer i;

    stom_top uut (
        .clk_i  (clk_r),
        .rst_ni (rst_nr)
    );

    initial begin
        clk_r = 1'b0;
        forever #5 clk_r = ~clk_r;
    end

    initial begin
        rst_nr = 1'b0;
        
        // Belleği sıfırla
        for (i = 0; i < 64; i = i + 1) begin
            uut.ram_inst.memory_array[i] = 32'h0;
        end

        // Komutları 'program.mem' dosyasından oku
        $readmemb("program.mem", uut.ram_inst.memory_array);

        #20;
        rst_nr = 1'b1;
        
        $display("Zaman | PC      | ALU Sonucu");
        $display("----------------------------------------");
        
        repeat (25) begin
            @(posedge clk_r);
            #1;
            $display("%0t   | %08h  | %08h", 
                     $time, 
                     uut.datapath_inst.pc_current_w, 
                     uut.datapath_inst.alu_result_w);
        end

        $finish;
    end
endmodule

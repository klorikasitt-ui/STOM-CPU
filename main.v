module stom_mux2 #(
    parameter DATA_WIDTH = 32
)(
    input  wire [DATA_WIDTH-1:0] data0_i,
    input  wire [DATA_WIDTH-1:0] data1_i,
    input  wire                  sel_i,
    output wire [DATA_WIDTH-1:0] data_o
);
    assign data_o = (sel_i) ? data1_i : data0_i;
endmodule

module stom_mux3 #(
    parameter DATA_WIDTH = 32
)(
    input  wire [DATA_WIDTH-1:0] data0_i,
    input  wire [DATA_WIDTH-1:0] data1_i,
    input  wire [DATA_WIDTH-1:0] data2_i,
    input  wire [1:0]            sel_i,
    output reg  [DATA_WIDTH-1:0] data_o
);
    always @(*) begin
        case (sel_i)
            2'b00: data_o = data0_i;
            2'b01: data_o = data1_i;
            2'b10: data_o = data2_i;
            default: data_o = {DATA_WIDTH{1'b0}};
        endcase
    end
endmodule

module stom_mux4 #(
    parameter DATA_WIDTH = 32
)(
    input  wire [DATA_WIDTH-1:0] data0_i,
    input  wire [DATA_WIDTH-1:0] data1_i,
    input  wire [DATA_WIDTH-1:0] data2_i,
    input  wire [DATA_WIDTH-1:0] data3_i,
    input  wire [1:0]            sel_i,
    output reg  [DATA_WIDTH-1:0] data_o
);
    always @(*) begin
        case (sel_i)
            2'b00: data_o = data0_i;
            2'b01: data_o = data1_i;
            2'b10: data_o = data2_i;
            2'b11: data_o = data3_i;
            default: data_o = {DATA_WIDTH{1'b0}};
        endcase
    end
endmodule

module stom_register #(
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk_i,
    input  wire                  rst_ni,
    input  wire                  en_i,
    input  wire [DATA_WIDTH-1:0] data_i,
    output reg  [DATA_WIDTH-1:0] data_o
);
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            data_o <= {DATA_WIDTH{1'b0}};
        end else if (en_i) begin
            data_o <= data_i;
        end
    end
endmodule

module stom_pc (
    input  wire        clk_i,
    input  wire        rst_ni,
    input  wire        pc_en_i,
    input  wire [31:0] pc_next_i,
    output wire [31:0] pc_current_o
);
    stom_register #(
        .DATA_WIDTH(32)
    ) pc_reg_inst (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .en_i   (pc_en_i),
        .data_i (pc_next_i),
        .data_o (pc_current_o)
    );
endmodule

module stom_register_file (
    input  wire        clk_i,
    input  wire        rst_ni,
    input  wire        we_i,
    input  wire [4:0]  read_addr1_i,
    input  wire [4:0]  read_addr2_i,
    input  wire [4:0]  write_addr_i,
    input  wire [31:0] write_data_i,
    output wire [31:0] read_data1_o,
    output wire [31:0] read_data2_o
);
    reg [31:0] register_array [0:31];
    integer i;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (i = 0; i < 32; i = i + 1) begin
                register_array[i] <= 32'd0;
            end
        end else if (we_i && (write_addr_i != 5'd0)) begin
            register_array[write_addr_i] <= write_data_i;
        end
    end

    assign read_data1_o = (read_addr1_i == 5'd0) ? 32'd0 : register_array[read_addr1_i];
    assign read_data2_o = (read_addr2_i == 5'd0) ? 32'd0 : register_array[read_addr2_i];
endmodule

module stom_alu (
    input  wire [31:0] operand_a_i,
    input  wire [31:0] operand_b_i,
    input  wire [3:0]  alu_op_i,
    output reg  [31:0] alu_result_o,
    output wire        zero_flag_o
);
    always @(*) begin
        case (alu_op_i)
            4'b0000: alu_result_o = operand_a_i & operand_b_i;
            4'b0001: alu_result_o = operand_a_i | operand_b_i;
            4'b0010: alu_result_o = operand_a_i + operand_b_i;
            4'b0011: alu_result_o = operand_a_i ^ operand_b_i;
            4'b0100: alu_result_o = ~(operand_a_i | operand_b_i);
            4'b0110: alu_result_o = operand_a_i - operand_b_i;
            4'b0111: alu_result_o = ($signed(operand_a_i) < $signed(operand_b_i)) ? 32'd1 : 32'd0;
            4'b1000: alu_result_o = ~operand_a_i;
            4'b1001: alu_result_o = operand_b_i;
            default: alu_result_o = 32'd0;
        endcase
    end
    assign zero_flag_o = (alu_result_o == 32'd0) ? 1'b1 : 1'b0;
endmodule

module stom_ram (
    input  wire        clk_i,
    input  wire        we_i,
    input  wire [31:0] addr_i,
    input  wire [31:0] data_i,
    output wire [31:0] data_o
);
    reg [31:0] memory_array [0:1023];
    wire [9:0] word_addr_w;
    
    assign word_addr_w = addr_i[11:2];
    
    always @(posedge clk_i) begin
        if (we_i) begin
            memory_array[word_addr_w] <= data_i;
        end
    end
    
    assign data_o = memory_array[word_addr_w];
endmodule

module stom_control_unit (
    input  wire        clk_i,
    input  wire        rst_ni,
    input  wire [5:0]  opcode_i,
    output reg         pc_write_cond_o,
    output reg         pc_write_o,
    output reg         i_or_d_o,
    output reg         mem_read_o,
    output reg         mem_write_o,
    output reg         mem_to_reg_o,
    output reg         ir_write_o,
    output reg  [1:0]  pc_source_o,
    output reg  [3:0]  alu_op_o,
    output reg  [1:0]  alu_src_b_o,
    output reg         alu_src_a_o,
    output reg         reg_write_o,
    output reg         reg_dst_o
);
    localparam STATE_FETCH      = 4'd0;
    localparam STATE_DECODE     = 4'd1;
    localparam STATE_MEM_ADR    = 4'd2;
    localparam STATE_MEM_RD     = 4'd3;
    localparam STATE_MEM_WB     = 4'd4;
    localparam STATE_MEM_WR     = 4'd5;
    localparam STATE_EXEC       = 4'd6;
    localparam STATE_ALU_WB     = 4'd7;
    localparam STATE_BRANCH     = 4'd8;
    localparam STATE_JUMP       = 4'd9;

    localparam OP_RTYPE = 6'b000000;
    localparam OP_LW    = 6'b100011;
    localparam OP_SW    = 6'b101011;
    localparam OP_BEQ   = 6'b000100;
    localparam OP_JUMP  = 6'b000010;
    localparam OP_ADDI  = 6'b001000;
    localparam OP_ANDI  = 6'b001100;
    localparam OP_ORI   = 6'b001101;
    localparam OP_XORI  = 6'b001110;

    reg [3:0] current_state_q, next_state_d;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            current_state_q <= STATE_FETCH;
        end else begin
            current_state_q <= next_state_d;
        end
    end

    always @(*) begin
        next_state_d = current_state_q;
        case (current_state_q)
            STATE_FETCH: begin
                next_state_d = STATE_DECODE;
            end
            STATE_DECODE: begin
                case (opcode_i)
                    OP_LW, OP_SW:  next_state_d = STATE_MEM_ADR;
                    OP_RTYPE, OP_ADDI, OP_ANDI, OP_ORI, OP_XORI: next_state_d = STATE_EXEC;
                    OP_BEQ:        next_state_d = STATE_BRANCH;
                    OP_JUMP:       next_state_d = STATE_JUMP;
                    default:       next_state_d = STATE_FETCH;
                endcase
            end
            STATE_MEM_ADR: begin
                if (opcode_i == OP_LW) begin
                    next_state_d = STATE_MEM_RD;
                end else if (opcode_i == OP_SW) begin
                    next_state_d = STATE_MEM_WR;
                end
            end
            STATE_MEM_RD: begin
                next_state_d = STATE_MEM_WB;
            end
            STATE_MEM_WB: begin
                next_state_d = STATE_FETCH;
            end
            STATE_MEM_WR: begin
                next_state_d = STATE_FETCH;
            end
            STATE_EXEC: begin
                next_state_d = STATE_ALU_WB;
            end
            STATE_ALU_WB: begin
                next_state_d = STATE_FETCH;
            end
            STATE_BRANCH: begin
                next_state_d = STATE_FETCH;
            end
            STATE_JUMP: begin
                next_state_d = STATE_FETCH;
            end
            default: begin
                next_state_d = STATE_FETCH;
            end
        endcase
    end

    always @(*) begin
        pc_write_cond_o = 1'b0;
        pc_write_o      = 1'b0;
        i_or_d_o        = 1'b0;
        mem_read_o      = 1'b0;
        mem_write_o     = 1'b0;
        mem_to_reg_o    = 1'b0;
        ir_write_o      = 1'b0;
        pc_source_o     = 2'b00;
        alu_op_o        = 4'b0000;
        alu_src_b_o     = 2'b00;
        alu_src_a_o     = 1'b0;
        reg_write_o     = 1'b0;
        reg_dst_o       = 1'b0;

        case (current_state_q)
            STATE_FETCH: begin
                mem_read_o  = 1'b1;
                i_or_d_o    = 1'b0;
                ir_write_o  = 1'b1;
                alu_src_a_o = 1'b0;
                alu_src_b_o = 2'b01;
                alu_op_o    = 4'b0010;
                pc_write_o  = 1'b1;
                pc_source_o = 2'b00;
            end
            STATE_DECODE: begin
                alu_src_a_o = 1'b0;
                alu_src_b_o = 2'b11;
                alu_op_o    = 4'b0010;
            end
            STATE_MEM_ADR: begin
                alu_src_a_o = 1'b1;
                alu_src_b_o = 2'b10;
                alu_op_o    = 4'b0010;
            end
            STATE_MEM_RD: begin
                mem_read_o  = 1'b1;
                i_or_d_o    = 1'b1;
            end
            STATE_MEM_WB: begin
                reg_write_o  = 1'b1;
                mem_to_reg_o = 1'b1;
                reg_dst_o    = 1'b0;
            end
            STATE_MEM_WR: begin
                mem_write_o = 1'b1;
                i_or_d_o    = 1'b1;
            end
            STATE_EXEC: begin
                alu_src_a_o = 1'b1;
                if (opcode_i == OP_RTYPE) begin
                    alu_src_b_o = 2'b00;
                    alu_op_o    = 4'b1111; 
                end else if (opcode_i == OP_ADDI) begin
                    alu_src_b_o = 2'b10;
                    alu_op_o    = 4'b0010;
                end else if (opcode_i == OP_ANDI) begin
                    alu_src_b_o = 2'b10;
                    alu_op_o    = 4'b0000;
                end else if (opcode_i == OP_ORI) begin
                    alu_src_b_o = 2'b10;
                    alu_op_o    = 4'b0001;
                end else if (opcode_i == OP_XORI) begin
                    alu_src_b_o = 2'b10;
                    alu_op_o    = 4'b0011;
                end
            end
            STATE_ALU_WB: begin
                reg_write_o  = 1'b1;
                mem_to_reg_o = 1'b0;
                if (opcode_i == OP_RTYPE) begin
                    reg_dst_o = 1'b1;
                end else begin
                    reg_dst_o = 1'b0;
                end
            end
            STATE_BRANCH: begin
                alu_src_a_o     = 1'b1;
                alu_src_b_o     = 2'b00;
                alu_op_o        = 4'b0110;
                pc_write_cond_o = 1'b1;
                pc_source_o     = 2'b01;
            end
            STATE_JUMP: begin
                pc_write_o  = 1'b1;
                pc_source_o = 2'b10;
            end
            default: begin
            end
        endcase
    end
endmodule

module stom_alu_decoder (
    input  wire [5:0] funct_i,
    input  wire [3:0] alu_op_i,
    output reg  [3:0] alu_control_o
);
    always @(*) begin
        if (alu_op_i == 4'b1111) begin
            case (funct_i)
                6'b100000: alu_control_o = 4'b0010;
                6'b100010: alu_control_o = 4'b0110;
                6'b100100: alu_control_o = 4'b0000;
                6'b100101: alu_control_o = 4'b0001;
                6'b100110: alu_control_o = 4'b0011;
                6'b100111: alu_control_o = 4'b1100;
                6'b101010: alu_control_o = 4'b0111;
                default:   alu_control_o = 4'b0000;
            endcase
        end else begin
            alu_control_o = alu_op_i;
        end
    end
endmodule

module stom_datapath (
    input  wire        clk_i,
    input  wire        rst_ni,
    input  wire [31:0] mem_data_i,
    input  wire        pc_write_cond_i,
    input  wire        pc_write_i,
    input  wire        i_or_d_i,
    input  wire        ir_write_i,
    input  wire [1:0]  pc_source_i,
    input  wire [3:0]  alu_control_i,
    input  wire [1:0]  alu_src_b_i,
    input  wire        alu_src_a_i,
    input  wire        reg_write_i,
    input  wire        reg_dst_i,
    input  wire        mem_to_reg_i,
    output wire [31:0] pc_current_o,
    output wire [31:0] adr_o,
    output wire [31:0] write_data_o,
    output wire [31:0] instr_o
);
    wire [31:0] pc_next_w;
    wire [31:0] pc_current_w;
    wire        pc_en_w;
    wire [31:0] instr_w;
    wire [31:0] data_reg_w;
    wire [4:0]  write_reg_addr_w;
    wire [31:0] write_reg_data_w;
    wire [31:0] read_data1_w;
    wire [31:0] read_data2_w;
    wire [31:0] a_reg_w;
    wire [31:0] b_reg_w;
    wire [31:0] sign_imm_w;
    wire [31:0] sign_imm_shifted_w;
    wire [31:0] alu_src_a_data_w;
    wire [31:0] alu_src_b_data_w;
    wire [31:0] alu_result_w;
    wire        alu_zero_w;
    wire [31:0] alu_out_reg_w;
    wire [31:0] jump_addr_w;

    assign pc_current_o = pc_current_w;
    assign instr_o = instr_w;
    assign write_data_o = b_reg_w;
    assign sign_imm_w = {{16{instr_w[15]}}, instr_w[15:0]};
    assign sign_imm_shifted_w = {sign_imm_w[29:0], 2'b00};
    assign jump_addr_w = {pc_current_w[31:28], instr_w[25:0], 2'b00};
    assign pc_en_w = pc_write_i | (pc_write_cond_i & alu_zero_w);

    stom_pc pc_inst (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .pc_en_i      (pc_en_w),
        .pc_next_i    (pc_next_w),
        .pc_current_o (pc_current_w)
    );

    stom_mux2 #(
        .DATA_WIDTH(32)
    ) adr_mux_inst (
        .data0_i (pc_current_w),
        .data1_i (alu_out_reg_w),
        .sel_i   (i_or_d_i),
        .data_o  (adr_o)
    );

    stom_register #(
        .DATA_WIDTH(32)
    ) instr_reg_inst (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .en_i   (ir_write_i),
        .data_i (mem_data_i),
        .data_o (instr_w)
    );

    stom_register #(
        .DATA_WIDTH(32)
    ) data_reg_inst (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .en_i   (1'b1),
        .data_i (mem_data_i),
        .data_o (data_reg_w)
    );

    stom_mux2 #(
        .DATA_WIDTH(5)
    ) write_reg_mux_inst (
        .data0_i (instr_w[20:16]),
        .data1_i (instr_w[15:11]),
        .sel_i   (reg_dst_i),
        .data_o  (write_reg_addr_w)
    );

    stom_mux2 #(
        .DATA_WIDTH(32)
    ) write_data_mux_inst (
        .data0_i (alu_out_reg_w),
        .data1_i (data_reg_w),
        .sel_i   (mem_to_reg_i),
        .data_o  (write_reg_data_w)
    );

    stom_register_file reg_file_inst (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .we_i         (reg_write_i),
        .read_addr1_i (instr_w[25:21]),
        .read_addr2_i (instr_w[20:16]),
        .write_addr_i (write_reg_addr_w),
        .write_data_i (write_reg_data_w),
        .read_data1_o (read_data1_w),
        .read_data2_o (read_data2_w)
    );

    stom_register #(
        .DATA_WIDTH(32)
    ) a_reg_inst (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .en_i   (1'b1),
        .data_i (read_data1_w),
        .data_o (a_reg_w)
    );

    stom_register #(
        .DATA_WIDTH(32)
    ) b_reg_inst (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .en_i   (1'b1),
        .data_i (read_data2_w),
        .data_o (b_reg_w)
    );

    stom_mux2 #(
        .DATA_WIDTH(32)
    ) alu_src_a_mux_inst (
        .data0_i (pc_current_w),
        .data1_i (a_reg_w),
        .sel_i   (alu_src_a_i),
        .data_o  (alu_src_a_data_w)
    );

    stom_mux4 #(
        .DATA_WIDTH(32)
    ) alu_src_b_mux_inst (
        .data0_i (b_reg_w),
        .data1_i (32'd4),
        .data2_i (sign_imm_w),
        .data3_i (sign_imm_shifted_w),
        .sel_i   (alu_src_b_i),
        .data_o  (alu_src_b_data_w)
    );

    stom_alu alu_inst (
        .operand_a_i  (alu_src_a_data_w),
        .operand_b_i  (alu_src_b_data_w),
        .alu_op_i     (alu_control_i),
        .alu_result_o (alu_result_w),
        .zero_flag_o  (alu_zero_w)
    );

    stom_register #(
        .DATA_WIDTH(32)
    ) alu_out_reg_inst (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .en_i   (1'b1),
        .data_i (alu_result_w),
        .data_o (alu_out_reg_w)
    );

    stom_mux3 #(
        .DATA_WIDTH(32)
    ) pc_source_mux_inst (
        .data0_i (alu_result_w),
        .data1_i (alu_out_reg_w),
        .data2_i (jump_addr_w),
        .sel_i   (pc_source_i),
        .data_o  (pc_next_w)
    );

endmodule

module stom_top (
    input  wire clk_i,
    input  wire rst_ni
);
    wire [31:0] mem_data_w;
    wire [31:0] write_data_w;
    wire [31:0] adr_w;
    wire        mem_read_w;
    wire        mem_write_w;
    
    wire        pc_write_cond_w;
    wire        pc_write_w;
    wire        i_or_d_w;
    wire        ir_write_w;
    wire [1:0]  pc_source_w;
    wire [3:0]  alu_op_w;
    wire [1:0]  alu_src_b_w;
    wire        alu_src_a_w;
    wire        reg_write_w;
    wire        reg_dst_w;
    wire        mem_to_reg_w;
    
    wire [31:0] instr_w;
    wire [3:0]  alu_control_w;
    
    stom_control_unit control_unit_inst (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .opcode_i        (instr_w[31:26]),
        .pc_write_cond_o (pc_write_cond_w),
        .pc_write_o      (pc_write_w),
        .i_or_d_o        (i_or_d_w),
        .mem_read_o      (mem_read_w),
        .mem_write_o     (mem_write_w),
        .mem_to_reg_o    (mem_to_reg_w),
        .ir_write_o      (ir_write_w),
        .pc_source_o     (pc_source_w),
        .alu_op_o        (alu_op_w),
        .alu_src_b_o     (alu_src_b_w),
        .alu_src_a_o     (alu_src_a_w),
        .reg_write_o     (reg_write_w),
        .reg_dst_o       (reg_dst_w)
    );

    stom_alu_decoder alu_decoder_inst (
        .funct_i       (instr_w[5:0]),
        .alu_op_i      (alu_op_w),
        .alu_control_o (alu_control_w)
    );

    stom_datapath datapath_inst (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .mem_data_i      (mem_data_w),
        .pc_write_cond_i (pc_write_cond_w),
        .pc_write_i      (pc_write_w),
        .i_or_d_i        (i_or_d_w),
        .ir_write_i      (ir_write_w),
        .pc_source_i     (pc_source_w),
        .alu_control_i   (alu_control_w),
        .alu_src_b_i     (alu_src_b_w),
        .alu_src_a_i     (alu_src_a_w),
        .reg_write_i     (reg_write_w),
        .reg_dst_i       (reg_dst_w),
        .mem_to_reg_i    (mem_to_reg_w),
        .pc_current_o    (),
        .adr_o           (adr_w),
        .write_data_o    (write_data_w),
        .instr_o         (instr_w)
    );

    stom_ram ram_inst (
        .clk_i  (clk_i),
        .we_i   (mem_write_w),
        .addr_i (adr_w),
        .data_i (write_data_w),
        .data_o (mem_data_w)
    );
endmodule

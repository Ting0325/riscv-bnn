module ACC(
    input clk,
    input rst_n,
    output reg enable,
    input [31:0] addr_in,
    input [31:0] data_in,
    input [31:0] data_mem,
    output reg [31:0] data_out,
    output logic wenb,
    output logic renb,
    output reg [15:2] addr_mem,
    output [3:0] webb_out
    );

    parameter ACC_MMAP_BASE = 32'hf000_ffff;
    parameter ACC_MMAP_RANG = 32'h0fff_0000;
    parameter ACC_MMAP_WRITE_SRC    =   32'h0008_0000;
    parameter ACC_MMAP_WRITE_DES    =   32'h000c_0000;
    parameter ACC_MMAP_START        =   32'h0010_0000;
    
    
    // Input A
    logic [15:2] A;
    // Input B
    logic [15:2] B;
    // Output Y
    logic [31:0] Y;

    // Internal masked  address
    logic [31:0] ACC_addr;
    
    logic [15:0] A_next;
    // Input B
    logic [15:0] B_next;
    // Output Y
    logic [31:0] Y_next;
    assign ACC_addr = (addr_in) & ACC_MMAP_RANG;
    //source and destination address and byte select
    logic word_addr;

    assign webb_out  = 4'b1111;

    
    // FSM
    localparam IDLE=2'd0, SRC=2'd1, DES=2'd2, START=2'd3;
    logic [1:0] curr_state;
    logic [1:0] next_state;
    // state reg
    always@(posedge clk or negedge rst_n)begin
      if (~rst_n) begin
					curr_state <= IDLE;
					A <= 0;
					B <= 0;
					Y <= 0;
					A_next <= 0;
					B_next <= 0;
					Y_next <= 0;
      end
      else begin
					curr_state <= next_state;
					A <= A_next;
					B <= B_next;
					Y <= Y_next;
    
      end
    end
    // next state logic    
    always@(*)begin
      case (curr_state)
        IDLE    : if (ACC_addr==ACC_MMAP_WRITE_SRC)begin
                    next_state = SRC;
                    A_next = data_in;
                    Y_next = Y;
                   end else 
                    next_state = IDLE;
        SRC     : if (ACC_addr==ACC_MMAP_WRITE_DES)begin
                    next_state = DES;
                    A_next = A;
                    B_next = data_in;
                    Y_next = data_mem;
                  end else 
                    next_state = SRC;
        DES   :   if (ACC_addr==ACC_MMAP_START)begin
                   next_state = START;
                   B_next = B;
                   Y_next = Y;
                  end else     
                   next_state = DES;

        START  : next_state = IDLE;
                  
        default :next_state = IDLE;
      endcase
    end
    
    // output logic
    always@(*)begin
      case (curr_state)

        IDLE    :begin
                  enable = 1'b0;
                  data_out = Y;
                  wenb = 1'b0;
                  renb = 1'b0;
                  end
        SRC     :begin
                  enable = 1'b1;
                  data_out = Y;
                  wenb = 1'b0;
                  renb = 1'b1;
                  addr_mem = A[15:2];
                  end
        DES     : begin
                  enable = 1'b1;
                  wenb = 1'b0;
                  data_out = Y;
                  renb = 1'b0;
                  addr_mem = 14'b0;
                  end
        START   : begin
                  enable = 1'b1;
                  data_out = Y;
                  wenb = 1'b1;
                  renb = 1'b0;
                  addr_mem = B[15:2];
                 end
      endcase
    end       
    
endmodule


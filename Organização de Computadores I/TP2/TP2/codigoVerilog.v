module fetch (input lt, zero, rst, clk, branch, jump, input [31:0] sigext, output [31:0] inst);
  
  wire [31:0] pc, pc_4, new_pc;
  wire [2:0] funct3;

  assign pc_4 = 4 + pc; // pc+4  Adder
  assign funct3 = inst[14:12]; // utilizado para distinguir tipos de branch

  always @(funct3 or jump) begin
    if(jump) 
      new_pc <= pc_4 + sigext;
    else
      begin
        case(funct3)
          3'b000: new_pc <= (branch & zero) ? pc_4 + sigext : pc_4; // beq
          3'b100: new_pc <= (branch & lt)   ? pc_4 + sigext : pc_4; // blt
          3'b101: new_pc <= (branch & (zero | !lt)) ? pc_4 + sigext : pc_4; // bge
          default: new_pc <= pc_4;
        endcase
      end
  end
  
  PC program_counter(new_pc, clk, rst, pc);

  reg [31:0] inst_mem [0:31];

  assign inst = inst_mem[pc[31:2]];

  initial begin
    // Testes 
    inst_mem[0] <= 32'h00000000;  // 0  nop
  end
  
endmodule

module PC (input [31:0] pc_in, input clk, rst, output reg [31:0] pc_out);

  always @(posedge clk) begin
    pc_out <= pc_in;
    if (~rst)
      pc_out <= 0;
  end

endmodule

module decode (input [31:0] inst, writedata, writedata2, input clk, output [31:0] data1, data2, ImmGen, output alusrc2, alusrc1, memsrc, memread, memwrite, memtoreg, branch, jump, output [1:0] aluop, output [9:0] funct);
  
  wire jump, branch, memsrc, memread, memtoreg, MemWrite, alusrc2, alusrc1, regwrite, regwrite2;
  wire [1:0] aluop; 
  wire [4:0] writereg, rs1, rs2, rd;
  wire [6:0] opcode;
  wire [9:0] funct;
  wire [31:0] ImmGen;

  assign opcode = inst[6:0];
  assign rs1    = inst[19:15];
  assign rs2    = inst[24:20];
  assign rd     = inst[11:7];
  assign funct = {inst[31:25],inst[14:12]};

  ControlUnit control (opcode, inst, alusrc2, alusrc1, memtoreg, regwrite, regwrite2, memsrc, memread, memwrite, branch, jump, aluop, ImmGen);
  
  Register_Bank Registers (clk, regwrite, regwrite2, rs1, rs2, rd, writedata, writedata2, data1, data2); 

endmodule

module ControlUnit (input [6:0] opcode, input [31:0] inst, output reg alusrc2, alusrc1, memtoreg, regwrite, regwrite2, memsrc, memread, memwrite, branch, jump, output reg [1:0] aluop, output reg [31:0] ImmGen);

  always @(opcode) begin
    alusrc2   <= 0;
    alusrc1   <= 0;
    memtoreg  <= 0;
    regwrite  <= 0;
    regwrite2 <= 0;
    memsrc    <= 0;
    memread   <= 0;
    memwrite  <= 0;
    branch    <= 0;
    aluop     <= 0;
    ImmGen    <= 0; 
    jump    <= 0;
    case(opcode) 
      7'b0110011: begin // R type == 51
        regwrite  <= 1;
        aluop     <= 2;
      end
      7'b1100011: begin // beq, blt, bge == 99
        branch    <= 1;
        aluop     <= 1;
        ImmGen    <= {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
      end
      7'b0010011: begin // addi == 19 TIPO - I
        alusrc2   <= 1;
        regwrite  <= 1;
        ImmGen    <= {{20{inst[31]}},inst[31:20]};
      end
      7'b0000011: begin // lw == 3
        alusrc2   <= 1;
        memtoreg  <= 1;
        regwrite  <= 1;
        memread   <= 1;
        ImmGen    <= {{20{inst[31]}},inst[31:20]};
      end
      7'b0100011: begin // sw == 35
        alusrc2   <= 1;
        memwrite  <= 1;
        ImmGen    <= {{20{inst[31]}},inst[31:25],inst[11:7]};
      end
          7'b0110111: begin //LUI == 55
        alusrc2   <= 1;
        regwrite  <= 1;
        aluop     <= 3;
              ImmGen   <= {inst[31:12]};
      end
          7'b0001010: begin // LWI == 10 OBS.: Meu funct será 5, para cair que alucontrol = 5 (usei funct 5 de tipo r emprestada)
        alusrc2   <= 0;
        memtoreg  <= 1;
        regwrite  <= 1;
        memread   <= 1;
      
      end
      7'b0000010: begin // swap == 2
        alusrc2   <= 1;
        regwrite  <= 1;
        regwrite2 <= 1;
      end
      7'b0000100: begin // ss == 8
        alusrc1   <= 1;
        alusrc2   <= 1;
        memsrc    <= 1;
        memwrite  <= 1;
        ImmGen    <= {{20{inst[31]}},inst[31:25],inst[11:7]};
      end
          7'b1101111: begin //Jump J baseado no JAL
          jump <= 1;
            ImmGen <= {{12'b0},inst[31],inst[19:12],inst[20],inst[30:21]};
            end
    endcase
  end

endmodule

module Register_Bank (input clk, regwrite, regwrite2, input [4:0] read_reg1, read_reg2, writereg, input [31:0] writedata, writedata2, output [31:0] read_data1, read_data2);

  integer i;
  reg [31:0] memory [0:31]; // 32 registers de 32 bits cada

  // fill the memory
  initial begin
    for (i = 0; i <= 31; i++) 
      memory[i] <= i;
  end

  assign read_data1 = (regwrite && read_reg1==writereg) ? writedata : memory[read_reg1];
  assign read_data2 = (regwrite && read_reg2==writereg) ? writedata : memory[read_reg2];
  
  always @(posedge clk) begin
    if (regwrite && ~regwrite2)
      memory[writereg] <= writedata;
    else if (regwrite && regwrite2) begin // swap
      memory[read_reg1] <= writedata2; // Por enquanto, só possibilita escrita em read_reg1 utilizando writedata2.
      memory[read_reg2] <= writedata;
    end
  end
  
endmodule

module execute (input [31:0] in1, in2, ImmGen, input alusrc2, alusrc1, input [1:0] aluop, input [9:0] funct, output lt, zero, output [31:0] aluout1, aluout2);

  wire [31:0] alu_A, alu_B;
  wire [3:0] aluctrl;
  
  assign alu_A = (alusrc1) ? in2 : in1 ;
  assign alu_B = (alusrc2) ? ImmGen : in2 ; // Decide entre o Imm gen e o rs2

  // Primeira mão da saída aluout1
  assign aluout1 = in1;

  //Unidade Lógico Aritimética
  ALU alu (aluctrl, alu_A, alu_B, aluout2, lt, zero);

  alucontrol alucontrol (aluop, funct, aluctrl);

endmodule

module alucontrol (input [1:0] aluop, input [9:0] funct, output reg [3:0] alucontrol);
  
  wire [7:0] funct7;
  wire [2:0] funct3;

  assign funct3 = funct[2:0];
  assign funct7 = funct[9:3];

  always @(aluop) begin
    case (aluop)
      0:begin
          case(funct3)
              6: alucontrol <= 4'd1;
                1: alucontrol <= 4'd3;
                5: alucontrol <= 4'd5; //LWI
              default: alucontrol <= 4'd2; // ADD to SW and LW
            endcase
        end
      1: alucontrol <= 4'd6; // SUB to branch
      3: alucontrol <= 4'd4; //Usado pelo lui
      default: begin
        case (funct3)
          0: alucontrol <= (funct7 == 0) ? /*ADD*/ 4'd2 : /*SUB*/ 4'd6; 
          2: alucontrol <= 4'd7; // SLT
          6: alucontrol <= 4'd1; // OR
          //39: alucontrol <= 4'd12; // NOR
          7: alucontrol <= 4'd0; // AND
          default: alucontrol <= 4'd15; // Nop
        endcase
      end
    endcase
  end
endmodule

module ALU (input [3:0] alucontrol, input [31:0] A, B, output reg [31:0] aluout2, output lt, zero);
  
  assign lt   = (aluout2[31]);  // Vendo pelo bit de sinal
    assign zero = (aluout2 == 0); // Zero recebe um valor lógico caso aluout2 seja igual a zero.
  
  always @(alucontrol, A, B) begin
      case (alucontrol)
        0: aluout2 <= A & B; // AND
        1: aluout2 <= A | B; // OR
        2: aluout2 <= A + B; // ADD
        3: aluout2 <= A << B; //SLLI
        4: aluout2 <= {B,12'b0}; //LUI
        5: aluout2 <= (A + B) << 2; //LWI
        6: aluout2 <= A - B; // SUB
        //7: aluout2 <= A < B ? 32'd1:32'd0; //SLT
        //12: aluout2 <= ~(A | B); // NOR
      default: aluout2 <= 0; //default 0, Nada acontece;
    endcase
  end
endmodule

module memory (input [31:0] address, writedata, input memread, memwrite, clk, output [31:0] readdata);

  integer i;
  reg [31:0] memory [0:127]; 
  
  // fill the memory
  initial begin
    for (i = 0; i <= 127; i++) 
      memory[i] <= i;
  end

  assign readdata = (memread) ? memory[address[31:2]] : 0;

  always @(posedge clk) begin
    if (memwrite)
      memory[address[31:2]] <= writedata;
  end
endmodule

module writeback (input [31:0] aluout2, readdata, rawrs2, input memtoreg, output reg [31:0] write_data, write_data2);
  always @(memtoreg) begin
    write_data  <= (memtoreg) ? readdata : aluout2;
    write_data2 <= rawrs2;
  end
endmodule

// TOP -------------------------------------------
module mips (input clk, rst, output [31:0] writedata, writedata2);
  
  wire [31:0] inst, sigext, data1, data2, aluout1, aluout2, readdata, memadr, memdata;
  wire lt, zero, memsrc, memread, memwrite, memtoreg, branch, jump, alusrc2, alusrc1;
  wire [9:0] funct;
  wire [1:0] aluop;
  
  // FETCH STAGE
  fetch fetch (lt, zero, rst, clk, branch, jump, sigext, inst);
  
  // DECODE STAGE
  decode decode (inst, writedata, writedata2, clk, data1, data2, sigext, alusrc2, alusrc1, memsrc, memread, memwrite, memtoreg, branch, jump, aluop, funct);   
  
  // EXECUTE STAGE
  execute execute (data1, data2, sigext, alusrc2, alusrc1, aluop, funct, lt, zero, aluout1, aluout2);

  // Choosing memory address and data inputs
  assign memadr  = (memsrc) ? aluout1 << 2 : aluout2;
  assign memdata = (memsrc) ? aluout2 : data2;
  // MEMORY STAGE
  memory memory (memadr, memdata, memread, memwrite, clk, readdata);

  // WRITEBACK STAGE
  writeback writeback (aluout2, readdata, data2, memtoreg, writedata, writedata2);

endmodule